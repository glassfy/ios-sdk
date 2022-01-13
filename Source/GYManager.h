//
//  GYManager.h
//  Glassfy
//
//  Created by Luca Garbolino on 17/12/20.
//

#import <Foundation/Foundation.h>
#import "GYTypes.h"
@class GYSku;


NS_ASSUME_NONNULL_BEGIN

@interface GYManager : NSObject
@property(nonatomic, readonly, strong, nonnull) NSString *apiKey;
@property(nonatomic, readonly, assign) BOOL watcherMode;

+ (GYManager *)managerWithApiKey:(NSString *)apiKey watcherMode:(BOOL)watcherMode;

- (void)loginUser:(NSString *_Nullable)userId withCompletion:(GYErrorCompletion _Nullable)block;
- (void)logoutWithCompletion:(GYErrorCompletion _Nullable)block;

- (void)permissionsWithCompletion:(GYPermissionsCompletion)block;
- (void)offeringsWithCompletion:(GYOfferingsCompletion)block;
- (void)skuWithIdentifier:(NSString *)skuid completion:(GYSkuBlock)block;

- (void)purchaseSku:(GYSku *)sku completion:(GYPaymentTransactionBlock)block;
- (void)purchaseSku:(GYSku *)sku withDiscount:(SKProductDiscount *_Nullable)discount completion:(GYPaymentTransactionBlock)block API_AVAILABLE(ios(12.2), macos(10.14.4), watchos(6.2));

- (void)setEmailUserProperty:(NSString *)email completion:(GYErrorCompletion)block;
- (void)setDeviceToken:(NSString *)deviceToken completion:(GYErrorCompletion)block;
- (void)setExtraUserProperty:(NSDictionary<NSString*,NSString*> *)extra completion:(GYErrorCompletion)block;

- (void)getUserProperties:(GYUserPropertiesCompletion)block;

- (void)restorePurchasesWithCompletion:(GYPermissionsCompletion)block;
@end

NS_ASSUME_NONNULL_END
