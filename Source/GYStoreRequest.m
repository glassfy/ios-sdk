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

- (void)productWithOfferings:(NSArray<GYOffering*> *)offerings completion:(GYStoreProductsCompletion)block
{
    NSMutableSet *productIds = [NSMutableSet set];
    for (GYOffering *o in offerings) {
        for (GYSku *s in o.skus) {
            [productIds addObject:s.productId];
        }
    }
    [self productWithIdentifiers:productIds completion:block];
}

- (void)productWithSkus:(NSArray<GYSku*> *)skus completion:(GYStoreProductsCompletion)block
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
    GYLog(@"STORE Start %lu product request", (unsigned long) ids.allObjects.count);
    GYLogInfo(@"STORE Requested products:\n\t%@", [ids.allObjects componentsJoinedByString:@"\n\t"]);
    
    for (SKRequest *r in self.reqs) {
        NSSet *rIds = [self.requestedProductIds objectForKey:r];
        if (![ids isEqualToSet:rIds]) {
            continue;
        }
        
        GYLog(@"STORE Product request already in progress");
    
        NSArray *completions = [self.productCompletions objectForKey:r];
        completions = [completions arrayByAddingObject:block];
        [self.productCompletions setObject:completions forKey:r];
        
        return;
    }
    
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
        GYLog(@"STORE Refresh receipt 🧾 in progress");
        
        [self.receiptCompletions addObject:block];
        return;
    }

    GYLog(@"STORE Start refresh receipt 🧾");

    [self.receiptCompletions addObject:block];
    SKReceiptRefreshRequest *req = [[SKReceiptRefreshRequest alloc] init];
    req.delegate = self;
    
    [self.reqs addObject:req];
    
    [req start];
}

- (void)handleSuccessfulRequest:(SKRequest *)req response:(nullable SKProductsResponse *)response
{
    if ([req isKindOfClass:SKProductsRequest.class]) {
        GYLog(@"STORE Found %lu products", (unsigned long)response.products.count);
        GYLogErr(response.invalidProductIdentifiers.count ?
                 [NSString stringWithFormat:@"STORE Invalid %lu products", (unsigned long)response.invalidProductIdentifiers.count] :
                 nil);
        GYLogHint(response.invalidProductIdentifiers.count ?
                  [NSString stringWithFormat:@"StoreKit does not return details for the following products:\n\t%@\nCheck the guide at 🔗 https://docs.glassfy.io/16293898", [response.invalidProductIdentifiers componentsJoinedByString:@"\n\t"]] :
                  nil);
        
        
        
        
        
        NSArray *completions = [self.productCompletions objectForKey:req];
        [self.productCompletions removeObjectForKey:req];
        [self.requestedProductIds removeObjectForKey:req];
        for (GYProductResponseHandler completion in completions) {
            completion(response,nil);
        }
    }
    else if ([req isKindOfClass:SKReceiptRefreshRequest.class]) {
        GYLog(@"STORE Success refresh receipt 🧾");
        for (GYRefreshReceiptCompletion completion in self.receiptCompletions) {
            completion(nil);
        }
    }
    [self.reqs removeObject:req];
}

- (void)handleFailedRequest:(SKRequest *)req withError:(NSError *)error
{
    GYLogErr(@"STORE Error: %@", error.debugDescription);
    
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
