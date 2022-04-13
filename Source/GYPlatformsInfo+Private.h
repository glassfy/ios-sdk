//
//  GYPlatformInfo+Private.h.h
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import "GYPlatformsInfo.h"
#import "GYCodableProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GYPlatformsInfo (Private) <GYDecodeProtocol>
+ (instancetype)platformsInfoWithResponse:(GYAPIPlatformInfoResponse *_Nullable)response;
@end

NS_ASSUME_NONNULL_END
