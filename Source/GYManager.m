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
#import "GYLogger.h"
#import "GYError.h"
#import "GYTypes.h"
#import "GYSku+Private.h"
#import "GYPermission+Private.h"
#import "GYTransaction+Private.h"
#import "GYOffering+Private.h"
#import "GYPermissions+Private.h"
#import "GYOfferings+Private.h"
#import "GYUserProperties+Private.h"
#import "GYPaywallViewController+Private.h"
#import "GYStoresInfo+Private.h"
#import "Glassfy+Private.h"
#import "GYPurchasesHistory+Private.h"
#import "GYPaywall+Private.h"
#import "GYSysInfo.h"
#import "GYInitializeOptions.h"

@interface GYManager() <SKPaymentTransactionObserver>
@property(nonatomic, strong) GYCacheManager *cache;
@property(nonatomic, strong) GYAPIManager *api;
@property(nonatomic, strong) GYStoreRequest *store;
@property(nonatomic, strong) GYInitializeOptions *options;
@property(nonatomic, assign) BOOL initialized;

@property(nonatomic, weak) id<GYPurchaseDelegate> purchasesDelegate;
@property(nonatomic, strong) NSMapTable<GYSku*, GYPaymentTransactionBlock> *purchaseCompletions;
@end

@implementation GYManager

+ (GYManager *)managerWithOptions:(GYInitializeOptions *)options
{
    GYManager *manager = [[self alloc] initWithInitializeOptions:options];
    [manager startSDK];
    return manager;
}

- (instancetype)initWithInitializeOptions:(GYInitializeOptions *)options
{
    self = [super init];
    if (self) {
        self.options = options;
        
        self.store = [GYStoreRequest new];
        self.cache = [GYCacheManager new];
        self.api = [[GYAPIManager alloc] initWithApiKey:options.apiKey cache:self.cache];
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

- (void)setPurchaseDelegate:(id<GYPurchaseDelegate>)delegate
{
    _purchasesDelegate = delegate;
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
    return self.options.watcherMode;
}

- (void)permissionsWithCompletion:(GYPermissionsCompletion)block
{
    [self permissionsMaxRetries:10 completion:block];
}

- (void)offeringsWithCompletion:(GYOfferingsCompletion)block
{
    [self.api getOfferingsWithCompletion:^(GYAPIOfferingsResponse *res, NSError *apiErr) {
        [self.store productWithOfferings:res.offerings completion:^(NSArray<SKProduct*> *products, NSError *storeErr) {
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

- (void)skuWithId:(NSString *)skuid completion:(GYSkuBlock)block
{
    [self.api getSkuWithId:skuid store:GYStoreAppStore withCompletion:^(GYAPISkuResponse *res, NSError *apiErr) {
        GYSku *sku = (GYSku *) res.sku;
        [self.store productWithIdentifier:sku.productId completion:^(SKProduct *product, NSError *storeErr) {
            sku.product = product;
            
            NSError *err = apiErr ?: storeErr;
            if (!err) {
                if (!product) {
                    err = GYError.storeProductNotFound;
                }
                else if (@available(iOS 12.2, macOS 10.14.4, watchOS 6.2, *)) {
                    if (sku.promotionalId && !sku.discount) {
                        err = GYError.storeProductNotFound;
                    }
                }
                else if (sku.promotionalId) {
                    err = GYError.storeProductNotFound;
                }
            }
            
            typeof(block) __strong completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    err ? completion(nil, err) : completion(sku, nil);
                });
            }
        }];
    }];
}

- (void)skuWithProductId:(NSString *)productid promotionalId:(NSString *)promoid completion:(GYSkuBlock)block
{
    [self.api getSkuWithProductId:productid promotionalId:promoid withCompletion:^(GYAPISkuResponse *res, NSError *apiErr) {
        GYSku *sku = (GYSku *) res.sku;
        [self.store productWithIdentifier:sku.productId completion:^(SKProduct *product, NSError *storeErr) {
            sku.product = product;
            
            NSError *err = apiErr ?: storeErr;
            if (!err) {
                if (!product) {
                    err = GYError.storeProductNotFound;
                }
                else if (@available(iOS 12.2, macOS 10.14.4, watchOS 6.2, *)) {
                    if (sku.promotionalId && !sku.discount) {
                        err = GYError.storeProductNotFound;
                    }
                }
                else if (sku.promotionalId) {
                    err = GYError.storeProductNotFound;
                }
            }
            
            typeof(block) __strong completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    err ? completion(nil, err) : completion(sku, nil);
                });
            }
        }];
    }];
}

- (void)skuWithId:(NSString *)skuid store:(GYStore)store completion:(GYSkuBaseCompletion)block
{
    if (store == GYStoreAppStore) {
        [self skuWithId:skuid completion:block];
        return;
    }
    
    GYLogHint(store == GYStorePlayStore ?
              @"Impossible to retrive all information on a PlayStore SKU, only skuId and productId will be returned"
              : nil);
    
    [self.api getSkuWithId:skuid store:store withCompletion:^(GYAPISkuResponse *res, NSError *apiErr) {
        NSError *err = apiErr;
        if (!res && !err) {
            err = GYError.storeProductNotFound;
        }
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                err ? completion(nil, err) : completion(res.sku, nil);
            });
        }
    }];
}

