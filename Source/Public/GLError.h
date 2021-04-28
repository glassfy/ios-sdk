//
//  GLError.h
//  Glassfy
//
//  Created by Luca Garbolino on 21/04/2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const GLErrorDomain;

typedef NS_ERROR_ENUM(GLErrorDomain, GLErrorCode) {
    GLErrorCodeInvalidPurchase,
    GLErrorCodePurchaseInProgress,
    GLErrorCodeMissingReceipt,
    GLErrorCodeEncode,
    GLErrorCodeDeferredPurchase,
    GLErrorCodeStoreProductNotFound,
    GLErrorCodeInvalidAPIToken          = 1000,
    GLErrorCodeSubscriberIDNotFound     = 1001,
    GLErrorCodeInstallationIDNotFound   = 1002,
    GLErrorCodeStoreTypeNotFound        = 1003,
    GLErrorCodeWrongStoreType           = 1004,
    GLErrorCodeGenericError             = 1005,
    GLErrorCodeInvalidAppID             = 1006,
    GLErrorCodeUnauthorized             = 1007,
    GLErrorCodeSkuIDNotFound            = 1008,
    GLErrorCodeAppIDNotFound            = 1009,
    GLErrorCodeInvalidParameter         = 1010,
    GLErrorCodeAppleReceiptStatusError  = 1011,
    GLErrorCodeInvalidFieldValueError   = 1012,
    GLErrorCodeInvalidFieldNameError    = 1013,
    GLErrorCodeUnknow                   = -1
} NS_SWIFT_NAME(Glassfy.ErrorCode);

NS_SWIFT_NAME(Glassfy.Error)
@interface GLError : NSObject

@property(class, readonly) NSError *invalidPurchase;    //ToDo unused
@property(class, readonly) NSError *missingReceipt;
@property(class, readonly) NSError *encodeData;
@property(class, readonly) NSError *purchaseInProgress;
@property(class, readonly) NSError *deferredPurchase;
@property(class, readonly) NSError *storeProductNotFound;

+ (NSError *)serverError:(GLErrorCode)code description:(nullable NSString *)description;
@end

NS_ASSUME_NONNULL_END
