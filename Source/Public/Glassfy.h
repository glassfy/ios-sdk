//
//  Glassfy.h
//  Glassfy
//
//  Created by Luca Garbolino on 17/12/20.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#if __has_include(<Glassfy/GLTypes.h>)
#import <Glassfy/GLSku.h>
#import <Glassfy/GLOffering.h>
#import <Glassfy/GLTransaction.h>
#import <Glassfy/GLPermission.h>
#import <Glassfy/GLPermissions.h>
#import <Glassfy/GLOfferings.h>

#import <Glassfy/GLTypes.h>
#import <Glassfy/GLError.h>
#else
#import "GLSku.h"
#import "GLOffering.h"
#import "GLTransaction.h"
#import "GLPermission.h"
#import "GLPermissions.h"
#import "GLOfferings.h"

#import "GLTypes.h"
#import "GLError.h"
#endif


////! Project version number for Glassfy.
FOUNDATION_EXPORT double GlassfyVersionNumber;

////! Project version string for Glassfy.
FOUNDATION_EXPORT const unsigned char GlassfyVersionString[];

NS_ASSUME_NONNULL_BEGIN

@interface Glassfy : NSObject

@property(class, nonatomic, strong, readonly) NSString *sdkVersion;

+ (void)initializeWithAPIKey:(NSString *)apiKey NS_SWIFT_NAME(initialize(apiKey:));
+ (void)initializeWithAPIKey:(NSString *)apiKey completion:(GLErrorCompletion _Nullable)block NS_SWIFT_NAME(initialize(apiKey:completion:));
+ (void)initializeWithAPIKey:(NSString *)apiKey userId:(NSString *_Nullable)userId completion:(GLErrorCompletion _Nullable)block NS_SWIFT_NAME(initialize(apiKey:userId:completion:));
+ (void)initializeWithAPIKey:(NSString *)apiKey userId:(NSString *_Nullable)userId watcherMode:(BOOL)watcherMode completion:(GLErrorCompletion _Nullable)block NS_SWIFT_NAME(initialize(apiKey:userId:watcherMode:completion:));

+ (void)setUserId:(NSString *_Nullable)userId;
+ (void)logoutWithCompletion:(GLErrorCompletion _Nullable)block NS_SWIFT_NAME(logout(completion:));

+ (void)permissionsWithCompletion:(GLPermissionsCompletion)block;
+ (void)permissionWithIdentifier:(NSString *)identifier completion:(GLPermissionsCompletion)block NS_SWIFT_NAME(permission(identifier:completion:));

+ (void)offeringsWithCompletion:(GLOfferingsCompletion)block;
+ (void)offeringWithIdentifier:(NSString *)identifier completion:(GLOfferingsCompletion)block NS_SWIFT_NAME(offering(identifier:completion:));

+ (void)purchaseSku:(GLSku *)sku completion:(GLPaymentTransactionBlock)block NS_SWIFT_NAME(purchase(sku:completion:));
+ (void)purchase:(NSString *)productId completion:(GLPaymentTransactionBlock)block NS_SWIFT_NAME(purchase(productId:completion:));
+ (void)purchaseProduct:(SKProduct *)product completion:(GLPaymentTransactionBlock)block NS_SWIFT_NAME(purchase(product:completion:));
+ (void)purchaseProduct:(SKProduct *)product withDiscount:(SKProductDiscount *_Nullable)discount completion:(GLPaymentTransactionBlock)block NS_SWIFT_NAME(purchase(product:discount:completion:)) API_AVAILABLE(ios(12.2));

+ (void)restorePurchasesWithCompletion:(GLPermissionsCompletion)block NS_SWIFT_NAME(restorePurchases(completion:));

+ (void)setLogLevel:(GLLogLevel)level NS_SWIFT_NAME(log(level:));



@end

NS_ASSUME_NONNULL_END
