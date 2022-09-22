//
//  Glassfy.h
//  Glassfy
//
//  Created by Luca Garbolino on 17/12/20.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYSku.h>
#import <Glassfy/GYSkuPaddle.h>
#import <Glassfy/GYAccountableSku.h>
#import <Glassfy/GYOffering.h>
#import <Glassfy/GYTransaction.h>
#import <Glassfy/GYPermission.h>
#import <Glassfy/GYPermissions.h>
#import <Glassfy/GYOfferings.h>
#import <Glassfy/GYUserProperties.h>
#import <Glassfy/GYPaywallViewController.h>

#import <Glassfy/GYTypes.h>
#import <Glassfy/GYError.h>
#import <Glassfy/GYPurchaseDelegate.h>
#import <Glassfy/GYStoresInfo.h>
#import <Glassfy/GYStoreInfoPaddle.h>
#else
#import "GYSku.h"
#import "GYSkuPaddle.h"
#import "GYAccountableSku.h"
#import "GYOffering.h"
#import "GYTransaction.h"
#import "GYPermission.h"
#import "GYPermissions.h"
#import "GYOfferings.h"
#import "GYUserProperties.h"
#import "GYPaywallViewController.h"

#import "GYTypes.h"
#import "GYError.h"
#import "GYPurchaseDelegate.h"
#import "GYStoresInfo.h"
#import "GYStoreInfoPaddle.h"
#endif


////! Project version number for Glassfy.
FOUNDATION_EXPORT double GlassfyVersionNumber;

////! Project version string for Glassfy.
FOUNDATION_EXPORT const unsigned char GlassfyVersionString[];

NS_ASSUME_NONNULL_BEGIN

@interface Glassfy : NSObject

/**
 Glassfy SDK version
 */
@property(class, nonatomic, strong, readonly) NSString *sdkVersion;

/**
 Initialize the SDK
 
 @note For more details, follow instruction at https://docs.glassfy.io/get-started/configuration
 
 @param apiKey API Key
 */
+ (void)initializeWithAPIKey:(NSString *)apiKey NS_SWIFT_NAME(initialize(apiKey:));

/**
 Initialize the SDK
 
 @note For more details, follow instruction at https://docs.glassfy.io/get-started/configuration
 
 @param apiKey API Key
 @param watcherMode Take advantage of our charts and stats without change your existing code
 */
+ (void)initializeWithAPIKey:(NSString *)apiKey watcherMode:(BOOL)watcherMode NS_SWIFT_NAME(initialize(apiKey:watcherMode:));

/**
 Chek permissions status of the user
 
 @note For more details, check the documentation https://docs.glassfy.io/dashboard/configure-permissions.html
 
 @param block Completion block with results
 */
+ (void)permissionsWithCompletion:(GYPermissionsCompletion)block;

/**
 Fetch offerings
 
 @note For more details, check the documentation https://docs.glassfy.io/dashboard/configure-offerings
 
 @param block Completion block with results
 */
+ (void)offeringsWithCompletion:(GYOfferingsCompletion)block;

/**
 Fetch sku along with appstore info
 
 @note For more details, check the documentation https://docs.glassfy.io/dashboard/configure-products
  
 @param skuid Sku's identifier
 @param block Completion block with result
 */
+ (void)skuWithId:(NSString *)skuid completion:(GYSkuBlock)block NS_SWIFT_NAME(sku(id:completion:));

/**
 Fetch sku along with store info
 
 @note For more details, check the documentation https://docs.glassfy.io/dashboard/configure-products
  
 @param skuid Sku's identifier
 @param store Store
 @param block Completion block with result.
 */
+ (void)skuWithId:(NSString *)skuid store:(GYStore)store completion:(GYSkuBaseCompletion)block NS_SWIFT_NAME(sku(id:store:completion:));

/**
 Fetch sku along with appstore info
 
 @note For more details, check the documentation https://docs.glassfy.io/dashboard/configure-products
  
 @param productid SKProduct product identifier
 @param promoid Promotional Identifier
 @param block Completion block with result
 */
+ (void)skuWithProductId:(NSString *)productid promotionalId:(NSString *_Nullable)promoid completion:(GYSkuBlock)block NS_SWIFT_NAME(sku(productId:promotionalId:completion:));

/**
 Make a purchase
 
 @param sku The sku that rapresesent the item to buy. To get a reference, @see offeringsWithCompletion:
 @param block Completion block with results
 */
+ (void)purchaseSku:(GYSku *)sku completion:(GYPaymentTransactionBlock)block NS_SWIFT_NAME(purchase(sku:completion:));

/**
 Make a purchase applying a Promotional Offers. Introductory offers are automatically applied to the purchase if user is eligible (new subscriber) while, Promotional Offers can be applied to lapsed/current subscribers

 @note Be sure to load Subscription p8 Key File/ID on https://dashboard.glassfy.io so we that we can sign the purchase on your behalf

 @param sku Reference to the sku to buy. To get a reference call our offering API
 @param discount The discount to apply
 @param block Completion block with results
 */
