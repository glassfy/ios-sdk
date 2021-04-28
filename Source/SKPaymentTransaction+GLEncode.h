//
//  SKPaymentTransaction+Encode.h
//  Glassfy
//
//  Created by Luca Garbolino on 22/12/20.
//

#import <StoreKit/StoreKit.h>
#import "GLCodableProtocol.h"


@interface SKPaymentTransaction (GLEncode) <GLEncodeProtocol>
@end
