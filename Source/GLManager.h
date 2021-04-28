//
//  GLManager.h
//  Glassfy
//
//  Created by Luca Garbolino on 17/12/20.
//

#import <Foundation/Foundation.h>
#import "GLTypes.h"
@class GLSku;


NS_ASSUME_NONNULL_BEGIN

@interface GLManager : NSObject
@property(nonatomic, readonly, strong, nonnull) NSString *apiKey;
@property(nonatomic, readonly, strong, nullable) NSString *userId;
@property(nonatomic, readonly, assign) BOOL watcherMode;

+ (GLManager *)managerWithApiKey:(NSString *)apiKey userId:(NSString *_Nullable)userId watcherMode:(BOOL)watcherMode completion:(GLErrorCompletion _Nullable)block;

- (void)setUserId:(NSString *_Nullable)userId;
- (void)logoutWithCompletion:(GLErrorCompletion _Nullable)block;

- (void)permissionsWithCompletion:(GLPermissionsCompletion)block;
- (void)permissionWithIdentifier:(NSString *)identifier completion:(GLPermissionsCompletion)block;

- (void)offeringsWithCompletion:(GLOfferingsCompletion)block;
- (void)offeringWithIdentifier:(NSString *)identifier completion:(GLOfferingsCompletion)block;

- (void)purchaseSku:(GLSku *)sku completion:(GLPaymentTransactionBlock)block;
- (void)purchase:(NSString *)productId completion:(GLPaymentTransactionBlock)block;
- (void)purchaseProduct:(SKProduct *)product completion:(GLPaymentTransactionBlock)block;
- (void)purchaseProduct:(SKProduct *)product withDiscount:(SKProductDiscount *_Nullable)discount completion:(GLPaymentTransactionBlock)block API_AVAILABLE(ios(12.2));

- (void)restorePurchasesWithCompletion:(GLPermissionsCompletion)block;
@end

NS_ASSUME_NONNULL_END
