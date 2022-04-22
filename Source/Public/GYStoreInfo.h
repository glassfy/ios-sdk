//
//  GYStoreInfo.h
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYTypes.h>
#else
#import "GYTypes.h"
#endif

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.StoreInfo)
@interface GYStoreInfo : NSObject
@property(nonatomic, readonly) GYStore store;
@property(nonatomic, readonly) NSDictionary *rawInfo;
@end

NS_ASSUME_NONNULL_END
