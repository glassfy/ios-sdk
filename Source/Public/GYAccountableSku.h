//
//  GYAccountableSku.h
//  Glassfy
//
//  Created by Luca Garbolino on 21/09/22.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYSkuBase.h>
#else
#import "GYSkuBase.h"
#endif

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.AccountableSku)
@interface GYAccountableSku : GYSkuBase
@property(nonatomic, readonly) BOOL isInIntroOfferPeriod;
@property(nonatomic, readonly) BOOL isInTrialPeriod;
@end

NS_ASSUME_NONNULL_END
