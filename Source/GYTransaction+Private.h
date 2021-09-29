//
//  GYTransaction.h
//  Glassfy
//
//  Created by Luca Garbolino on 24/12/20.
//

#import "GYTransaction.h"
@class GYPermissions;

NS_ASSUME_NONNULL_BEGIN

@interface GYTransaction (Private)
@property(nonatomic, assign) BOOL receiptValidated;
@property(nonatomic, strong) GYPermissions *permissions;

+ (instancetype)transactionWithPaymentTransaction:(SKPaymentTransaction*)transaction;
@end

NS_ASSUME_NONNULL_END