- (void)purchaseSku:(GYSku *)sku completion:(GYPaymentTransactionBlock)block
{
    [self purchaseSku:sku withDiscountId:sku.promotionalId completion:block];
}

- (void)purchaseSku:(GYSku *)sku withDiscount:(SKProductDiscount *_Nullable)discount completion:(GYPaymentTransactionBlock)block
{
    [self purchaseSku:sku withDiscountId:discount.identifier completion:block];
}

- (void)restorePurchasesWithCompletion:(GYPermissionsCompletion)block
{
    NSURL *reciptURL = NSBundle.mainBundle.appStoreReceiptURL;
    typeof(self) __weak weakSelf = self;
    if (reciptURL && [NSFileManager.defaultManager fileExistsAtPath:reciptURL.path]) {
        [self.api postReceipt:[NSData dataWithContentsOfURL:reciptURL]
                          sku:nil
                  transaction:nil
                   completion:^(GYAPIPermissionsResponse *res, NSError *err)
        {
            GYPermissions *installation = [GYPermissions permissionsWithResponse:res
                                                                  installationId:weakSelf.cache.installationId];
            
            GYPermissionsCompletion completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(installation, err);
                });
            }
        }];
    }
    else {
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

- (void)setEmailUserProperty:(NSString *)email completion:(GYErrorCompletion)block
{
    if (email && ![email isKindOfClass:NSString.class]) {
        NSError *err = GYError.wrongParameterType;
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(err);
            });
        }
        return;
    }
    [self setUserProperty:GYUserPropertyTypeEmail value:email completion:block];
}

- (void)setDeviceToken:(NSString *)deviceToken completion:(GYErrorCompletion)block
{
    if (deviceToken && ![deviceToken isKindOfClass:NSString.class]) {
        NSError *err = GYError.wrongParameterType;
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(err);
            });
        }
        return;
    }
    [self setUserProperty:GYUserPropertyTypeToken value:deviceToken completion:block];
}

- (void)setExtraUserProperty:(NSDictionary *)extra completion:(GYErrorCompletion)block
{
    if (extra) {
        NSError *err;
        if (![extra isKindOfClass:NSDictionary.class]) {
            err = GYError.wrongParameterType;
        }
        else {
            for (id key in extra.allKeys) {
                if (![key isKindOfClass:NSString.class] ||
                    ![extra[key] isKindOfClass:NSString.class])
                {
                    err = GYError.wrongParameterType;
                    break;
                }
            }
        }
        
        if (err) {
            typeof(block) __strong completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(err);
                });
            }
            return;
        }
    }
    [self setUserProperty:GYUserPropertyTypeExtra value:extra completion:block];
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

- (void)paywallWithRemoteConfigurationId:(NSString *)remoteConfigId completion:(GYPaywallCompletion)block
{
#if TARGET_OS_IPHONE
    NSString *lang = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
    [self.api getPaywall:remoteConfigId locale:lang completion:^(GYAPIPaywallResponse *res, NSError *paywallErr) {
        GYPaywall *paywall;
        
        // Create the dispatch group
        dispatch_group_t serviceGroup = dispatch_group_create();
        
        __block NSError *storeError = nil;
        if (!paywallErr) {
            paywall = [GYPaywall paywallWithResponse:res];

            // Start sku request with appstore
            dispatch_group_enter(serviceGroup);
            [self.store productWithSkus:res.skus completion:^(NSArray<SKProduct*> *products, NSError *storeErr) {
                storeError = storeErr;
                if (!storeErr && (res.skus.count != products.count)) {
                    storeError = GYError.storeProductNotFound;
                }
                res.skus = [GYSku matchSkus:res.skus withProducts:products ?: @[]];
                dispatch_group_leave(serviceGroup);
            }];
        }
        
        dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
            NSError *overallError = paywallErr ?: storeError;
            if (overallError) {
                block(nil, overallError);
                return;
            }
            block(paywall, nil);
        });
    }];
