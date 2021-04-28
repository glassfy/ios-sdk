//
//  GLManager.m
//  Glassfy
//
//  Created by Luca Garbolino on 17/12/20.
//

#import <StoreKit/StoreKit.h>

#import "GLManager.h"
#import "GLCacheManager.h"
#import "GLAPIManager.h"
#import "GLStoreRequest.h"
#import "GLOffering.h"
#import "GLSku+Private.h"
#import "GLLogger.h"
#import "GLError.h"
#import "GLTypes.h"
#import "GLPermission+Private.h"
#import "GLTransaction+Private.h"
#import "GLOffering+Private.h"
#import "GLPermissions+Private.h"
#import "GLOffers+Private.h"
#import "Glassfy+Private.h"
#import "GLSysInfo.h"

@interface GLManager() <SKPaymentTransactionObserver>
@property(nonatomic, strong) GLCacheManager *cache;
@property(nonatomic, strong) GLAPIManager *api;
@property(nonatomic, strong) GLStoreRequest *store;
@property(nonatomic, assign) BOOL watcherMode;
@property(nonatomic, assign) BOOL initialized;

@property(nonatomic, strong) NSMapTable<SKProduct*, GLPaymentTransactionBlock> *purchaseCompletions;
@end

@implementation GLManager

+ (GLManager *)managerWithApiKey:(NSString *)apiKey userId:(NSString *_Nullable)userId watcherMode:(BOOL)watcherMode completion:(GLErrorCompletion)block
{
    GLManager *manager = [[self alloc] initWithApiKey:apiKey userId:userId watcherMode:watcherMode];
    [manager startSDKWithCompletion:block];
    return manager;
}

- (instancetype)initWithApiKey:(NSString *)apiKey userId:(NSString *)userId watcherMode:(BOOL)watcherMode
{
    self = [super init];
    if (self) {
        self.watcherMode = watcherMode;
        self.store = [GLStoreRequest new];
        self.cache = [[GLCacheManager alloc] initWithUserId:userId];
        self.api = [[GLAPIManager alloc] initWithApiKey:apiKey cache:self.cache];
        self.purchaseCompletions = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableCopyIn];
    }
    return self;
}

- (void)logoutWithCompletion:(GLErrorCompletion _Nullable)block
{
    typeof(self) __weak weakSelf = self;
    [self.api postLogoutWithCompletion:^(GLAPIBaseResponse *res, NSError *err) {
        if (!err) {
            weakSelf.cache.userId = nil;
        }
        
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(err);
            });
        }
    }];
}

- (NSString *)apiKey
{
    return self.api.apiKey;
}


- (void)setUserId:(NSString *)userId
{
    self.cache.userId = userId;
    [self startSDKWithCompletion:nil];
}

- (NSString *)userId
{
    return self.cache.userId;
}

- (BOOL)watcherMode
{
    return _watcherMode;
}

- (void)permissionsWithCompletion:(GLPermissionsCompletion)block
{
    if (!self.initialized) {
        typeof(self) __weak weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), Glassfy.shared.glqueue, ^{
            [weakSelf permissionsWithCompletion:block];
        });
        return;
    }
    
    [self.api getPermissionsWithCompletion:^(GLAPIPermissionsResponse *res, NSError *err) {
        GLPermissions *installation = [GLPermissions permissionsWithResponse:res];
        
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                err ? completion(nil, err) : completion(installation, nil);
            });
        }
    }];
}

- (void)permissionWithIdentifier:(NSString *)identifier completion:(GLPermissionsCompletion)block
{
    if (!self.initialized) {
        typeof(self) __weak weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), Glassfy.shared.glqueue, ^{
            [weakSelf permissionWithIdentifier:identifier completion:block];
        });
        return;
    }
    
    [self.api getPermissionWithIdentifier:identifier completion:^(GLAPIPermissionsResponse *res, NSError *err) {
        GLPermissions *installation = [GLPermissions permissionsWithResponse:res];
        
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                err ? completion(nil, err) : completion(installation, nil);
            });
        }
    }];
}

