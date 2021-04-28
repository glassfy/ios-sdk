//
//  GLSku+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 11/01/21.
//

#import "GLSku.h"
#import "GLCodableProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GLSku (Private) <GLDecodeProtocol>
@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSString *productId;
@property(nonatomic, assign) GLSkuEligibility introductoryEligibility;
@property(nonatomic, assign) GLSkuEligibility promotionalEligibility;
@property(nonatomic, strong) NSDictionary<NSString*, NSString*>* extravars;
@property(nonatomic, nullable, strong) SKProduct *product;
@end

NS_ASSUME_NONNULL_END
