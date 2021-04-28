//
//  GLLogger.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <Foundation/Foundation.h>
#import "GLTypes.h"

NS_ASSUME_NONNULL_BEGIN

#ifdef DEBUG
@interface GLLogger: NSObject
    #define GLLog(...) GLLogDebug(__VA_ARGS__)
    #define GLLogErr(...) [GLLogger logErr:__VA_ARGS__]
    #define GLLogDebug(...) [GLLogger logDebug:__VA_ARGS__]
    #define GLLogInfo(...) [GLLogger logInfo:__VA_ARGS__]
    #define GLLogSetLevel(level) [GLLogger setLogLevel:level]

    + (void)logErr:(nullable NSString *)format, ...;
    + (void)logDebug:(nullable NSString *)format, ...;
    + (void)logInfo:(nullable NSString *)format, ...;
    
    + (void)setLogLevel:(GLLogLevel)level;
@end
#else
    #define GLLog(...) do{ }while(0)
    #define GLLogErr(...) do{ }while(0)
    #define GLLogDebug(...) do{ }while(0)
    #define GLLogInfo(...) do{ }while(0)
    #define GLLogSetLevel(level) do{ }while(0)
#endif

NS_ASSUME_NONNULL_END
