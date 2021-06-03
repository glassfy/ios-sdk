//
//  GYTransaction.m
//  Glassfy
//
//  Created by Luca Garbolino on 24/12/20.
//

#import <StoreKit/StoreKit.h>
#import "GYTransaction.h"
#import "GYTransaction+Private.h"


@interface GYTransaction()
@property(nonatomic, readwrite, strong) SKPaymentTransaction *paymentTransaction;
@property(nonatomic, readwrite, strong) NSArray<GYPermission*> *permissions;
@property(nonatomic, assign) BOOL receiptValidated;
@end

@implementation GYTransaction (Private)

+ (instancetype)transactionWithPaymentTransaction:(SKPaymentTransaction*)t
{
    GYTransaction *transaction = [[self alloc] init];
    transaction.paymentTransaction = t;
    transaction.permissions = @[];
    
    return transaction;
}

@end

@implementation GYTransaction

- (NSString *)productIdentifier
{
    return self.paymentTransaction.payment.productIdentifier;
}

@end
