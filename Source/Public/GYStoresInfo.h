//
//  GYStoresInfo.h
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
@class GYStoreInfo;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.StoresInfo)
@interface GYStoresInfo : NSObject
@property(nonatomic, readonly) NSArray<GYStoreInfo*> *all;

- (NSArray<GYStoreInfo*> *)filter:(GYStore)type;
@end

NS_ASSUME_NONNULL_END
