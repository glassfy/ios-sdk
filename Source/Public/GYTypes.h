//
//  GYTypes.h
//  Glassfy
//
//  Created by Luca Garbolino on 21/12/20.
//

#ifndef Types_h
#define Types_h

#import <Foundation/Foundation.h>
@class SKPaymentTransaction;
@class GYTransaction;
@class GYPermissions;
@class GYOfferings;
@class GYUserProperties;
@class GYStoresInfo;
@class GYSku;
@class GYSkuBase;
@class GYPaywallViewController;

NS_ASSUME_NONNULL_BEGIN

typedef void(^GYSkuBlock)(GYSku* _Nullable, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.SkuBlock);
typedef void(^GYSkuBaseCompletion)(GYSkuBase* _Nullable, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.SkuBaseCompletion);
typedef void(^GYPaymentTransactionBlock)(GYTransaction* _Nullable, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.PaymentTransactionBlock);
typedef void(^GYOfferingsCompletion)(GYOfferings* _Nullable, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.OfferingsCompletion);
typedef void(^GYPermissionsCompletion)(GYPermissions* _Nullable, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.PermissionsCompletion);
typedef void(^GYBooleanCompletion)(BOOL, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.BooleanCompletion);
typedef void(^GYErrorCompletion)(NSError* _Nullable) NS_SWIFT_NAME(Glassfy.ErrorCompletion);
typedef void(^GYUserPropertiesCompletion)(GYUserProperties* _Nullable, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.UserPropertiesCompletion);
typedef void(^GYStoreCompletion)(GYStoresInfo* _Nullable, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.StoreCompletion);
typedef void(^GYPaywallCompletion)(GYPaywallViewController* _Nullable, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.PaywallCompletion);
typedef void(^GYPaywallCloseBlock)(GYTransaction* _Nullable, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.PaywallCloseBlock);
typedef void(^GYPaywallLinkBlock)(NSURL*) NS_SWIFT_NAME(Glassfy.PaywallLinkBlock);
typedef void(^GYPaywallPurchaseBlock)(GYSku*) NS_SWIFT_NAME(Glassfy.PaywallPurchaseBlock);
typedef void(^GYPaywallRestoreBlock)(void) NS_SWIFT_NAME(Glassfy.PaywallRestoreBlock);


typedef NS_ENUM(NSInteger, GYSkuEligibility) {
    GYSkuEligibilityEligible = 1,
    GYSkuEligibilityNonEligible = -1,
    GYSkuEligibilityUnknown = 0
} NS_SWIFT_NAME(Glassfy.SkuEligibility);

typedef NS_ENUM(NSInteger, GYEntitlement) {
    // The customer never bought any products.
    GYEntitlementNeverBuy = -9,
    // The customer received a refund for the subscription.
    GYEntitlementOtherRefund = -8,
    // The customer received a refund due to a perceived issue with the app.
    GYEntitlementIssueRefund = -7,
    // The system canceled the subscription because the customer upgraded.
    GYEntitlementUpgraded = -6,
    // The customer intentionally cancelled the subscription.
    GYEntitlementExpiredVoluntary = -5,
    // The product is no longer available.
    GYEntitlementProductNotAvailable = -4,
    // The customer did not accept the price increase.
    GYEntitlementFailToAcceptIncrease = -3,
    // The receipt is fully expired due to a billing issue.
    GYEntitlementExpiredFromBilling = -2,
    // The receipt is expired but the subscription is still in a billing-retry state.
    // If grace period is enabled this state excludes subscriptions in grace period.
    GYEntitlementInRetry = -1,
    // The receipt is out of date or there is another purchase issue.
    GYEntitlementMissingInfo = 0,
    // The subscription expired but is in grace period.
    GYEntitlementExpiredInGrace = 1,
    // The subscription is an off-platform subscription.
    GYEntitlementOffPlatform = 2,
    // The subscription is a non-renewing subscription.
    GYEntitlementNonRenewing = 3,
    // The subscription is active and auto-renew is off.
    GYEntitlementAutoRenewOff = 4,
    // The subscription is active and auto-renew is on.
    GYEntitlementAutoRenewOn = 5,
} NS_SWIFT_NAME(Glassfy.Entitlement);

typedef NS_OPTIONS(NSUInteger, GYLogFlag) {
    GYLogFlagError = 1 << 0,
    GYLogFlagDebug = 1 << 1,
    GYLogFlagInfo = 1 << 2
} NS_SWIFT_NAME(Glassfy.LogFlag);

typedef NS_ENUM(NSUInteger, GYLogLevel) {
    GYLogLevelOff   = 0,
    GYLogLevelError = (GYLogLevelOff | GYLogFlagError),
    GYLogLevelDebug = (GYLogLevelError | GYLogFlagDebug),
    GYLogLevelInfo  = (GYLogLevelDebug | GYLogFlagInfo),
    GYLogLevelAll   = NSUIntegerMax
} NS_SWIFT_NAME(Glassfy.LogLevel);

typedef NS_ENUM(NSUInteger, GYStore) {
    GYStoreAppStore = 1,
    GYStorePlayStore = 2,
    GYStorePaddle = 3
} NS_SWIFT_NAME(Glassfy.Store);

NS_ASSUME_NONNULL_END

#endif /* Types_h */
