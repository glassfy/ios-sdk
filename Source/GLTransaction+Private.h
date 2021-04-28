//
//  GLTransaction.h
//  Glassfy
//
//  Created by Luca Garbolino on 24/12/20.
//

#import "GLTransaction.h"


NS_ASSUME_NONNULL_BEGIN

@interface GLTransaction (Private)
@property(nonatomic, assign) BOOL receiptValidated;
@property(nonatomic, strong) NSArray<GLPermission*> *permissions;

+ (instancetype)transactionWithPaymentTransaction:(SKPaymentTransaction*)transaction;
@end

NS_ASSUME_NONNULL_END
