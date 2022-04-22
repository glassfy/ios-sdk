//
//  GYOfferings+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 23/02/21.
//

#import "GYOfferings.h"
@class SKProduct;

NS_ASSUME_NONNULL_BEGIN

@interface GYOfferings (Private)

+ (instancetype)offeringsWithOffers:(NSArray<GYOffering*> * _Nullable)offerings products:(NSArray<SKProduct*> *)products;

@end

NS_ASSUME_NONNULL_END
