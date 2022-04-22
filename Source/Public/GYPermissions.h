//
//  GYPermissions.h
//  Glassfy
//
//  Created by Luca Garbolino on 22/02/21.
//

#import <Foundation/Foundation.h>
@class GYPermission;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.Permissions)
@interface GYPermissions : NSObject
@property(nonatomic, readonly) NSArray<GYPermission*> *all;

@property(nullable, nonatomic, readonly) NSString *originalApplicationVersion;
@property(nullable, nonatomic, readonly) NSDate *originalApplicationDate;

@property(nullable, nonatomic, readonly) NSString *subscriberId;
@property(nullable, nonatomic, readonly) NSString *installationId;

// Custom Keyed Subscripting method
- (nullable GYPermission *)objectForKeyedSubscript:(NSString *)permissionid;
@end

NS_ASSUME_NONNULL_END
