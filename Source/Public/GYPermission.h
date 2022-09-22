//
//  GYPermission.h
//  Glassfy
//
//  Created by Luca Garbolino on 07/01/21.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYTypes.h>
#else
#import "GYTypes.h"
#endif

@class GYAccountableSku;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.Permission)
@interface GYPermission : NSObject
@property(nonatomic, readonly, strong) NSString *permissionId;
@property(nonatomic, readonly, assign) GYEntitlement entitlement;
@property(nonatomic, readonly, assign) BOOL isValid;
@property(nonatomic, readonly, strong, nullable) NSDate *expireDate;
@property(nonatomic, readonly, strong) NSSet<GYAccountableSku*> *accountableSkus;


/// Deprecations
@property(nonatomic, readonly) NSString *permissionIdentifier __attribute__((deprecated("Renamed to permissionId")));
@end

NS_ASSUME_NONNULL_END
