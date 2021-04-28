//
//  GLTypes.h
//  Glassfy
//
//  Created by Luca Garbolino on 21/12/20.
//

#ifndef Types_h
#define Types_h

#import <Foundation/Foundation.h>
@class SKPaymentTransaction;
@class GLTransaction;
@class GLPermissions;
@class GLOfferings;

NS_ASSUME_NONNULL_BEGIN

typedef void(^GLPaymentTransactionBlock)(GLTransaction* _Nullable, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.PaymentTransactionBlock);
typedef void(^GLOfferingsCompletion)(GLOfferings* _Nullable, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.OfferingsCompletion);
typedef void(^GLPermissionsCompletion)(GLPermissions* _Nullable, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.PermissionsCompletion);
typedef void(^GLBooleanCompletion)(BOOL, NSError* _Nullable) NS_SWIFT_NAME(Glassfy.BooleanCompletion);
typedef void(^GLErrorCompletion)(NSError* _Nullable) NS_SWIFT_NAME(Glassfy.ErrorCompletion);

typedef NS_ENUM(NSInteger, GLEntitlement) {
    // The customer received a refund for the subscription.
    GLEntitlementOtherRefund = -8,
    // The customer received a refund due to a perceived issue with the app.
    GLEntitlementIssueRefund = -7,
    // The system canceled the subscription because the customer upgraded.
    GLEntitlementUpgraded = -6,
    // The customer intentionally cancelled the subscription.
    GLEntitlementExpiredVoloutary = -5,
    // The product is no longer available.
    GLEntitlementProductNotAvailable = -4,
    // The customer did not accept the price increase.
    GLEntitlementFailToAcceptIncrase = -3,
    // The receipt is fully expired due to a billing issue.
    GLEntitlementExpiredFromBilling = -2,
    // The receipt is expired but the subscription is still in a billing-retry state.
    // If grace period is enabled this state excludes subscriptions in grace period.
    GLEntitlementInRetry = -1,
    // The receipt is out of date or there is another purchase issue.
    GLEntitlementMissingInfo = 0,
    // The subscription expired but is in grace period.
    GLEntitlementExpiredInGrace = 1,
    // The subscription is an off-platform subscription.
    GLEntitlementOffPlatform = 2,
    // The subscription is a non-renewing subscription.
    GLEntitlementNonRenewing = 3,
    // The subscription is active and auto-renew is off.
    GLEntitlementAutoRenewOff = 4,
    // The subscription is active and auto-renew is on.
    GLEntitlementAutoRenewOn = 5,
} NS_SWIFT_NAME(Glassfy.Entitlement);

typedef NS_OPTIONS(NSUInteger, GLLogFlag) {
    GLLogFlagError = 1 << 0,
    GLLogFlagDebug = 1 << 1,
    GLLogFlagInfo = 1 << 2
} NS_SWIFT_NAME(Glassfy.LogFlag);

typedef NS_ENUM(NSUInteger, GLLogLevel) {
    GLLogLevelOff   = 0,
    GLLogLevelError = (GLLogLevelOff | GLLogFlagError),
    GLLogLevelDebug = (GLLogLevelError | GLLogFlagDebug),
    GLLogLevelInfo  = (GLLogLevelDebug | GLLogFlagInfo),
    GLLogLevelAll   = NSUIntegerMax
} NS_SWIFT_NAME(Glassfy.LogLevel);

NS_ASSUME_NONNULL_END

#endif /* Types_h */
