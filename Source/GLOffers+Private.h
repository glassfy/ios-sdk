//
//  GLOfferings+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 23/02/21.
//

#import "GLOfferings.h"
@class SKProduct;

NS_ASSUME_NONNULL_BEGIN

@interface GLOfferings (Private)

+ (instancetype)offeringsWithOffers:(NSArray<GLOffering *> * _Nullable)offerings products:(NSArray<SKProduct *> *)products;

@end

NS_ASSUME_NONNULL_END
