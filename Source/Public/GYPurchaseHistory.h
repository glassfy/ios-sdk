//
//  GYPurchaseHistory.h
//  Glassfy
//
//  Created by Luca Garbolino on 06/03/23.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYTypes.h>
#else
#import "GYTypes.h"
#endif

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.PurchaseHistory)
@interface GYPurchaseHistory : NSObject

@property(nonatomic, readonly, strong) NSString *productId;
@property(nonatomic, readonly, strong, nullable) NSString *skuId;

@property(nonatomic, readonly, assign) GYEventType type;
@property(nonatomic, readonly, assign) GYStore store;

@property(nonatomic, readonly, strong, nullable) NSDate *purchaseDate;
@property(nonatomic, readonly, strong, nullable) NSDate *expireDate;

@property(nonatomic, readonly, strong, nullable) NSString *transactionId;
@property(nonatomic, readonly, strong, nullable) NSString *subscriberId;
@property(nonatomic, readonly, strong, nullable) NSString *currencyCode;
@property(nonatomic, readonly, strong, nullable) NSString *countryCode;

@property(nonatomic, readonly, assign) BOOL isInIntroOfferPeriod;
@property(nonatomic, readonly, strong, nullable) NSString *promotionalOfferId;
@property(nonatomic, readonly, strong, nullable) NSString *offerCodeRefName;
@property(nonatomic, readonly, strong, nullable) NSString *licenseCode;
@property(nonatomic, readonly, strong, nullable) NSString *webOrderLineItemId;

@end

NS_ASSUME_NONNULL_END
