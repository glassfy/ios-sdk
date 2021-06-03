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

- (void)purchaseSku:(GYSku *)sku completion:(GYPaymentTransactionBlock)block;
- (void)purchase:(NSString *)productId completion:(GYPaymentTransactionBlock)block;
- (void)purchaseProduct:(SKProduct *)product completion:(GYPaymentTransactionBlock)block;
- (void)purchaseProduct:(SKProduct *)product withDiscount:(SKProductDiscount *_Nullable)discount completion:(GYPaymentTransactionBlock)block API_AVAILABLE(ios(12.2));

- (void)addUserProperty:(GYUserPropertyType)property value:(id)obj completion:(GYUserPropertiesCompletion)block;
- (void)getUserProperties:(GYUserPropertiesCompletion)block;

- (void)restorePurchasesWithCompletion:(GYPermissionsCompletion)block;
@end

NS_ASSUME_NONNULL_END
