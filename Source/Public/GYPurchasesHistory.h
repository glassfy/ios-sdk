//
//  GYPurchasesHistory.h
//  Glassfy
//
//  Created by Luca Garbolino on 06/03/23.
//

#import <Foundation/Foundation.h>
@class GYPurchaseHistory;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.PurchasesHistory)
@interface GYPurchasesHistory : NSObject
@property(nonatomic, readonly, strong) NSArray<GYPurchaseHistory *> *all;

@property(nonatomic, readonly, strong) NSString *subscriberId;
@property(nonatomic, readonly, strong, nullable) NSString *customId;
@end

NS_ASSUME_NONNULL_END
