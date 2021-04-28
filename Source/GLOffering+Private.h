//
//  GLOffering+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 15/01/21.
//

#import "GLOffering.h"
#import "GLCodableProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GLOffering (Private) <GLDecodeProtocol>
@property(nonatomic, nullable, strong) NSString *name;
@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSArray<GLSku*> *skus;
@end

NS_ASSUME_NONNULL_END
