//
//  GYManager.h
//  Glassfy
//
//  Created by Luca Garbolino on 17/12/20.
//

#import <Foundation/Foundation.h>
#import "GYTypes.h"
#import "GYPurchaseDelegate.h"
@class GYSku;
@class GYAttributionItem;
@class GYInitializeOptions;

NS_ASSUME_NONNULL_BEGIN

@interface GYManager : NSObject
@property(nonatomic, readonly, strong, nonnull) NSString *apiKey;
@property(nonatomic, readonly, assign) BOOL watcherMode;

+ (GYManager *)managerWithOptions:(GYInitializeOptions *)options;

- (void)setPurchaseDelegate:(id<GYPurchaseDelegate>)delegate;

- (void)loginUser:(NSString *_Nullable)userId
   withCompletion:(GYErrorCompletion _Nullable)block;

- (void)logoutWithCompletion:(GYErrorCompletion _Nullable)block;

- (void)permissionsWithCompletion:(GYPermissionsCompletion)block;

- (void)offeringsWithCompletion:(GYOfferingsCompletion)block;

- (void)skuWithId:(NSString *)skuid completion:(GYSkuBlock)block;

- (void)skuWithId:(NSString *)skuId store:(GYStore)store completion:(GYSkuBaseCompletion)block;

- (void)skuWithProductId:(NSString *)productid
           promotionalId:(NSString *_Nullable)promoid
              completion:(GYSkuBlock)block;

- (void)purchaseSku:(GYSku *)sku completion:(GYPaymentTransactionBlock)block;

- (void)purchaseSku:(GYSku *)sku
       withDiscount:(SKProductDiscount *_Nullable)discount
         completion:(GYPaymentTransactionBlock)block
API_AVAILABLE(ios(12.2), macos(10.14.4), watchos(6.2));

- (void)setEmailUserProperty:(NSString *)email completion:(GYErrorCompletion)block;

- (void)setDeviceToken:(NSString *)deviceToken completion:(GYErrorCompletion)block;

- (void)setExtraUserProperty:(NSDictionary<NSString*,NSString*> *)extra
                  completion:(GYErrorCompletion)block;

- (void)getUserProperties:(GYUserPropertiesCompletion)block;

- (void)connectPaddleLicenseKey:(NSString *)licenseKey
                          force:(BOOL)force
                     completion:(GYErrorCompletion)block;

- (void)connectGlassfyUniversalCode:(NSString*)universalCode
                              force:(BOOL)force
                     withCompletion:(GYErrorCompletion)block;

- (void)connectCustomSubscriber:(NSString *_Nullable)customId
                     completion:(GYErrorCompletion)block;

- (void)paywallWithRemoteConfigurationId:(NSString *)remoteConfigId
                              completion:(GYPaywallCompletion)block
API_UNAVAILABLE(macos, watchos);

- (void)paywallViewControllerWithRemoteConfigurationId:(NSString *)remoteConfigId
                                          awaitLoading:(BOOL)awaitLoading
                                            completion:(GYPaywallViewControllerCompletion)block
API_UNAVAILABLE(macos, watchos);

- (void)restorePurchasesWithCompletion:(GYPermissionsCompletion)block;

- (void)storeInfo:(GYStoreCompletion)block;

- (void)setAttributionWithType:(GYAttributionType)type
                         value:(NSString *_Nullable)value
                    completion:(GYErrorCompletion)block;

- (void)setAttributions:(NSArray<GYAttributionItem*> *)attributions
             completion:(GYErrorCompletion)block;

- (void)purchaseHistoryWithCompletion:(GYPurchaseHistoryCompletion)block;

@end

NS_ASSUME_NONNULL_END
