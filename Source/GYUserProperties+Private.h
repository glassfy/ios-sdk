//
//  GYUserProperties+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 28/05/21.
//

#import "GYUserProperties.h"
#import "GYCodableProtocol.h"
#import "GYTypes.h"

typedef NSString *              GYUserPropertyType;
#define GYUserPropertyTypeEmail @"email"
#define GYUserPropertyTypeToken @"token"
#define GYUserPropertyTypeExtra @"info"

NS_ASSUME_NONNULL_BEGIN

@interface GYUserProperties (Private) <GYDecodeProtocol>
@end

NS_ASSUME_NONNULL_END