#else
    dispatch_async(dispatch_get_main_queue(), ^{
        block(nil, GYError.notSupported);
    });
#endif
}

- (void)paywallViewControllerWithRemoteConfigurationId:(NSString *)remoteConfigId
                                          awaitLoading:(BOOL)awaitLoading
                                            completion:(GYPaywallViewControllerCompletion)block
{
#if TARGET_OS_IPHONE
    [self paywallWithRemoteConfigurationId:remoteConfigId completion:^(GYPaywall * _Nullable somePaywall, NSError * _Nullable error) {
        if (!somePaywall || error) {
            block(nil, error);
            return;
        }
        
        __block GYPaywall *paywall = somePaywall;
        if (awaitLoading) {
            [paywall setContentAvailableHandler:^(GYPaywallViewController * _Nullable viewController, NSError * _Nullable error) {
                if (error) {
                    block(nil, error);
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(viewController, nil);
                    paywall = nil;
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block([paywall viewController], nil);
                paywall = nil;
            });
        }
    }];
#else
    dispatch_async(dispatch_get_main_queue(), ^{
        block(nil, GYError.notSupported);
    });
#endif
}

- (void)connectPaddleLicenseKey:(NSString *)licenseKey force:(BOOL)force completion:(GYErrorCompletion)block
{
    [self.api postConnectPaddleLicenseKey:licenseKey force:force completion:^(GYAPIBaseResponse *res, NSError *err) {
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(err);
            });
        }
    }];
}

- (void)connectGlassfyUniversalCode:(NSString*)universalCode
                              force:(BOOL)force
                     withCompletion:(GYErrorCompletion)block
{
    [self.api postConnectGlassfyUniversalCode:universalCode force:force completion:^(GYAPIBaseResponse *res, NSError *err) {
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(err);
            });
        }
    }];
    
}

- (void)connectCustomSubscriber:(NSString *_Nullable)customId completion:(GYErrorCompletion)block
{
    [self.api postConnectUser:customId completion:^(GYAPIBaseResponse *res, NSError *err) {
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(err);
            });
        }
    }];
}

- (void)storeInfo:(GYStoreCompletion)block
{
    [self.api getStoreInfoWithCompletion:^(GYAPIStoreInfoResponse *res, NSError *err) {
        GYStoresInfo *storesInfo = [GYStoresInfo storesInfoWithResponse:res];
        
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                err ? completion(nil, err) : completion(storesInfo, nil);
            });
        }
    }];
}

- (void)setAttributionWithType:(GYAttributionType)type value:(NSString *_Nullable)value completion:(GYErrorCompletion)block
{
    GYAttributionItem *item = [GYAttributionItem attributionItemWithType:type value:value];
    [self setAttributions:@[item] completion:block];
}

- (void)setAttributions:(NSArray<GYAttributionItem *>*)attributions completion:(GYErrorCompletion)block
{
    [self setAttributions:attributions maxRetries:10 completion:block];
}

