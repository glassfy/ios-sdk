//
//  GYAttributionItem.h
//  Glassfy
//
//  Created by Luca Garbolino on 02/11/22.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYTypes.h>
#else
#import "GYTypes.h"
#endif

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.AttributionItem)
@interface GYAttributionItem : NSObject

+ (instancetype)attributionItemWithType:(GYAttributionType)name value:(NSString *_Nullable)value;

@end

NS_ASSUME_NONNULL_END
