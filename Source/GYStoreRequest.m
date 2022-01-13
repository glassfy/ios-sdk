//
//  GYStoreRequest.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import "GYStoreRequest.h"
#import "Glassfy+Private.h"
#import "GYOffering.h"
#import <StoreKit/StoreKit.h>
#import "GYSku.h"
#import "GYLogger.h"


typedef void (^GYProductResponseHandler)(SKProductsResponse* _Nullable, NSError* _Nullable);

@interface GYStoreRequest() <SKProductsRequestDelegate>
@property (nonatomic, strong, nullable) NSMapTable<SKRequest*, NSSet*> *requestedProductIds;
@property (nonatomic, strong, nullable) NSMapTable<SKRequest*, NSArray<GYProductResponseHandler>*> *productCompletions;

@property (nonatomic, strong, nullable) NSMutableArray<GYRefreshReceiptCompletion> *receiptCompletions;

@property (nonatomic, strong, nullable) NSMutableArray<SKRequest*> *reqs;
@end

@implementation GYStoreRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.reqs = [NSMutableArray array];
        self.receiptCompletions = [NSMutableArray array];
        self.productCompletions = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableCopyIn];
        self.requestedProductIds = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
    }
    return self;
}


#pragma mark - public

- (void)productWithOfferings:(NSArray<GYOffering *> *)offerings completion:(GYStoreProductsCompletion)block
{
    NSMutableSet *productIds = [NSMutableSet set];
    for (GYOffering *o in offerings) {
        for (GYSku *s in o.skus) {
            [productIds addObject:s.productId];
        }
    }
    [self productWithIdentifiers:productIds completion:block];
}

- (void)productWithSkus:(NSArray<GYSku *> *)skus completion:(GYStoreProductsCompletion)block
{
    NSMutableSet *productIds = [NSMutableSet set];
    [skus enumerateObjectsUsingBlock:^(GYSku *sku, NSUInteger idx, BOOL *stop) {
        [productIds addObject:sku.productId];
    }];
    [self productWithIdentifiers:productIds completion:block];
}

- (void)productWithIdentifiers:(NSSet<NSString*> *)productIds completion:(GYStoreProductsCompletion)block
{
    if (productIds.count == 0) {
        block(@[], nil);
        return;
    }
    
    [self startProductRequest:productIds completion:^(SKProductsResponse *res, NSError *err) {
        typeof(block) __strong completion = block;
        if (completion) {
            completion(res.products ?: @[], err);
        }
    }];
}

- (void)productWithIdentifier:(NSString *)productId completion:(GYStoreProductCompletion)block
{
    if (productId.length == 0) {
        block(nil, nil);
        return;
    }
    [self startProductRequest:[NSSet setWithObject:productId] completion:^(SKProductsResponse *res, NSError *err) {
        typeof(block) __strong completion = block;
        if (completion) {
            completion(res.products.firstObject, err);
        }
    }];
}

- (void)refreshReceipt:(GYRefreshReceiptCompletion)block
{
    [self startRefreshReceiptWithCompletion:block];
}


#pragma mark - private

- (void)startProductRequest:(NSSet<NSString*> *)ids completion:(GYProductResponseHandler)block
{
    for (SKRequest *r in self.reqs) {
        NSSet *rIds = [self.requestedProductIds objectForKey:r];
        if (![ids isEqualToSet:rIds]) {
            continue;
        }
        
        GYLog(@"STORE IN FLIGHT product request: %@", [ids.allObjects componentsJoinedByString:@","]);
    
        NSArray *completions = [self.productCompletions objectForKey:r];
        completions = [completions arrayByAddingObject:block];
        [self.productCompletions setObject:completions forKey:r];
        
        return;
    }
    
    
    GYLog(@"STORE START product request: %@", [ids.allObjects componentsJoinedByString:@","]);
    
    SKProductsRequest *req = [[SKProductsRequest alloc] initWithProductIdentifiers:ids];
    req.delegate = self;
    [self.productCompletions setObject:@[block] forKey:req];
    [self.requestedProductIds setObject:ids forKey:req];
    [self.reqs addObject:req];
    
    [req start];
}

- (void)startRefreshReceiptWithCompletion:(GYRefreshReceiptCompletion)block
{
    if (self.receiptCompletions.count) {
        GYLog(@"STORE IN FLIGHT refresh receipt");
        
        [self.receiptCompletions addObject:block];
        return;
    }

    GYLog(@"STORE START refresh receipt");

    [self.receiptCompletions addObject:block];
    SKReceiptRefreshRequest *req = [[SKReceiptRefreshRequest alloc] init];
    req.delegate = self;
    
    [self.reqs addObject:req];
    
    [req start];
}

- (void)handleSuccessfulRequest:(SKRequest *)req response:(nullable SKProductsResponse *)response
{
    if ([req isKindOfClass:SKProductsRequest.class]) {
        GYLog(@"STORE FOUND %lu products", (unsigned long)response.products.count);
        if (response.invalidProductIdentifiers.count) {
            GYLog(@"STORE INVALID products: %@", response.invalidProductIdentifiers);
        }
        NSArray *completions = [self.productCompletions objectForKey:req];
        [self.productCompletions removeObjectForKey:req];
        [self.requestedProductIds removeObjectForKey:req];
        for (GYProductResponseHandler completion in completions) {
            completion(response,nil);
        }
    }
    else if ([req isKindOfClass:SKReceiptRefreshRequest.class]) {
        GYLog(@"STORE SUCCESS refresh receipt");
        for (GYRefreshReceiptCompletion completion in self.receiptCompletions) {
            completion(nil);
        }
    }
    [self.reqs removeObject:req];
}

- (void)handleFailedRequest:(SKRequest *)req withError:(NSError *)error
{
    GYLogErr(@"STORE ERROR: %@", error.debugDescription);
    
    if ([req isKindOfClass:SKProductsRequest.class]) {
        NSArray *completions = [self.productCompletions objectForKey:req];
        [self.productCompletions removeObjectForKey:req];
        [self.requestedProductIds removeObjectForKey:req];
        for (GYProductResponseHandler completion in completions) {
            completion(nil, error);
        }
    }
    else if ([req isKindOfClass:SKReceiptRefreshRequest.class]) {
        NSArray *completions = self.receiptCompletions;
        self.receiptCompletions = [NSMutableArray array];
        for (GYRefreshReceiptCompletion completion in completions) {
            completion(error);
        }
    }
    [self.reqs removeObject:req];
}


#pragma mark - SKProductsRequest

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    typeof(self) __weak weakSelf = self;
    dispatch_async(Glassfy.shared.glqueue, ^{
        [weakSelf handleFailedRequest:request withError:error];
    });
}

- (void)requestDidFinish:(SKRequest *)request
{
    if ([request isKindOfClass:SKReceiptRefreshRequest.class]) {
        typeof(self) __weak weakSelf = self;
        dispatch_async(Glassfy.shared.glqueue, ^{
            [weakSelf handleSuccessfulRequest:request response:nil];
        });
    }
}


#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    typeof(self) __weak weakSelf = self;
    dispatch_async(Glassfy.shared.glqueue, ^{
        [weakSelf handleSuccessfulRequest:request response:response];
    });
}

@end
