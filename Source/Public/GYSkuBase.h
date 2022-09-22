//
//  GYSkuBase.h
//  Glassfy
//
//  Created by Luca Garbolino on 20/04/22.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYTypes.h>
#else
#import "GYTypes.h"
#endif

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.SkuBase)
@interface GYSkuBase : NSObject
@property(nonatomic, readonly) NSString *skuId;
@property(nonatomic, readonly) NSString *productId;

@property(nonatomic, readonly) GYStore store;

/// Deprecations
@property(nonatomic, readonly) NSString *identifier __attribute__((deprecated("Renamed to skuId")));
@end

NS_ASSUME_NONNULL_END