- (void)offeringsWithCompletion:(GLOfferingsCompletion)block
{
    [self.api getOfferingsWithCompletion:^(GLAPIOfferingsResponse *res, NSError *apiErr) {
        [self.store productWithOfferings:res.offerings completion:^(NSArray<SKProduct *> *products, NSError *storeErr) {
            GLOfferings *offers = [GLOfferings offeringsWithOffers:res.offerings products:products];
            
            typeof(block) __strong completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *err = apiErr ?: storeErr;
                    err ? completion(nil, err) : completion(offers, nil);
                });
            }
        }];
    }];
}

- (void)offeringWithIdentifier:(NSString *)identifier completion:(GLOfferingsCompletion)block
{
    [self.api getOfferingWithIdentifier:identifier completion:^(GLAPIOfferingsResponse *res, NSError *apiErr) {
        [self.store productWithOfferings:res.offerings completion:^(NSArray<SKProduct *> *products, NSError *storeErr) {
            GLOfferings *offers = [GLOfferings offeringsWithOffers:res.offerings products:products];
            
            typeof(block) __strong completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *err = apiErr ?: storeErr;
                    err ? completion(nil, err) : completion(offers, nil);
                });
            }
        }];
    }];
}

- (void)purchaseSku:(GLSku *)sku completion:(GLPaymentTransactionBlock)block
{
    [self purchaseProduct:sku.product completion:block];
}

- (void)purchase:(NSString *)productId completion:(GLPaymentTransactionBlock)block
{
    typeof(self) __weak weakSelf = self;
    [self.store productWithIdentifier:productId completion:^(SKProduct *product, NSError *err) {
        if (product) {
            [weakSelf purchaseProduct:product completion:block];
        }
        else {
            typeof(block) __strong completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, err ?: GLError.storeProductNotFound);
                });
            }
        }
    }];
}

- (void)purchaseProduct:(SKProduct *)product completion:(GLPaymentTransactionBlock)block
{
    for (SKProduct *p in self.purchaseCompletions.keyEnumerator) {
        if ([p.productIdentifier isEqualToString:product.productIdentifier]) {
            GLLogErr(@"PURCHASE already in progress");
            
            GLPaymentTransactionBlock completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, GLError.purchaseInProgress);
                });
            }
            return;
        }
    }
    
    [self.purchaseCompletions setObject:block forKey:product];
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [SKPaymentQueue.defaultQueue addPayment:payment];
}

- (void)purchaseProduct:(SKProduct *)product withDiscount:(SKProductDiscount *)discount completion:(GLPaymentTransactionBlock)block
{
    if (discount == nil) {
        [self purchaseProduct:product completion:block];
        
        return;
    }
    
    for (SKProduct *p in self.purchaseCompletions.keyEnumerator) {
        if ([p.productIdentifier isEqualToString:product.productIdentifier]) {
            GLLogErr(@"PURCHASE already in progress");
            
            GLPaymentTransactionBlock completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, GLError.purchaseInProgress);
                });
            }
            return;
        }
    }
    
    [self.purchaseCompletions setObject:block forKey:product];
    
    typeof(self) __weak weakSelf = self;
    [self.api getSignatureForProductId:product.productIdentifier
                               offerId:discount.identifier
                            completion:^(GLAPISignatureResponse *res, NSError *err)
    {
        if (err) {
            GLPaymentTransactionBlock completion = [self.purchaseCompletions objectForKey:product];
            [self.purchaseCompletions removeObjectForKey:product];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, err);
                });
            }
        }

        SKPaymentDiscount *paymentDiscount = [[SKPaymentDiscount alloc] initWithIdentifier:discount.identifier
                                                                             keyIdentifier:res.keyIdentifier
                                                                                     nonce:res.nonce
                                                                                 signature:res.signature
                                                                                 timestamp:res.timestamp];
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        payment.paymentDiscount = paymentDiscount;
        payment.applicationUsername = weakSelf.cache.userId;
        [SKPaymentQueue.defaultQueue addPayment:payment];
    }];
}

