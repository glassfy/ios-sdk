//
//  SKPaymentTransaction+Encode.m
//  Glassfy
//
//  Created by Luca Garbolino on 22/12/20.
//

#import "SKPaymentTransaction+GLEncode.h"
#import "SKPaymentDiscount+GLEncode.h"
#import "SKPayment+GLEncode.h"

@implementation SKPaymentTransaction (GLEncode)

- (id)encodedObject
{
    NSMutableDictionary *transactionInfo = [NSMutableDictionary dictionary];
    
    transactionInfo[@"payment"] = [self.payment encodedObject];
    transactionInfo[@"transactiondate"] = @(self.transactionDate.timeIntervalSince1970);
    transactionInfo[@"transactionidentifier"] = self.transactionIdentifier;
    
    return [NSDictionary dictionaryWithDictionary:transactionInfo];
}

@end
