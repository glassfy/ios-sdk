//
//  GYAPIManager.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <Foundation/Foundation.h>
#import "GYTypes.h"
#import "GYUserProperties+Private.h"
#import "GYAPIInitResponse.h"
#import "GYAPIPermissionsResponse.h"
#import "GYAPIOfferingsResponse.h"
#import "GYAPISignatureResponse.h"
#import "GYAPIPropertiesResponse.h"
#import "GYAPISkuResponse.h"
#import "GYAPIPaywallResponse.h"
#import "GYAPIStoreInfoResponse.h"
@class SKProduct;
@class SKPaymentTransaction;
@class GYCacheManager;

typedef void(^GYGetInitCompletion)(GYAPIInitResponse* _Nullable, NSError* _Nullable);
typedef void(^GYGetPermissionsCompletion)(GYAPIPermissionsResponse* _Nullable, NSError* _Nullable);
typedef void(^GYGetOfferingsCompletion)(GYAPIOfferingsResponse* _Nullable, NSError* _Nullable);
typedef void(^GYGetSignatureCompletion)(GYAPISignatureResponse* _Nullable, NSError* _Nullable);
typedef void(^GYGetPropertiesCompletion)(GYAPIPropertiesResponse* _Nullable, NSError* _Nullable);
typedef void(^GYGetPaywallCompletion)(GYAPIPaywallResponse* _Nullable, NSError* _Nullable);
typedef void(^GYGetSkuCompletion)(GYAPISkuResponse* _Nullable, NSError* _Nullable);
typedef void(^GYBaseCompletion)(GYAPIBaseResponse* _Nullable, NSError* _Nullable);
typedef void(^GYGetStoreInfo)(GYAPIStoreInfoResponse* _Nullable, NSError* _Nullable);

typedef GYBaseCompletion GYProductsCompletion;
typedef GYBaseCompletion GYLogoutCompletion;
typedef GYBaseCompletion GYLoginCompletion;
typedef GYBaseCompletion GYPropertyCompletion;
typedef GYBaseCompletion GYGetConnectCompletion;


NS_ASSUME_NONNULL_BEGIN

@interface GYAPIManager : NSObject
@property(nonatomic, readonly) NSString *apiKey;

- (instancetype)initWithApiKey:(NSString *)apiKey cache:(GYCacheManager *)cache;

- (void)getInitWithInfoWithCompletion:(GYGetInitCompletion _Nullable)block;

- (void)getSkuWithId:(NSString *)skuid store:(GYStore)store withCompletion:(GYGetSkuCompletion _Nullable)block;
- (void)getSkuWithProductId:(NSString *)productid promotionalId:(NSString *_Nullable)promoid withCompletion:(GYGetSkuCompletion _Nullable)block;
- (void)getOfferingsWithCompletion:(GYGetOfferingsCompletion _Nullable)block;
- (void)getPermissionsWithCompletion:(GYGetPermissionsCompletion _Nullable)block;

- (void)postProducts:(NSArray<SKProduct*> *)products
          completion:(GYProductsCompletion _Nullable)block;

- (void)postReceipt:(NSData *)receipt
                sku:(GYSku *_Nullable)sku
        transaction:(SKPaymentTransaction *_Nullable)transaction
         completion:(GYGetPermissionsCompletion _Nullable)block;

- (void)postLogoutWithCompletion:(GYLogoutCompletion _Nullable)block;
- (void)postLogin:(NSString *)userId withCompletion:(GYLoginCompletion _Nullable)block;

- (void)postProperty:(GYUserPropertyType)property obj:(id _Nullable)obj completion:(GYPropertyCompletion _Nullable)block;
- (void)getPropertiesWithCompletion:(GYGetPropertiesCompletion _Nullable)block;

- (void)postConnectUser:(NSString *_Nullable)customId completion:(GYGetConnectCompletion _Nullable)block;
- (void)postConnectPaddleLicenseKey:(NSString *)licenseKey force:(BOOL)force completion:(GYGetConnectCompletion _Nullable)block;

- (void)getStoreInfoWithCompletion:(GYGetStoreInfo _Nullable)block;

- (void)getSignatureForProductId:(NSString *)productId offerId:(NSString *)offerId completion:(GYGetSignatureCompletion _Nullable)block;

- (void)getPaywall:(NSString *)paywallId locale:(NSString *_Nullable)locale completion:(GYGetPaywallCompletion _Nullable)block;

- (void)putLastSeen;
@end

NS_ASSUME_NONNULL_END
