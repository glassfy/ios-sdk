//
//  GLAPIInitResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 21/12/20.
//

#import <Foundation/Foundation.h>
#import "GLAPIBaseResponse.h"
@class GLSku;


NS_ASSUME_NONNULL_BEGIN

@interface GLAPIInitResponse: GLAPIBaseResponse
@property(nonatomic, strong) NSArray<GLSku *> *skus;
@property(nonatomic, assign) BOOL hasReceipt;
@end

NS_ASSUME_NONNULL_END
