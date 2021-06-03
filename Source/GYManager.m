//
//  GYManager.m
//  Glassfy
//
//  Created by Luca Garbolino on 17/12/20.
//

#import <StoreKit/StoreKit.h>

#import "GYManager.h"
#import "GYCacheManager.h"
#import "GYAPIManager.h"
#import "GYStoreRequest.h"
#import "GYOffering.h"
#import "GYSku+Private.h"
#import "GYLogger.h"
#import "GYError.h"
#import "GYTypes.h"
#import "GYPermission+Private.h"
#import "GYTransaction+Private.h"
#import "GYOffering+Private.h"
#import "GYPermissions+Private.h"
#import "GYOfferings+Private.h"
#import "GYUserProperties+Private.h"
#import "Glassfy+Private.h"
#import "GYSysInfo.h"

@interface GYManager() <SKPaymentTransactionObserver>
@property(nonatomic, strong) GYCacheManager *cache;
@property(nonatomic, strong) GYAPIManager *api;
@property(nonatomic, strong) GYStoreRequest *store;
@property(nonatomic, assign) BOOL watcherMode;
@property(nonatomic, assign) BOOL initialized;

@property(nonatomic, strong) NSMapTable<SKProduct*, GYPaymentTransactionBlock> *purchaseCompletions;
@end

@implementation GYManager

+ (GYManager *)managerWithApiKey:(NSString *)apiKey watcherMode:(BOOL)watcherMode
{
    GYManager *manager = [[self alloc] initWithApiKey:apiKey watcherMode:watcherMode];
    [manager startSDK];
    return manager;
}

- (instancetype)initWithApiKey:(NSString *)apiKey watcherMode:(BOOL)watcherMode
{
    self = [super init];
    if (self) {
        self.watcherMode = watcherMode;
        self.store = [GYStoreRequest new];
        self.cache = [GYCacheManager new];
        self.api = [[GYAPIManager alloc] initWithApiKey:apiKey cache:self.cache];
        self.purchaseCompletions = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableCopyIn];
        
        if (GYSysInfo.applicationDidBecomeActiveNotification) {
            [NSNotificationCenter.defaultCenter addObserver:self
                                                   selector:@selector(applicationDidBecomeActive:)
                                                       name:GYSysInfo.applicationDidBecomeActiveNotification
                                                     object:nil];
        }
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (NSString *)apiKey
{
    return self.api.apiKey;
}

- (void)loginUser:(NSString *)userId withCompletion:(GYErrorCompletion _Nullable)block
{
    if (!userId) {
        [self logoutWithCompletion:block];
        return;
    }
    
    [self.api postLogin:userId withCompletion:^(GYAPIBaseResponse *res, NSError *err) {
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(err);
            });
        }
    }];
}

- (void)logoutWithCompletion:(GYErrorCompletion _Nullable)block
{
    [self.api postLogoutWithCompletion:^(GYAPIBaseResponse *res, NSError *err) {
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(err);
            });
        }
    }];
}

- (BOOL)watcherMode
{
    return _watcherMode;
}

- (void)permissionsWithCompletion:(GYPermissionsCompletion)block
{
    [self permissionsMaxRetries:2 completion:block];
}

- (void)offeringsWithCompletion:(GYOfferingsCompletion)block
{
    [self.api getOfferingsWithCompletion:^(GYAPIOfferingsResponse *res, NSError *apiErr) {
        [self.store productWithOfferings:res.offerings completion:^(NSArray<SKProduct *> *products, NSError *storeErr) {
            GYOfferings *offers = [GYOfferings offeringsWithOffers:res.offerings products:products];
            
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

- (void)purchaseSku:(GYSku *)sku completion:(GYPaymentTransactionBlock)block
{
    [self purchaseProduct:sku.product completion:block];
}

- (void)purchase:(NSString *)productId completion:(GYPaymentTransactionBlock)block
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
                    completion(nil, err ?: GYError.storeProductNotFound);
                });
            }
        }
    }];
}

- (void)purchaseProduct:(SKProduct *)product completion:(GYPaymentTransactionBlock)block
{
    for (SKProduct *p in self.purchaseCompletions.keyEnumerator) {
        if ([p.productIdentifier isEqualToString:product.productIdentifier]) {
            GYLogErr(@"PURCHASE already in progress");
            
            GYPaymentTransactionBlock completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, GYError.purchaseInProgress);
                });
            }
            return;
        }
    }
    
    [self.purchaseCompletions setObject:block forKey:product];
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [SKPaymentQueue.defaultQueue addPayment:payment];
}

