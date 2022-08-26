//
//  GYLogger.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#ifdef DEBUG

#define LogFormat "%s\t%s"

#import "GYLogger.h"
#import <os/log.h>

@interface GYLogger()
@property(nonatomic, strong) os_log_t logGlassfy;
@end


@implementation GYLogger

static GYLogLevel logLevel = GYLogLevelError;

+ (void)setLogLevel:(GYLogLevel)level
{
    logLevel = level;
}

+ (void)logErr:(NSString *)format,...
{
    if (!format) { return; }
    os_log_t log = (logLevel & GYLogFlagError) ? self.shared.logGlassfy : OS_LOG_DISABLED;
    
    va_list args;
    va_start(args, format);
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [[logString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        os_log(log, LogFormat, idx ? " " : "🛑", obj.UTF8String);
    }];
//    os_log_error(self.shared.logGlassfy, LogFormat, "❗️", logString.UTF8String);
}

+ (void)logDebug:(NSString *)format,...
{
    if (!format) { return; }
    os_log_t log = (logLevel & GYLogFlagDebug) ? self.shared.logGlassfy : OS_LOG_DISABLED;

    va_list args;
    va_start(args, format);
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [[logString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        os_log(log, LogFormat, idx ? " " : "🔨", obj.UTF8String);
    }];
//    os_log_debug(log, LogFormat, "🔨", logString.UTF8String);
}

+ (void)logInfo:(NSString *)format,...
{
    if (!format) { return; }
    os_log_t log = (logLevel & GYLogFlagInfo) ? self.shared.logGlassfy : OS_LOG_DISABLED;

    va_list args;
    va_start(args, format);
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [[logString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        os_log(log, LogFormat, idx ? " " : "📋", obj.UTF8String);
    }];
//    os_log_info(log, LogFormat, "📋", logString.UTF8String);
}

+ (void)logHint:(nullable NSString *)format, ...
{
    if (!format) { return; }
    os_log_t log = self.shared.logGlassfy;

    va_list args;
    va_start(args, format);
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [[logString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        os_log(log, LogFormat, idx ? " " : "🧐", obj.UTF8String);
    }];
//    os_log_info(log, LogFormat, "🧐", logString.UTF8String);
}


#pragma mark - private

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.logGlassfy = os_log_create("net.glassfy.sdk", "Glassfy SDK");
    }
    return self;
}

+ (GYLogger *)shared
{
    static GYLogger *sharedInstance = nil;
    static dispatch_once_t initOnceToken;
    dispatch_once(&initOnceToken, ^{
        sharedInstance = [[GYLogger alloc] init];
    });
    return sharedInstance;
}

@end

#endif
