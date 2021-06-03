//
//  GYAPIBaseResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 21/12/20.
//

#import <Foundation/Foundation.h>
#import "GYCodableProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface GYAPIBaseResponse : NSObject <GYDecodeProtocol>
@property(nonatomic, assign) NSInteger status;
@end

NS_ASSUME_NONNULL_END
