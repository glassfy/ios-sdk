//
//  GYLogger.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <Foundation/Foundation.h>
#import "GYTypes.h"

NS_ASSUME_NONNULL_BEGIN

#ifdef DEBUG

#define GYLog(...) GYLogDebug(__VA_ARGS__)
#define GYLogErr(...) [GYLogger logErr:__VA_ARGS__]
#define GYLogDebug(...) [GYLogger logDebug:__VA_ARGS__]
#define GYLogInfo(...) [GYLogger logInfo:__VA_ARGS__]
#define GYLogHint(...) [GYLogger logHint:__VA_ARGS__]
#define GYLogSetLevel(level) [GYLogger setLogLevel:level]

@interface GYLogger: NSObject
+ (void)logErr:(nullable NSString *)format, ...;
+ (void)logDebug:(nullable NSString *)format, ...;
+ (void)logInfo:(nullable NSString *)format, ...;
+ (void)logHint:(nullable NSString *)format, ...;

+ (void)setLogLevel:(GYLogLevel)level;
@end

#else

#define GYLog(...) do{ }while(0)
#define GYLogErr(...) do{ }while(0)
#define GYLogDebug(...) do{ }while(0)
#define GYLogInfo(...) do{ }while(0)
#define GYLogHint(...) do{ }while(0)
#define GYLogSetLevel(level) do{ }while(0)

#endif

NS_ASSUME_NONNULL_END
