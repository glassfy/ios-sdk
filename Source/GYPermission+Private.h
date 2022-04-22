//
//  GYTransaction.h
//  Glassfy
//
//  Created by Luca Garbolino on 24/12/20.
//

#import "GYPermission.h"


NS_ASSUME_NONNULL_BEGIN

@interface GYPermission (Private)
+ (instancetype)permissionWithIdentifier:(NSString *)identifier
                             entitlement:(GYEntitlement)entitlement
                                  expire:(nullable NSDate *)date
                         accountableSkus:(NSSet<GYSkuBase*> *)accountableSkus;
@end

NS_ASSUME_NONNULL_END
