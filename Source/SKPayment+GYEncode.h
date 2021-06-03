//
//  SKPayment+Encode.h
//  Glassfy
//
//  Created by Luca Garbolino on 23/12/20.
//

#import <StoreKit/StoreKit.h>
#import "GYCodableProtocol.h"


@interface SKPayment (GYEncode) <GYEncodeProtocol>
@end
