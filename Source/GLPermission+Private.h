//
//  GLTransaction.h
//  Glassfy
//
//  Created by Luca Garbolino on 24/12/20.
//

#import "GLPermission.h"


NS_ASSUME_NONNULL_BEGIN

@interface GLPermission (Private)
+ (instancetype)permissionWithIdentifier:(NSString *)identifier entitlement:(GLEntitlement)entitlement expire:(nullable NSDate *)date;
@end

NS_ASSUME_NONNULL_END
