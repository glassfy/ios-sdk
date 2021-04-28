//
//  GLPermission.h
//  Glassfy
//
//  Created by Luca Garbolino on 07/01/21.
//

#import <Foundation/Foundation.h>

#if __has_include(<Glassfy/GLTypes.h>)
#import <Glassfy/GLTypes.h>
#else
#import "GLTypes.h"
#endif



NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.Permission)
@interface GLPermission : NSObject
@property(nonatomic, readonly, strong) NSString *permissionIdentifier;
@property(nonatomic, readonly, assign) GLEntitlement entitlement;
@property(nonatomic, readonly, assign) BOOL isValid;
@property(nonatomic, readonly, strong, nullable) NSDate *expireDate;
@end

NS_ASSUME_NONNULL_END