- (void)purchaseProduct:(SKProduct *)product withDiscount:(SKProductDiscount *)discount completion:(GYPaymentTransactionBlock)block
{
    if (discount == nil) {
        [self purchaseProduct:product completion:block];
        
        return;
    }
    
    for (SKProduct *p in self.purchaseCompletions.keyEnumerator) {
        if ([p.productIdentifier isEqualToString:product.productIdentifier]) {
            GYLogErr(@"PURCHASE already in progress");
            
            GYPaymentTransactionBlock completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, GYError.purchaseInProgress);
                });
            }
            return;
        }
    }
    
    [self.purchaseCompletions setObject:block forKey:product];
    
    [self.api getSignatureForProductId:product.productIdentifier
                               offerId:discount.identifier
                            completion:^(GYAPISignatureResponse *res, NSError *err)
    {
        if (err) {
            GYPaymentTransactionBlock completion = [self.purchaseCompletions objectForKey:product];
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
//        payment.applicationUsername = weakSelf.cache.userId;
        [SKPaymentQueue.defaultQueue addPayment:payment];
    }];
}

- (void)restorePurchasesWithCompletion:(GYPermissionsCompletion)block
{
    NSURL *reciptURL = NSBundle.mainBundle.appStoreReceiptURL;
    if (reciptURL && [NSFileManager.defaultManager fileExistsAtPath:reciptURL.path]) {
        [self.api postReceipt:[NSData dataWithContentsOfURL:reciptURL]
                      product:nil
                  transaction:nil
                   completion:^(GYAPIPermissionsResponse *res, NSError *err)
        {
            GYPermissions *installation = [GYPermissions permissionsWithResponse:res];
            
            GYPermissionsCompletion completion = block;
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
                GYPermissionsCompletion completion = block;
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

- (void)addUserProperty:(GYUserPropertyType)property value:(id)obj completion:(GYUserPropertiesCompletion)block
{
    [self.api postProperty:property obj:obj completion:^(GYAPIPropertiesResponse *res, NSError *err) {
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                err ? completion(nil, err) : completion(res.properties, nil);
            });
        }
    }];
}

- (void)getUserProperties:(GYUserPropertiesCompletion)block
{
    [self.api getPropertiesWithCompletion:^(GYAPIPropertiesResponse *res, NSError *err) {
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                err ? completion(nil, err) : completion(res.properties, nil);
            });
        }
    }];
}

#pragma mark - Notification

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    typeof(self) __weak weakSelf = self;
    dispatch_async(Glassfy.shared.glqueue, ^{
        [weakSelf.api putLastSeen];
    });
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
    BOOL restored = NO;
    for (SKPaymentTransaction *transaction in transactions) {
        GYTransaction *t = [GYTransaction transactionWithPaymentTransaction:transaction];
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                GYLog(@"TRANSACTION %@ PURCHASED", t.productIdentifier);
                [self handlePurchasedTransaction:t];
                break;
            case SKPaymentTransactionStateRestored: // status from -[SKPaymentQueue restoreCompletedTransactions];
                GYLog(@"TRANSACTION %@ RESTORED", t.productIdentifier);
                if (!restored) {
                    [self handleRestoredTransaction:t];
                    restored = YES;
                }
                else {
                    [self completeTransaction:t];
                }
                break;
            case SKPaymentTransactionStateFailed:
                GYLogErr(@"TRANSACTION %@ FAILED: %@", t.productIdentifier, t.paymentTransaction.error.debugDescription);
                [self handleFailedTransaction:t];
                break;
            case SKPaymentTransactionStateDeferred:
                GYLog(@"TRANSACTION %@ DEFERRED", t.productIdentifier);
                [self handleDeferredTransaction:t];
                break;
            case SKPaymentTransactionStatePurchasing:
                GYLog(@"TRANSACTION %@ PURCHASING", t.productIdentifier);
                break;
        }
    }
}

- (void)handlePurchasedTransaction:(GYTransaction *)t
{
    GYPaymentTransactionBlock completion;
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
        completion = ^void(GYTransaction *tranansaction, NSError *err) {
            GYLogInfo(@"Default Purchase Completion Handler");
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
                                   completion:^(GYAPIPermissionsResponse *res, NSError *err) {
                        t.permissions = res.permissions ?: @[];
                        t.receiptValidated = (err.code != GYErrorCodeAppleReceiptStatusError);
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
                           completion:^(GYAPIPermissionsResponse *res, NSError *err) {
                t.permissions = res.permissions ?: @[];
                t.receiptValidated = (err.code != GYErrorCodeAppleReceiptStatusError);
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(t, err);
                });
                [weakSelf completeTransaction:t];
            }];
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, GYError.missingReceipt);    //ToDo
        });
        [self completeTransaction:t];
    }
}

