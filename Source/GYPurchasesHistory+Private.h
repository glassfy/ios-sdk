//
//  GYPurchasesHistory+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 06/03/23.
//

#import "GYPurchasesHistory.h"
@class GYAPIPurchaseHistoryResponse;

NS_ASSUME_NONNULL_BEGIN

@interface GYPurchasesHistory (Private)

+ (instancetype)purchasesHistoryWithResponse:(GYAPIPurchaseHistoryResponse *)res;

@end

NS_ASSUME_NONNULL_END
