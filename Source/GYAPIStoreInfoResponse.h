//
//  GYAPIStoreInfoResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import <Foundation/Foundation.h>
#import "GYAPIBaseResponse.h"
@class GYStoreInfo;

NS_ASSUME_NONNULL_BEGIN

@interface GYAPIStoreInfoResponse : GYAPIBaseResponse
@property(nonatomic, strong) NSArray<GYStoreInfo*> *info;
@end

NS_ASSUME_NONNULL_END
