//
//  GYUserProperties.m
//  Glassfy
//
//  Created by Luca Garbolino on 28/05/21.
//

#import "GYUserProperties+Private.h"

@interface GYUserProperties()
@property(nonatomic, readwrite, strong) NSString *email;
@property(nonatomic, readwrite, strong) NSString *token;
@property(nonatomic, readwrite, strong) NSDictionary<NSString*,NSString*> *extra;
@end

@implementation GYUserProperties (Private)

- (instancetype)initWithObject:(nonnull NSDictionary *)obj error:(NSError **)error {
    self = [super init];
    if (self) {
        NSString *email = obj[GYUserPropertyTypeEmail];
        if ([email isKindOfClass:NSString.class] && email.length) {
            self.email = email;
        }
        NSString *token = obj[GYUserPropertyTypeToken];
        if ([token isKindOfClass:NSString.class] && token.length) {
            self.token = token;
        }
        NSDictionary *extra = obj[GYUserPropertyTypeExtra];
        if ([extra isKindOfClass:NSDictionary.class]) {
            self.extra = extra;
        }
    }
    
    return self;
}

@end

@implementation GYUserProperties

@end
