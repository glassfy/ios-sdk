//
//  SKPaymentDiscount+Encode.m
//  Glassfy
//
//  Created by Luca Garbolino on 22/12/20.
//

#import "SKPaymentDiscount+GYEncode.h"

@implementation SKPaymentDiscount (GYEncode)

- (id)encodedObject
{
    NSMutableDictionary *discountInfo = [NSMutableDictionary dictionary];
    
    discountInfo[@"identifier"] = self.identifier;
    discountInfo[@"keyidentifier"] = self.keyIdentifier;

    return [NSDictionary dictionaryWithDictionary:discountInfo];
}

@end