- (void)purchaseHistoryWithCompletion:(GYPurchaseHistoryCompletion)block
{
    [self purchaseHistoryMaxRetries:10 completion:block];
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

- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product
{
    if ([self.purchasesDelegate respondsToSelector:@selector(handlePromotedProductId:withPromotionalId:purchaseHandler:)])
    {
        NSString *promoid;
        if (@available(iOS 12.2, *)) {
            promoid = payment.paymentDiscount.identifier;
        }
        NSString *productid = product.productIdentifier;
        
        typeof(self) __weak weakSelf = self;
        [self.purchasesDelegate handlePromotedProductId:productid
                                      withPromotionalId:promoid
                                        purchaseHandler:^(GYPaymentTransactionBlock completionHandler)
         {
            dispatch_async(Glassfy.shared.glqueue, ^{
                GYPaymentTransactionBlock completion = completionHandler ?: ^void(GYTransaction *tranansaction, NSError *err) {
                    GYLogInfo(@"TRANSACTION %@ Promoted purchase default completion handler", tranansaction.productId);
                };
                
                GYSku *sku = [GYSku skuWithProduct:product];
                [weakSelf.purchaseCompletions setObject:completion forKey:sku];
                
                [SKPaymentQueue.defaultQueue addPayment:payment];
            });
        }];
        return NO;
    }
    return YES;
}

- (void)paymentQueue:(nonnull SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction*> *)transactions
{
    typeof(self) __weak weakSelf = self;
    dispatch_async(Glassfy.shared.glqueue, ^{
        [weakSelf handleUpdatedTransactions:transactions];
    });
}

- (void)handleUpdatedTransactions:(nonnull NSArray<SKPaymentTransaction*> *)transactions
{
    BOOL restored = NO;
    for (SKPaymentTransaction *transaction in transactions) {
        GYTransaction *t = [GYTransaction transactionWithPaymentTransaction:transaction];
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                GYLogInfo(@"TRANSACTION %@ Purchased", t.productId);
                [self handlePurchasedTransaction:t];
                break;
            case SKPaymentTransactionStateRestored: // status from -[SKPaymentQueue restoreCompletedTransactions];
                GYLogInfo(@"TRANSACTION %@ Restored", t.productId);
                if (!restored) {
                    [self handleRestoredTransaction:t];
                    restored = YES;
                }
                else {
                    [self completeTransaction:t];
                }
                break;
            case SKPaymentTransactionStateFailed:
                GYLogErr(@"TRANSACTION %@ Failed:\n\t%@", t.productId, t.paymentTransaction.error.debugDescription);
                [self handleFailedTransaction:t];
                break;
            case SKPaymentTransactionStateDeferred:
                GYLogInfo(@"TRANSACTION %@ Deferred", t.productId);
                [self handleDeferredTransaction:t];
                break;
            case SKPaymentTransactionStatePurchasing:
                GYLogInfo(@"TRANSACTION %@ Purchasing", t.productId);
                break;
        }
    }
}