+ (void)purchaseSku:(GYSku *)sku withDiscount:(SKProductDiscount *_Nullable)discount completion:(GYPaymentTransactionBlock)block NS_SWIFT_NAME(purchase(sku:discount:completion:)) API_AVAILABLE(ios(12.2), macos(10.14.4), watchos(6.2));

/**
 Restore all user's purchases
 
 @note This includes only subscription and non-consumable product
 
 @param block Completion block with results
 */
+ (void)restorePurchasesWithCompletion:(GYPermissionsCompletion)block NS_SWIFT_NAME(restorePurchases(completion:));

/**
 Set log level of the SDK
 */
+ (void)setLogLevel:(GYLogLevel)level NS_SWIFT_NAME(log(level:));

/**
Save push notification device token

@param deviceToken A globally unique token that identifies this device to APNs
@param block Completion block
*/
+ (void)setDeviceToken:(NSString *_Nullable)deviceToken completion:(GYErrorCompletion)block NS_SWIFT_NAME(setDeviceToken(_:completion:));

/**
 Save user email
 
 @param email Email
 @param block Completion block
 */
+ (void)setEmailUserProperty:(NSString *_Nullable)email completion:(GYErrorCompletion)block NS_SWIFT_NAME(setUserProperty(email:completion:));

/**
Save extra user properties

@param extra Addional user properties
@param block Completion block
*/
+ (void)setExtraUserProperty:(NSDictionary<NSString*,NSString*> *_Nullable)extra completion:(GYErrorCompletion)block NS_SWIFT_NAME(setUserProperty(extra:completion:));

/**
 Fetch user properties
 
 @param block Completion block
 */
+ (void)getUserProperties:(GYUserPropertiesCompletion)block NS_SWIFT_NAME(userProperties(completion:));

/**
 Set purchase delegate
 
 @param delegate implementing GYPurchaseDelegate protocol
 */
+ (void)setPurchaseDelegate:(id<GYPurchaseDelegate> _Nullable)delegate;

/**
 Initialize a ViewController to show paywall
 
 @param paywallid Paywall identifier
 @param block Completion block
 */
+ (void)paywallWithId:(NSString *)paywallid completion:(GYPaywallCompletion)block API_UNAVAILABLE(macos, watchos) NS_SWIFT_NAME(paywall(id:completion:));

/**
 Connect paddle license key
 
 @param licenseKey Paddle license key
 @param block Completion block
 @note  Check error code in GYDomain - GYErrorCodeLicenseAlreadyConnected, GYErrorCodeLicenseNotFound to handle those cases
 */
+ (void)connectPaddleLicenseKey:(NSString *)licenseKey completion:(GYErrorCompletion)block NS_SWIFT_NAME(connectPaddle(licenseKey:completion:));

/**
 Connect paddle license key
 
 @param licenseKey Paddle license key
 @param force Disconnect license from other subscriber(s) and connect with current subscriber
 @param block Completion block
 @note  Check error code in GYDomain - GYErrorCodeLicenseAlreadyConnected, GYErrorCodeLicenseInvalid to handle those cases
 */
+ (void)connectPaddleLicenseKey:(NSString *)licenseKey force:(BOOL)force completion:(GYErrorCompletion)block NS_SWIFT_NAME(connectPaddle(licenseKey:force:completion:));

/**
 Connect custom subscriber
 
 @param customId Custom subscriber id
 @param block Completion block
 */
+ (void)connectCustomSubscriber:(NSString *_Nullable)customId completion:(GYErrorCompletion)block NS_SWIFT_NAME(connectCustomSubscriber(_:completion:));

/**
 Info about user connected stores
 
 @param block Completion block
 */
+ (void)storeInfo:(GYStoreCompletion)block NS_SWIFT_NAME(storeInfo(completion:));


/// Deprecations

/**
@warning Deprecated in favour of `+skuWithId:completion:`
*/
+ (void)skuWithIdentifier:(NSString *)skuid completion:(GYSkuBlock)block NS_SWIFT_NAME(sku(identifier:completion:)) __attribute__((deprecated("Renamed to +skuWithId:completion:")));

/**
 @warning Deprecated in favour of `+connectCustomSubscriber:completion:`
 */
+ (void)loginUser:(NSString *_Nullable)userId withCompletion:(GYErrorCompletion _Nullable)block NS_SWIFT_NAME(login(user:completion:)) __attribute__((deprecated()));

/**
 @warning Deprecated in favour of `+connectCustomSubscriber:completion:`
 */
+ (void)logoutWithCompletion:(GYErrorCompletion _Nullable)block NS_SWIFT_NAME(logout(completion:)) __attribute__((deprecated()));
@end

NS_ASSUME_NONNULL_END
