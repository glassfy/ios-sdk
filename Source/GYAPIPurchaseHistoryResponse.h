//
//  GYAPIPurchasesHistoryResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 06/03/23.
//

#import "GYAPIBaseResponse.h"
@class GYPurchaseHistory;

NS_ASSUME_NONNULL_BEGIN

@interface GYAPIPurchaseHistoryResponse : GYAPIBaseResponse
@property(nonatomic, strong) NSArray<GYPurchaseHistory*> *purchasesHistory;
@property(nonatomic, strong) NSString *subscriberId;
@property(nonatomic, strong, nullable) NSString *customId;
@end

NS_ASSUME_NONNULL_END
