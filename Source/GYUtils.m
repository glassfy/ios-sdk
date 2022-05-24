//
//  GYUtils.m
//  Glassfy
//
//  Created by Luca Garbolino on 20/05/21.
//

#import <CommonCrypto/CommonDigest.h>
#import "GYUtils.h"

@implementation GYUtils

+ (NSString *)requestSignature:(NSURLRequest *)req
{
    CC_SHA1_CTX ctx;
    CC_SHA1_Init(&ctx);
    const char *data;
    NSUInteger len;
    
    // SHA1 url
    data = req.URL.absoluteString.UTF8String;
    len = [req.URL.absoluteString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    CC_SHA1_Update(&ctx, data, (CC_LONG) (len > UINT32_MAX ? UINT32_MAX : len));
    
    // SHA1 body
    data = req.HTTPBody.bytes;
    len = req.HTTPBody.length;
    if (len > 0) {
        CC_SHA1_Update(&ctx, data, (CC_LONG) (len > UINT32_MAX ? UINT32_MAX : len));
    }
    
    // Calculate
    unsigned char md[CC_SHA1_DIGEST_LENGTH];
    if (CC_SHA1_Final(md, &ctx)) {
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        for (unsigned int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", md[i]];
            md[i] = 0;
        }
        return output;
    }
    return @"";
}

@end
