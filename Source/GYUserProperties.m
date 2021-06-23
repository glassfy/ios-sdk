//
//  GYUserProperties.m
//  Glassfy
//
//  Created by Luca Garbolino on 28/05/21.
//

#import "GYUserProperties.h"
#import "GYTypes.h"

@interface GYUserProperties()
@property(nonatomic, readwrite, strong) NSString* email;
@property(nonatomic, readwrite, strong) NSString* token;
@property(nonatomic, readwrite, strong) NSDictionary* extra;
@end

@implementation GYUserProperties (Private)

- (instancetype)initWithObject:(nonnull NSDictionary *)obj error:(NSError **)error {
    
    GYUserProperties *properties = [GYUserProperties new];
    
    NSString *propertyType;
    propertyType = [GYUserProperties stringWithPropertyType:GYUserPropertyTypeEmail];
    NSString *email = obj[propertyType];
    if ([email isKindOfClass:NSString.class] && email.length) {
        properties.email = email;
    }
    propertyType = [GYUserProperties stringWithPropertyType:GYUserPropertyTypeToken];
    NSString *token = obj[propertyType];
    if ([token isKindOfClass:NSString.class] && token.length) {
        properties.token = token;
    }
    propertyType = [GYUserProperties stringWithPropertyType:GYUserPropertyTypeExtra];
    NSDictionary *extra = obj[propertyType];
    if ([extra isKindOfClass:NSDictionary.class]) {
        properties.extra = extra;
    }
    
    return properties;
}

+ (NSString *)stringWithPropertyType:(GYUserPropertyType)property
{
    NSString *propertyStr;
    switch (property) {
        case GYUserPropertyTypeEmail:
            propertyStr = @"email";
            break;
        case GYUserPropertyTypeToken:
            propertyStr = @"token";
            break;
        case GYUserPropertyTypeExtra:
            propertyStr = @"info";
            break;
    }
    return propertyStr;
}

@end

@implementation GYUserProperties

@end
