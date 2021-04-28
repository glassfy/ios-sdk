//
//  GLStoreRequest.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <Foundation/Foundation.h>
#import "GLTypes.h"
@class SKProduct;
@class GLSku;
@class GLOffering;

typedef void(^GLStoreProductCompletion)(SKProduct* _Nullable, NSError* _Nullable);
typedef void(^GLStoreProductsCompletion)(NSArray<SKProduct*>* _Nonnull, NSError* _Nullable);
typedef GLErrorCompletion GLRefreshReceiptCompletion;


NS_ASSUME_NONNULL_BEGIN

@interface GLStoreRequest : NSObject
- (void)productWithOfferings:(NSArray<GLOffering *> *)offerings completion:(GLStoreProductsCompletion)block;
- (void)productWithSkus:(NSArray<GLSku *> *)skus completion:(GLStoreProductsCompletion)block;

- (void)productWithIdentifier:(NSString *)productId completion:(GLStoreProductCompletion)block;
- (void)productWithIdentifiers:(NSSet<NSString *> *)productIds completion:(GLStoreProductsCompletion)block;

- (void)refreshReceipt:(GLRefreshReceiptCompletion)block;
@end

NS_ASSUME_NONNULL_END
