//
//  GYError.m
//  Glassfy
//
//  Created by Luca Garbolino on 21/04/2020.
//

#import "GYError.h"

NSErrorDomain const GYErrorDomain = @"GYErrorDomain";

@implementation GYError

+ (NSError *)sdkNotInitialized
{
    return [NSError errorWithDomain:GYErrorDomain code:GYErrorCodeSDKNotInitialized userInfo:@{NSLocalizedDescriptionKey:@"SDK not initialized."}];
}

+ (NSError *)invalidPurchase
{
    return [NSError errorWithDomain:GYErrorDomain code:GYErrorCodeInvalidPurchase userInfo:@{NSLocalizedDescriptionKey:@"Invalid purchase: product id not on a purchases array"}];
}

+ (NSError *)purchaseInProgress
{
    return [NSError errorWithDomain:GYErrorDomain code:GYErrorCodePurchaseInProgress userInfo:@{NSLocalizedDescriptionKey:@"Purchase already in progress..."}];
}

+ (NSError *)missingReceipt
{
    return [NSError errorWithDomain:GYErrorDomain code:GYErrorCodeMissingReceipt userInfo:@{NSLocalizedDescriptionKey:@"Missing receipt"}];
}

+ (NSError *)encodeData
{
    return [NSError errorWithDomain:GYErrorDomain code:GYErrorCodeEncode userInfo:@{NSLocalizedDescriptionKey:@"Error encoding data"}];
}

+ (NSError *)exceedSizeLimits
{
    return [NSError errorWithDomain:GYErrorDomain code:GYErrorCodeSizeLimit userInfo:@{NSLocalizedDescriptionKey:@"Size Limit Exceeded"}];
}

+ (NSError *)deferredPurchase
{
    return [NSError errorWithDomain:GYErrorDomain code:GYErrorCodeDeferredPurchase userInfo:@{NSLocalizedDescriptionKey:@"User defer Purchase"}];
}

+ (NSError *)storeProductNotFound
{
    return [NSError errorWithDomain:GYErrorDomain code:GYErrorCodeStoreProductNotFound userInfo:@{NSLocalizedDescriptionKey:@"Store does not return the SKProduct"}];
}

+ (NSError *)wrongParameterType
{
    return [NSError errorWithDomain:GYErrorDomain code:GYErrorCodeWrongParameterType userInfo:@{NSLocalizedDescriptionKey:@"Wrong parameter type"}];
}

+ (NSError *)serverError:(GYErrorCode)code description:(nullable NSString *)description
{
    return [NSError errorWithDomain:GYErrorDomain code:code userInfo:description ? @{NSLocalizedDescriptionKey:description} : nil];
}

+ (NSError *)notSupported
{
    return [NSError errorWithDomain:GYErrorDomain code:GYErrorCodeAPINotSupported userInfo:@{NSLocalizedDescriptionKey:@"API not supported on this platform"}];
}

@end
