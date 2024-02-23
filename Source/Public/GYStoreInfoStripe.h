//
//  GYStoreInfoStripe.h
//  Glassfy
//
//  Created by Luca Garbolino on 21/02/24.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYStoreInfo.h>)
#import <Glassfy/GYStoreInfo.h>
#else
#import "GYStoreInfo.h"
#endif


NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.StoreInfoStripe)
@interface GYStoreInfoStripe : GYStoreInfo
@property(nonatomic, nullable, readonly) NSString *customerId;
@property(nonatomic, nullable, readonly) NSString *subscriptionId;
@property(nonatomic, nullable, readonly) NSString *producId;
@end

NS_ASSUME_NONNULL_END
