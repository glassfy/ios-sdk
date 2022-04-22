//
//  GYSku.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYTypes.h>
#import <Glassfy/GYSkuBase.h>
#else
#import "GYSkuBase.h"
#import "GYTypes.h"
#endif
@class SKProduct;
@class SKProductDiscount;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.Sku)
@interface GYSku : GYSkuBase
@property(nonatomic, readonly) GYSkuEligibility introductoryEligibility;
@property(nonatomic, readonly) GYSkuEligibility promotionalEligibility;
@property(nonatomic, readonly) NSDictionary<NSString*, NSString*>* extravars;

@property(nonatomic, readonly) SKProduct *product;
@property(nonatomic, nullable, readonly) SKProductDiscount *discount API_AVAILABLE(ios(12.2), macos(10.14.4), watchos(6.2));

@end

NS_ASSUME_NONNULL_END
