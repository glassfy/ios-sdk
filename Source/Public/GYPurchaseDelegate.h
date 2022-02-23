//
//  GYPurchaseDelegate.h
//  Glassfy
//
//  Created by Luca Garbolino on 21/02/22.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYTypes.h>
#else
#import "GYTypes.h"
#endif

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.PurchaseDelegate)
@protocol GYPurchaseDelegate <NSObject>
@optional
- (void)handlePromotedProductId:(NSString *)productid
              withPromotionalId:(NSString *_Nullable)promoid
                purchaseHandler:(void (^)(GYPaymentTransactionBlock _Nullable))purchase NS_SWIFT_NAME(handlePromoted(productId:promotionalId:purchaseHandler:));

- (void)didPurchaseProduct:(GYTransaction *)transaction NS_SWIFT_NAME(didPurchaseProduct(transaction:));

@end

NS_ASSUME_NONNULL_END
