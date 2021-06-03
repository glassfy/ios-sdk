//
//  GYUserProperties+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 28/05/21.
//

#import "GYUserProperties.h"
#import "GYTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface GYUserProperties (Private) <GYDecodeProtocol>
+ (NSString *)stringWithPropertyType:(GYUserPropertyType)property;
@end

NS_ASSUME_NONNULL_END
