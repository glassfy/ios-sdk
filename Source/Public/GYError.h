//
//  GYError.h
//  Glassfy
//
//  Created by Luca Garbolino on 21/04/2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const GYErrorDomain;

typedef NS_ERROR_ENUM(GYErrorDomain, GYErrorCode) {
    GYErrorCodeSDKNotInitialized,
    GYErrorCodeInvalidPurchase,
    GYErrorCodePurchaseInProgress,
    GYErrorCodeMissingReceipt,
    GYErrorCodeEncode,
    GYErrorCodeDeferredPurchase,
    GYErrorCodeStoreProductNotFound,
    GYErrorCodeSizeLimit,
    GYErrorCodeWrongParameterType,
    GYErrorCodeAPINotSupported,
    GYErrorCodeInvalidAPIToken          = 1000,
    GYErrorCodeSubscriberIDNotFound     = 1001,
    GYErrorCodeInstallationIDNotFound   = 1002,
    GYErrorCodeStoreTypeNotFound        = 1003,
    GYErrorCodeWrongStoreType           = 1004,
    GYErrorCodeGenericError             = 1005,
    GYErrorCodeInvalidAppID             = 1006,
    GYErrorCodeUnauthorized             = 1007,
    GYErrorCodeSkuIDNotFound            = 1008,
    GYErrorCodeAppIDNotFound            = 1009,
    GYErrorCodeInvalidParameter         = 1010,
    GYErrorCodeAppleReceiptStatusError  = 1011,
    GYErrorCodeInvalidFieldValueError   = 1012,
    GYErrorCodeInvalidFieldNameError    = 1013,
    GYErrorCodeLicenseAlreadyConnected  = 1050,
    GYErrorCodeLicenseNotFound          = 1051,
    GYErrorCodeUnknow                   = -1
} NS_SWIFT_NAME(Glassfy.ErrorCode);

NS_SWIFT_NAME(Glassfy.Error)
@interface GYError : NSObject

@property(class, readonly) NSError *sdkNotInitialized;
@property(class, readonly) NSError *invalidPurchase;    //ToDo unused
@property(class, readonly) NSError *missingReceipt;
@property(class, readonly) NSError *encodeData;
@property(class, readonly) NSError *purchaseInProgress;
@property(class, readonly) NSError *deferredPurchase;
@property(class, readonly) NSError *storeProductNotFound;
@property(class, readonly) NSError *exceedSizeLimits;
@property(class, readonly) NSError *wrongParameterType;
@property(class, readonly) NSError *notSupported;

+ (NSError *)serverError:(GYErrorCode)code description:(nullable NSString *)description;
@end

NS_ASSUME_NONNULL_END