- (void)restorePurchasesWithCompletion:(GLPermissionsCompletion)block
{
    NSURL *reciptURL = NSBundle.mainBundle.appStoreReceiptURL;
    if (reciptURL && [NSFileManager.defaultManager fileExistsAtPath:reciptURL.path]) {
        [self.api postReceipt:[NSData dataWithContentsOfURL:reciptURL]
                      product:nil
                  transaction:nil
                   completion:^(GLAPIPermissionsResponse *res, NSError *err)
        {
            GLPermissions *installation = [GLPermissions permissionsWithResponse:res];
            
            GLPermissionsCompletion completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(installation, err);
                });
            }
        }];
    }
    else {
        __weak typeof(self) weakSelf = self;
        [self.store refreshReceipt:^(NSError *err) {
            if (err) {
                GLPermissionsCompletion completion = block;
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, err);
                    });
                }
                return;
            }
            [weakSelf restorePurchasesWithCompletion:block];
        }];
    }
}


#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(nonnull SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions
{
    typeof(self) __weak weakSelf = self;
    dispatch_async(Glassfy.shared.glqueue, ^{
        [weakSelf handleUpdatedTransactions:transactions];
    });
}

- (void)handleUpdatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        GLTransaction *t = [GLTransaction transactionWithPaymentTransaction:transaction];
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                GLLog(@"TRANSACTION %@ PURCHASED", t.productIdentifier);
                [self handlePurchasedTransaction:t];
                break;
            case SKPaymentTransactionStateRestored: // status from -[SKPaymentQueue restoreCompletedTransactions];
                GLLog(@"TRANSACTION %@ RESTORED", t.productIdentifier);
                [self handleRestoredTransaction:t];
                break;
            case SKPaymentTransactionStateFailed:
                GLLogErr(@"TRANSACTION %@ FAILED: %@", t.productIdentifier, t.paymentTransaction.error.debugDescription);
                [self handleFailedTransaction:t];
                break;
            case SKPaymentTransactionStateDeferred:
                GLLog(@"TRANSACTION %@ DEFERRED", t.productIdentifier);
                [self handleDeferredTransaction:t];
                break;
            case SKPaymentTransactionStatePurchasing:
                GLLog(@"TRANSACTION %@ PURCHASING", t.productIdentifier);
                break;
        }
    }
}


#pragma mark - private

- (void)startSDKWithCompletion:(GLErrorCompletion _Nullable)block
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    typeof(self) __weak weakSelf = self;
    [self.api getInitWithInfoWithCompletion:^(GLAPIInitResponse *res, NSError *err) {
        [self.store productWithSkus:res.skus completion:^(NSArray<SKProduct *> *products, NSError *err) {
            if (products.count) {
                [weakSelf.api postProducts:products completion:nil];
            }
        }];
        
        BOOL initialized = YES;
        if (res && !res.hasReceipt) {
            NSURL *receiptURL = NSBundle.mainBundle.appStoreReceiptURL;
            GLLogInfo((receiptURL && [NSFileManager.defaultManager fileExistsAtPath:receiptURL.path]) ?
                      @"MANAGER STARTSDK sending local receipt..." :
                      @"MANAGER STARTSDK local receipt is missing, nothing to send...");
            if (receiptURL && [NSFileManager.defaultManager fileExistsAtPath:receiptURL.path]) {
                initialized = NO;
                [weakSelf.api postReceipt:[NSData dataWithContentsOfURL:receiptURL]
                                  product:nil
                              transaction:nil
                               completion:^(GLAPIPermissionsResponse *r, NSError *e)
                {
                    weakSelf.initialized = YES;
                }];
            }
        }
        weakSelf.initialized = initialized;
    }];
    
    typeof(block) __strong completion = block;
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });
    }
}