- (void)handleRestoredTransaction:(GYTransaction *)t
{
    [self handlePurchasedTransaction:t];
}

- (void)handleFailedTransaction:(GYTransaction *)t
{
    //ToDo - send reason to server
    
    GYPaymentTransactionBlock completion;
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

- (void)handleDeferredTransaction:(GYTransaction *)t
{
    GYPaymentTransactionBlock completion;
    for (SKProduct *p in self.purchaseCompletions.keyEnumerator) {
        if ([p.productIdentifier isEqualToString:t.productIdentifier]) {
            completion = [self.purchaseCompletions objectForKey:p];
            [self.purchaseCompletions removeObjectForKey:p];
            break;
        }
    }
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, GYError.deferredPurchase);
        });
    }
}

- (void)completeTransaction:(GYTransaction *)t
{
    GYLog(@"TRANSACTION %@ COMPLETED", t.productIdentifier);

    if (t.paymentTransaction && !self.watcherMode) {
        GYLog(@"TRANSACTION %@ FINISH", t.productIdentifier);
        [[SKPaymentQueue defaultQueue] finishTransaction:t.paymentTransaction];
    }
}


#pragma mark - private

- (void)startSDK
{
    self.initialized = NO;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    typeof(self) __weak weakSelf = self;
    void (^sendReceipt)(BOOL) = ^(BOOL shouldSendReceipt) {
        NSURL *receiptURL = NSBundle.mainBundle.appStoreReceiptURL;
        if (shouldSendReceipt && receiptURL && [NSFileManager.defaultManager fileExistsAtPath:receiptURL.path]) {
            GYLogInfo(@"MANAGER STARTSDK sending local receipt");
            [weakSelf.api postReceipt:[NSData dataWithContentsOfURL:receiptURL]
                              product:nil
                          transaction:nil
                           completion:^(GYAPIPermissionsResponse *r, NSError *e)
            {
                weakSelf.initialized = YES;
            }];
        }
        else {
            GYLogInfo(shouldSendReceipt ?
                      @"MANAGER STARTSDK local receipt is missing, nothing to send..." :
                      @"MANAGER STARTSDK receipt not requested");
            weakSelf.initialized = YES;
        }
    };
    
    [self.api getInitWithInfoWithCompletion:^(GYAPIInitResponse *res, NSError *err) {
        BOOL shouldSendReceipt = !res.hasReceipt;
        [self.store productWithSkus:res.skus completion:^(NSArray<SKProduct *> *products, NSError *err) {
            if (products.count) {
                [weakSelf.api postProducts:products completion:^(GYAPIBaseResponse *r, NSError *e) {
                    sendReceipt(shouldSendReceipt);
                }];
            }
            else {
                sendReceipt(shouldSendReceipt);
            }
        }];
    }];
}

- (void)permissionsMaxRetries:(NSUInteger)times completion:(GYPermissionsCompletion)block
{
    GYGetPermissionsCompletion apiCompletion = ^(GYAPIPermissionsResponse *res, NSError *err) {
        if (err && times > 0) {
            typeof(self) __weak weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), Glassfy.shared.glqueue, ^{
                [weakSelf permissionsMaxRetries:(times-1) completion:block];
            });
        }
        else {
            GYPermissions *permssions = [GYPermissions permissionsWithResponse:res];
            
            typeof(block) __strong completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    err ? completion(nil, err) : completion(permssions, nil);
                });
            }
        }
    };
    
    if (!self.initialized) {
        apiCompletion(nil, GYError.sdkNotInitialized);
        return;
    }
    
    [self.api getPermissionsWithCompletion:apiCompletion];
}

- (void)matchSkusInOfferings:(NSArray<GYOffering*>*)offerings withProducts:(NSArray<SKProduct*>*)products
{
    for (GYOffering *o in offerings) {
        // match sku with product
        for (GYSku *s in o.skus) {
            NSPredicate *p = [NSPredicate predicateWithFormat:@"productIdentifier = %@", s.productId];
            s.product = [products filteredArrayUsingPredicate:p].firstObject;
        }
        
        // filter sku without product
        NSPredicate *p = [NSPredicate predicateWithFormat:@"product != nil"];
        o.skus = [o.skus filteredArrayUsingPredicate:p];
    }
}


@end
