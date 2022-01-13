//
//  GYUserProperties.h
//  Glassfy
//
//  Created by Luca Garbolino on 28/05/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.UserProperties)
@interface GYUserProperties : NSObject
@property(nullable, nonatomic, readonly) NSString *email;
@property(nullable, nonatomic, readonly) NSString *token;
@property(nullable, nonatomic, readonly) NSDictionary<NSString*,NSString*> *extra;
@end

NS_ASSUME_NONNULL_END