- (void)handlePurchasedTransaction:(GYTransaction *)t
{
    GYPaymentTransactionBlock completion;
    GYSku *sku;
    for (GYSku *s in self.purchaseCompletions.keyEnumerator) {
        if ([s.productId isEqualToString:t.productId]) {
            sku = s;
            completion = [self.purchaseCompletions objectForKey:s];
            [self.purchaseCompletions removeObjectForKey:s];
            
            break;
        }
    }
    if (!completion) {
        completion = ^void(GYTransaction *tranansaction, NSError *err) {
            GYLogInfo(@"TRANSACTION %@ Purchase default completion handler", tranansaction.productId);
        };
    }
    
    NSURL *appStoreURL = NSBundle.mainBundle.appStoreReceiptURL;
    if (appStoreURL && [NSFileManager.defaultManager fileExistsAtPath:appStoreURL.path]) {
        typeof(self) __weak weakSelf = self;
        if (!sku) {
            [self.store productWithIdentifier:t.productId completion:^(SKProduct *p, NSError *err) {
                if (p) {
                    GYSku *s = [GYSku skuWithProduct:p];
                    [weakSelf.purchaseCompletions setObject:completion forKey:s];
                    [weakSelf handlePurchasedTransaction:t];
                }
                else {
                    [weakSelf.api postReceipt:[NSData dataWithContentsOfURL:appStoreURL]
                                          sku:nil
                                  transaction:t.paymentTransaction
                                   completion:^(GYAPIPermissionsResponse *res, NSError *err) {
                        t.permissions = [GYPermissions permissionsWithResponse:res
                                                                installationId:weakSelf.cache.installationId];
                        t.receiptValidated = (err.code != GYErrorCodeAppleReceiptStatusError);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(t, err);
                            if (!err && [weakSelf.purchasesDelegate respondsToSelector:@selector(didPurchaseProduct:)]) {
                                [weakSelf.purchasesDelegate didPurchaseProduct:t];
                            }
                        });
                        [weakSelf completeTransaction:t];
                    }];
                }
            }];
            return;
        }
        else {
            [self.api postReceipt:[NSData dataWithContentsOfURL:appStoreURL]
                              sku:sku
                      transaction:t.paymentTransaction
                           completion:^(GYAPIPermissionsResponse *res, NSError *err) {
                t.permissions = [GYPermissions permissionsWithResponse:res
                                                        installationId:weakSelf.cache.installationId];
                t.receiptValidated = (err.code != GYErrorCodeAppleReceiptStatusError);
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(t, err);
                    if (!err && [weakSelf.purchasesDelegate respondsToSelector:@selector(didPurchaseProduct:)]) {
                        [weakSelf.purchasesDelegate didPurchaseProduct:t];
                    }
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
    for (GYSku *s in self.purchaseCompletions.keyEnumerator) {
        if ([s.productId isEqualToString:t.productId]) {
            completion = [self.purchaseCompletions objectForKey:s];
            [self.purchaseCompletions removeObjectForKey:s];
            break;
        }
    }
    
    // add description and hint of error resolution
#ifdef DEBUG
    if ([t.paymentTransaction.error.domain isEqualToString:@"SKErrorDomain"]) {
        switch (t.paymentTransaction.error.code) {
            case SKErrorUnknown:
                GYLogErr(@"An Unknown error occurs");
                break;
            case SKErrorClientInvalid:
                GYLogErr(@"Client is not allowed to issue the request");
                break;
            case SKErrorPaymentCancelled:
                GYLogErr(@"User cancelled the payment request");
                break;
            case SKErrorPaymentNotAllowed:
                GYLogErr(@"This device (user) is not allowed to authorize payments");
                break;
        }
        if (@available(iOS 12.2, macOS 10.14.4, watchOS 6.2, *)) {
            switch (t.paymentTransaction.error.code) {
                case SKErrorInvalidSignature:
                    GYLogErr(@"The cryptographic signature provided for SKPaymentDiscount is not valid.");
                    GYLogHint(@"Make sure 'Subscription p8 Key File' and 'Subscription p8 Key ID' are correct on the app settings page 🔗 https://dashboard.glassfy.io");
                    break;
                case SKErrorInvalidOfferPrice:
                    GYLogErr(@"The price (specified in App Store Connect) of the selected offer is no longer valid (e.g. lower than the current base subscription price");
                    break;
            }
        }
        if (@available(iOS 14, macOS 11, watchOS 7, *)) {
            switch (t.paymentTransaction.error.code) {
                case SKErrorIneligibleForOffer:
                    GYLogErr(@"User is not eligible for the subscription offer");
                    break;
            }
        }
    }
#endif
    
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
    for (GYSku *s in self.purchaseCompletions.keyEnumerator) {
        if ([s.productId isEqualToString:t.productId]) {
            completion = [self.purchaseCompletions objectForKey:s];
            [self.purchaseCompletions removeObjectForKey:s];
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
    GYLogInfo(@"TRANSACTION %@ Completed", t.productId);

    if (t.paymentTransaction && !self.watcherMode) {
        GYLog(@"TRANSACTION %@ Finish", t.productId);
        [[SKPaymentQueue defaultQueue] finishTransaction:t.paymentTransaction];
    }
}


#pragma mark - private

- (void)startSDK
{
#if TARGET_OS_SIMULATOR
    GYLogHint(@"Not all features are supported on simulator.\nUse a real device to test.");
#endif
    self.initialized = NO;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    typeof(self) __weak weakSelf = self;
    void (^sendReceipt)(BOOL) = ^(BOOL shouldSendReceipt) {
        NSURL *receiptURL = NSBundle.mainBundle.appStoreReceiptURL;
        if (shouldSendReceipt && receiptURL && [NSFileManager.defaultManager fileExistsAtPath:receiptURL.path]) {
            GYLogInfo(@"MANAGER sending local receipt");
            [weakSelf.api postReceipt:[NSData dataWithContentsOfURL:receiptURL]
                                  sku:nil
                          transaction:nil
                           completion:^(GYAPIPermissionsResponse *r, NSError *e)
            {
                weakSelf.initialized = YES;
            }];
        }
        else {
            GYLogInfo(shouldSendReceipt ? @"MANAGER local receipt is missing, nothing to send..." : nil);
            weakSelf.initialized = YES;
        }
    };
    
    [self.api getInitWithCrossPlatformSdkFramework:self.options.crossPlatformSdkFramework
                           crossPlatformSdkVersion:self.options.crossPlatformSdkVersion
                                        completion:^(GYAPIInitResponse *res, NSError *err) {
        BOOL shouldSendReceipt = !res.hasReceipt;
        [self.store productWithSkus:res.skus completion:^(NSArray<SKProduct*> *products, NSError *err) {
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

- (void)purchaseSku:(GYSku *)sku withDiscountId:(NSString *)discountid completion:(GYPaymentTransactionBlock)block
{
#if TARGET_OS_SIMULATOR
    GYLogErr(@"Currently we do not support purchase through simulator, use a real device.\nFor more info check 🔗 https://docs.glassfy.io/1758942");
    GYPaymentTransactionBlock completion = block;
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, GYError.notSupported);
        });
    }
#else
    for (GYSku *s in self.purchaseCompletions.keyEnumerator) {
        if ([s.productId isEqualToString:sku.productId]) {
            GYLogErr(@"TRANSACTION %@ Purchase already in progress", s.productId);
            
            GYPaymentTransactionBlock completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, GYError.purchaseInProgress);
                });
            }
            return;
        }
    }
    
    [self.purchaseCompletions setObject:block forKey:sku];
    
    if (discountid == nil) {
        SKPayment *payment = [SKPayment paymentWithProduct:sku.product];
        [SKPaymentQueue.defaultQueue addPayment:payment];
        return;
    }
        
    [self.api getSignatureForProductId:sku.productId
                               offerId:discountid
                            completion:^(GYAPISignatureResponse *res, NSError *err)
    {
        if (err) {
            GYPaymentTransactionBlock completion = [self.purchaseCompletions objectForKey:sku];
            [self.purchaseCompletions removeObjectForKey:sku];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, err);
                });
            }
        }

    
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:sku.product];
        if (@available(iOS 12.2, macOS 10.14.4, watchOS 6.2, *)) {
            SKPaymentDiscount *paymentDiscount = [[SKPaymentDiscount alloc] initWithIdentifier:discountid
                                                                                 keyIdentifier:res.keyIdentifier
                                                                                         nonce:res.nonce
                                                                                     signature:res.signature
                                                                                     timestamp:res.timestamp];
            payment.applicationUsername = res.applicationUsername;
            payment.paymentDiscount = paymentDiscount;
        }

        [SKPaymentQueue.defaultQueue addPayment:payment];
    }];
