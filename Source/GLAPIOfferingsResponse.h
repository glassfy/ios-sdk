//
//  GLAPIOfferingsResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 21/12/20.
//

#import <Foundation/Foundation.h>
#import "GLAPIBaseResponse.h"
@class GLSku;
@class GLOffering;


NS_ASSUME_NONNULL_BEGIN

@interface GLAPIOfferingsResponse: GLAPIBaseResponse
@property(nonatomic, strong) NSArray<GLOffering *> *offerings;
@end

NS_ASSUME_NONNULL_END
