//
//  GYStoreRequest.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <Foundation/Foundation.h>
#import "GYTypes.h"
@class SKProduct;
@class GYSku;
@class GYOffering;

typedef void(^GYStoreProductCompletion)(SKProduct* _Nullable, NSError* _Nullable);
typedef void(^GYStoreProductsCompletion)(NSArray<SKProduct*>* _Nonnull, NSError* _Nullable);
typedef GYErrorCompletion GYRefreshReceiptCompletion;


NS_ASSUME_NONNULL_BEGIN

@interface GYStoreRequest : NSObject
- (void)productWithOfferings:(NSArray<GYOffering*> *)offerings completion:(GYStoreProductsCompletion)block;
- (void)productWithSkus:(nullable NSArray<GYSku*> *)skus completion:(GYStoreProductsCompletion)block;

- (void)productWithIdentifier:(NSString *)productId completion:(GYStoreProductCompletion)block;
- (void)productWithIdentifiers:(NSSet<NSString*> *)productIds completion:(GYStoreProductsCompletion)block;

- (void)refreshReceipt:(GYRefreshReceiptCompletion)block;
@end

NS_ASSUME_NONNULL_END