- (void)handlePurchasedTransaction:(GLTransaction *)t
{
    GLPaymentTransactionBlock completion;
    SKProduct *product;
    for (SKProduct *p in self.purchaseCompletions.keyEnumerator) {
        if ([p.productIdentifier isEqualToString:t.productIdentifier]) {
            product = p;
            completion = [self.purchaseCompletions objectForKey:p];
            [self.purchaseCompletions removeObjectForKey:p];
            
            break;
        }
    }
    if (!completion) {
        completion = ^void(GLTransaction *tranansaction, NSError *err) {
            //ToDO
            GLLog(@"Missing Purchasing Completion Handler");
        };
    }
    
    NSURL *appStoreURL = NSBundle.mainBundle.appStoreReceiptURL;
    if (appStoreURL && [NSFileManager.defaultManager fileExistsAtPath:appStoreURL.path]) {
        __weak typeof(self) weakSelf = self;
        if (!product) {
            [self.store productWithIdentifier:t.productIdentifier completion:^(SKProduct *p, NSError *err) {
                if (p) {
                    [weakSelf.purchaseCompletions setObject:completion forKey:p];
                    [weakSelf handlePurchasedTransaction:t];
                }
                else {
                    [weakSelf.api postReceipt:[NSData dataWithContentsOfURL:appStoreURL]
                                      product:nil
                                  transaction:t.paymentTransaction
                                   completion:^(GLAPIPermissionsResponse *res, NSError *err) {
                        t.permissions = res.permissions ?: @[];
                        t.receiptValidated = (err.code != GLErrorCodeAppleReceiptStatusError);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(t, err);
                        });
                        [weakSelf completeTransaction:t];
                    }];
                }
            }];
            return;
        }
        else {
            [self.api postReceipt:[NSData dataWithContentsOfURL:appStoreURL]
                          product:product
                      transaction:t.paymentTransaction
                           completion:^(GLAPIPermissionsResponse *res, NSError *err) {
                t.permissions = res.permissions ?: @[];
                t.receiptValidated = (err.code != GLErrorCodeAppleReceiptStatusError);
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(t, err);
                });
                [weakSelf completeTransaction:t];
            }];
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, GLError.missingReceipt);    //ToDo
        });
        [self completeTransaction:t];
    }
}

- (void)handleRestoredTransaction:(GLTransaction *)t
{
    [self handlePurchasedTransaction:t];
}

- (void)handleFailedTransaction:(GLTransaction *)t
{
    //ToDo - send reason to server
    
    GLPaymentTransactionBlock completion;
    for (SKProduct *p in self.purchaseCompletions.keyEnumerator) {
        if ([p.productIdentifier isEqualToString:t.productIdentifier]) {
            completion = [self.purchaseCompletions objectForKey:p];
            [self.purchaseCompletions removeObjectForKey:p];
            break;
        }
    }
    
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(t, t.paymentTransaction.error);
        });
    }
    [self completeTransaction:t];
}

- (void)handleDeferredTransaction:(GLTransaction *)t
{
    GLPaymentTransactionBlock completion;
    for (SKProduct *p in self.purchaseCompletions.keyEnumerator) {
        if ([p.productIdentifier isEqualToString:t.productIdentifier]) {
            completion = [self.purchaseCompletions objectForKey:p];
            [self.purchaseCompletions removeObjectForKey:p];
            break;
        }
    }
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, GLError.deferredPurchase);
        });
    }
}

- (void)completeTransaction:(GLTransaction *)t
{
    GLLog(@"TRANSACTION %@ COMPLETED", t.productIdentifier);

    if (t.paymentTransaction && !self.watcherMode) {
        GLLog(@"TRANSACTION %@ FINISH", t.productIdentifier);
        [[SKPaymentQueue defaultQueue] finishTransaction:t.paymentTransaction];
    }
}

- (void)matchSkusInOfferings:(NSArray<GLOffering*>*)offerings withProducts:(NSArray<SKProduct*>*)products
{
    for (GLOffering *o in offerings) {
        // match sku with product
        for (GLSku *s in o.skus) {
            NSPredicate *p = [NSPredicate predicateWithFormat:@"productIdentifier = %@", s.productId];
            s.product = [products filteredArrayUsingPredicate:p].firstObject;
        }
        
        // filter sku without product
        NSPredicate *p = [NSPredicate predicateWithFormat:@"product != nil"];
        o.skus = [o.skus filteredArrayUsingPredicate:p];
    }
}

@end
