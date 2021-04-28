//
//  SKPayment+Encode.m
//  Glassfy
//
//  Created by Luca Garbolino on 23/12/20.
//

#import "SKPayment+GLEncode.h"
#import "SKPaymentDiscount+GLEncode.h"

@implementation SKPayment (GLEncode)

- (id)encodedObject
{
    NSMutableDictionary *paymentInfo = [NSMutableDictionary dictionary];
    paymentInfo[@"productidentifier"] = self.productIdentifier;
    paymentInfo[@"quantity"] = @(self.quantity);
    paymentInfo[@"applicationusername"] = self.applicationUsername;
    if (@available(iOS 12.2, macOS 10.14.4, watchOS 6.2, *)) {
        paymentInfo[@"paymentdiscount"] = [self.paymentDiscount encodedObject];
    }
    
    return [NSDictionary dictionaryWithDictionary:paymentInfo];
}

@end
