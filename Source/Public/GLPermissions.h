//
//  GLPermissions.h
//  Glassfy
//
//  Created by Luca Garbolino on 22/02/21.
//

#import <Foundation/Foundation.h>
@class GLPermission;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.Permissions)
@interface GLPermissions : NSObject
@property(nonatomic, readonly) NSArray<GLPermission *> *all;
@property(nullable, nonatomic, readonly) NSString *originalApplicationVersion;
@property(nullable, nonatomic, readonly) NSDate *originalApplicationDate;
@end

NS_ASSUME_NONNULL_END
