//
//  GYUtils.h
//  Glassfy
//
//  Created by Luca Garbolino on 20/05/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GYUtils : NSObject
+ (NSString *)requestSignature:(NSURLRequest *)req;
@end

NS_ASSUME_NONNULL_END
