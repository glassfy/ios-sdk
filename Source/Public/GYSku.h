//
//  GYSku.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYTypes.h>
#else
#import "GYTypes.h"
#endif
@class SKProduct;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.Sku)
@interface GYSku : NSObject
@property(nonatomic, readonly) NSString *identifier;
@property(nonatomic, readonly) NSString *productId;
@property(nonatomic, readonly) GYSkuEligibility introductoryEligibility;
@property(nonatomic, readonly) GYSkuEligibility promotionalEligibility;
@property(nonatomic, readonly) NSDictionary<NSString*, NSString*>* extravars;
@property(nonatomic, readonly) SKProduct *product;
@end

NS_ASSUME_NONNULL_END