#endif
}

- (void)permissionsMaxRetries:(NSUInteger)times completion:(GYPermissionsCompletion)block
{
    typeof(self) __weak weakSelf = self;
    GYGetPermissionsCompletion apiCompletion = ^(GYAPIPermissionsResponse *res, NSError *err) {
        if (err && times > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC)), Glassfy.shared.glqueue, ^{
                [weakSelf permissionsMaxRetries:(times-1) completion:block];
            });
        }
        else {
            GYPermissions *permssions;
            if (!err) {
                permssions = [GYPermissions permissionsWithResponse:res
                                                     installationId:weakSelf.cache.installationId];
            }
            
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

- (void)purchaseHistoryMaxRetries:(NSUInteger)times completion:(GYPurchaseHistoryCompletion)block
{
    typeof(self) __weak weakSelf = self;
    GYGetPurchaseHistoryCompletion apiCompletion = ^(GYAPIPurchaseHistoryResponse *res, NSError *err) {
        if (err && times > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC)), Glassfy.shared.glqueue, ^{
                [weakSelf purchaseHistoryMaxRetries:(times-1) completion:block];
            });
        }
        else {
            GYPurchasesHistory *history;
            if (!err) {
                history = [GYPurchasesHistory purchasesHistoryWithResponse:res];
            }
            
            typeof(block) __strong completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    err ? completion(nil, err) : completion(history, nil);
                });
            }
        }
    };
    
    if (!self.initialized) {
        apiCompletion(nil, GYError.sdkNotInitialized);
        return;
    }
    
    [self.api getPurchaseHistoryWithCompletion:apiCompletion];
}

- (void)setUserProperty:(GYUserPropertyType)property value:(id)obj completion:(GYErrorCompletion)block
{
    [self.api postProperty:property obj:obj completion:^(GYAPIBaseResponse *res, NSError *err) {
        typeof(block) __strong completion = block;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(err);
            });
        }
    }];
}

- (void)setAttributions:(NSArray<GYAttributionItem *>*)attributions maxRetries:(NSUInteger)times completion:(GYErrorCompletion)block
{
    typeof(self) __weak weakSelf = self;
    GYPostAttributionsCompletion apiCompletion = ^(GYAPIBaseResponse *res, NSError *err) {
        if (err && times > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC)), Glassfy.shared.glqueue, ^{
                [weakSelf setAttributions:attributions maxRetries:(times-1) completion:block];
            });
        }
        else {
            typeof(block) __strong completion = block;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(err);
                });
            }
        }
    };
    
    if (!self.initialized) {
        apiCompletion(nil, GYError.sdkNotInitialized);
        return;
    }
    
    [self.api postAttributions:attributions withCompletion:apiCompletion];
}

@end
