//
//  GYSkuBase+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 20/04/22.
//

#import "GYSku.h"
#import "GYCodableProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GYSkuBase (Private) <GYDecodeProtocol>
@property(nonatomic, strong) NSString *skuId;
@property(nonatomic, strong) NSString *productId;
@property(nonatomic, assign) GYStore store;
@end

NS_ASSUME_NONNULL_END
