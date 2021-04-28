//
//  GLAPIBaseResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 21/12/20.
//

#import <Foundation/Foundation.h>
#import "GLCodableProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface GLAPIBaseResponse : NSObject <GLDecodeProtocol>
@property(nonatomic, assign) NSInteger status;
@end

NS_ASSUME_NONNULL_END
