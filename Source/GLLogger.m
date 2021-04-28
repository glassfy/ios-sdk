//
//  GLLogger.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#ifdef DEBUG

#define LogFormat @"[Glassfy SDK] (%@):\t%@"

#import "GLLogger.h"

@interface GLLogger()
@property(nonatomic, strong) dispatch_queue_t logQueue;
@property(atomic, assign) unsigned long long agId;
@end


@implementation GLLogger

static GLLogLevel logLevel = GLLogLevelError;

+ (void)setLogLevel:(GLLogLevel)level
{
    logLevel = level;
}

+ (void)logErr:(NSString *)format,...
{
    if (format && (logLevel & GLLogFlagError)) {
        va_list args;
        va_start(args, format);
        NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(LogFormat, @"ERROR", logString);
        va_end(args);
    }
}

+ (void)logDebug:(NSString *)format,...
{
    if (format && (logLevel & GLLogFlagDebug)) {
        va_list args;
        va_start(args, format);
        NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(LogFormat, @"debug", logString);
        va_end(args);
    }
}

+ (void)logInfo:(NSString *)format,...
{
    if (format && (logLevel & GLLogFlagInfo)) {
        va_list args;
        va_start(args, format);
        NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(LogFormat, @"info", logString);
        va_end(args);
    }
}

@end

#endif
