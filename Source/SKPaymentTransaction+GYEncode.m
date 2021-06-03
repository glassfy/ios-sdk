//
//  SKPaymentTransaction+Encode.m
//  Glassfy
//
//  Created by Luca Garbolino on 22/12/20.
//

#import "SKPaymentTransaction+GYEncode.h"
#import "SKPaymentDiscount+GYEncode.h"
#import "SKPayment+GYEncode.h"

@implementation SKPaymentTransaction (GYEncode)

- (id)encodedObject
{
    NSMutableDictionary *transactionInfo = [NSMutableDictionary dictionary];
    
    transactionInfo[@"payment"] = [self.payment encodedObject];
    transactionInfo[@"transactiondate"] = @(self.transactionDate.timeIntervalSince1970);
    transactionInfo[@"transactionidentifier"] = self.transactionIdentifier;
    
    return [NSDictionary dictionaryWithDictionary:transactionInfo];
}

@end
