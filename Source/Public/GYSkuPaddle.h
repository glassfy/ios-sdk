//
//  GYSkuPaddle.h
//  Glassfy
//
//  Created by Luca Garbolino on 22/04/22.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYSkuBase.h>
#else
#import "GYSkuBase.h"
#endif

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.SkuPaddle)
@interface GYSkuPaddle : GYSkuBase
@property(nonatomic, readonly) NSString *name;

@property(nonatomic, nullable, readonly) NSDecimalNumber *initialPrice;
@property(nonatomic, nullable, readonly) NSString *initialPriceCode;        // three-letter ISO currency code

@property(nonatomic, nullable, readonly) NSDecimalNumber *recurringPrice;
@property(nonatomic, nullable, readonly) NSString *recurringPriceCode;      // three-letter ISO currency code

@property(nonatomic, readonly) NSDictionary<NSString*, NSString*>* extravars;
@end

NS_ASSUME_NONNULL_END
