//
//  GLOffering.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import "GLOffering+Private.h"
#import "GLSku+Private.h"
#import "GLError.h"

@interface GLOffering()
@property(nonatomic, nullable, strong) NSString *name;
@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSArray<GLSku*> *skus;
@end


@implementation GLOffering (Private)

- (instancetype)initWithObject:(nonnull NSDictionary *)obj error:(NSError **)error {
    NSString *identifier;
    if ([obj[@"identifier"] isKindOfClass:NSString.class]) {
        identifier = obj[@"identifier"];
    }
    NSString *name;
    if ([obj[@"name"] isKindOfClass:NSString.class]) {
        name = obj[@"name"];
    }
    
    NSMutableArray<GLSku*> *skus = [NSMutableArray array];
    if ([obj[@"skus"] isKindOfClass:NSArray.class]) {
        NSArray *skusJSON = obj[@"skus"];
        for (NSDictionary *sku in skusJSON) {
            if (![sku isKindOfClass:NSDictionary.class]) {
                continue;
            }
            
            GLSku *s = [[GLSku alloc] initWithObject:sku error:nil];
            if (s) {
                [skus addObject:s];
            }
        }
    }

    if (!identifier) {
        if (error) {
            *error = [GLError serverError:GLErrorCodeUnknow description:@"Unexpected GLOffering data format: missing identifier"];
        }
        
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.name = name;
        self.identifier = identifier;
        self.skus = skus;
    }
    return self;
}

@end


@implementation GLOffering
@end
