//
//  GLError.m
//  Glassfy
//
//  Created by Luca Garbolino on 21/04/2020.
//

#import "GLError.h"

NSErrorDomain const GLErrorDomain = @"GLErrorDomain";

@implementation GLError

+ (NSError *)invalidPurchase
{
    return [NSError errorWithDomain:GLErrorDomain code:GLErrorCodeInvalidPurchase userInfo:@{NSLocalizedDescriptionKey:@"Invalid purchase: product id not on a purchases array"}];
}

+ (NSError *)purchaseInProgress
{
    return [NSError errorWithDomain:GLErrorDomain code:GLErrorCodePurchaseInProgress userInfo:@{NSLocalizedDescriptionKey:@"Purchase already in progress..."}];
}

+ (NSError *)missingReceipt
{
    return [NSError errorWithDomain:GLErrorDomain code:GLErrorCodeMissingReceipt userInfo:@{NSLocalizedDescriptionKey:@"Missing receipt"}];
}

+ (NSError *)encodeData
{
    return [NSError errorWithDomain:GLErrorDomain code:GLErrorCodeEncode userInfo:@{NSLocalizedDescriptionKey:@"Error encoding data"}];
}

+ (NSError *)deferredPurchase
{
    return [NSError errorWithDomain:GLErrorDomain code:GLErrorCodeDeferredPurchase userInfo:@{NSLocalizedDescriptionKey:@"User defer Purchase"}];
}

+ (NSError *)storeProductNotFound
{
    return [NSError errorWithDomain:GLErrorDomain code:GLErrorCodeStoreProductNotFound userInfo:@{NSLocalizedDescriptionKey:@"Store does not return the SKProduct"}];
}

+ (NSError *)serverError:(GLErrorCode)code description:(nullable NSString *)description
{
    return [NSError errorWithDomain:GLErrorDomain code:code userInfo:description ? @{NSLocalizedDescriptionKey:description} : nil];
}

@end
