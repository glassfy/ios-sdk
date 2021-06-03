//
//  GYLogger.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#ifdef DEBUG

#define LogFormat @"[Glassfy SDK] (%@):\t%@"

#import "GYLogger.h"

@interface GYLogger()
@property(nonatomic, strong) dispatch_queue_t logQueue;
@property(atomic, assign) unsigned long long agId;
@end


@implementation GYLogger

static GYLogLevel logLevel = GYLogLevelError;

+ (void)setLogLevel:(GYLogLevel)level
{
    logLevel = level;
}

+ (void)logErr:(NSString *)format,...
{
    if (format && (logLevel & GYLogFlagError)) {
        va_list args;
        va_start(args, format);
        NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(LogFormat, @"ERROR", logString);
        va_end(args);
    }
}

+ (void)logDebug:(NSString *)format,...
{
    if (format && (logLevel & GYLogFlagDebug)) {
        va_list args;
        va_start(args, format);
        NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(LogFormat, @"debug", logString);
        va_end(args);
    }
}

+ (void)logInfo:(NSString *)format,...
{
    if (format && (logLevel & GYLogFlagInfo)) {
        va_list args;
        va_start(args, format);
        NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(LogFormat, @"info", logString);
        va_end(args);
    }
}

@end

#endif
