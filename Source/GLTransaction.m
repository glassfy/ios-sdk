//
//  GLTransaction.m
//  Glassfy
//
//  Created by Luca Garbolino on 24/12/20.
//

#import <StoreKit/StoreKit.h>
#import "GLTransaction.h"
#import "GLTransaction+Private.h"


@interface GLTransaction()
@property(nonatomic, readwrite, strong) SKPaymentTransaction *paymentTransaction;
@property(nonatomic, readwrite, strong) NSArray<GLPermission*> *permissions;
@property(nonatomic, assign) BOOL receiptValidated;
@end

@implementation GLTransaction (Private)

+ (instancetype)transactionWithPaymentTransaction:(SKPaymentTransaction*)t
{
    GLTransaction *transaction = [[self alloc] init];
    transaction.paymentTransaction = t;
    transaction.permissions = @[];
    
    return transaction;
}

@end

@implementation GLTransaction

- (NSString *)productIdentifier
{
    return self.paymentTransaction.payment.productIdentifier;
}

@end
