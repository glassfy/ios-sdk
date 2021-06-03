//
//  GYAPIPropertiesResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 28/05/21.
//

#import <Foundation/Foundation.h>
#import "GYAPIBaseResponse.h"
@class GYUserProperties;

NS_ASSUME_NONNULL_BEGIN

@interface GYAPIPropertiesResponse : GYAPIBaseResponse
@property(nonatomic, strong) GYUserProperties *properties;
@end

NS_ASSUME_NONNULL_END
