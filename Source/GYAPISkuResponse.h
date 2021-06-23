//
//  GYAPISkuResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 15/06/21.
//

#import <Foundation/Foundation.h>
#import "GYAPIBaseResponse.h"
@class GYSku;

NS_ASSUME_NONNULL_BEGIN

@interface GYAPISkuResponse : GYAPIBaseResponse
@property(nonatomic, strong) GYSku *sku;
@end

NS_ASSUME_NONNULL_END
