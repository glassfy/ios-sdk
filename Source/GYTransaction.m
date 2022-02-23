//
//  GYTransaction.m
//  Glassfy
//
//  Created by Luca Garbolino on 24/12/20.
//

#import <StoreKit/StoreKit.h>
#import "GYPermissions+Private.h"
#import "GYTransaction.h"
#import "GYTransaction+Private.h"


@interface GYTransaction()
@property(nonatomic, readwrite, strong) SKPaymentTransaction *paymentTransaction;
@property(nonatomic, readwrite, strong) GYPermissions *permissions;
@property(nonatomic, assign) BOOL receiptValidated;
@end

@implementation GYTransaction (Private)

+ (instancetype)transactionWithPaymentTransaction:(SKPaymentTransaction*)t
{
    GYTransaction *transaction = [[self alloc] init];
    transaction.paymentTransaction = t;
    transaction.permissions = [GYPermissions new];
    
    return transaction;
}

@end

@implementation GYTransaction

- (NSString *)productId
{
    return self.paymentTransaction.payment.productIdentifier;
}

- (NSString *)promotionalId
{
    return self.paymentTransaction.payment.paymentDiscount.identifier;
}


#pragma mark - Deprecations

- (NSString *)productIdentifier
{
    return self.productId;
}

@end
