//
//  GYOffering.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import "GYOffering+Private.h"
#import "GYSku+Private.h"
#import "GYError.h"

@interface GYOffering()
//@property(nonatomic, nullable, strong) NSString *name;
@property(nonatomic, strong) NSString *offeringId;
@property(nonatomic, strong) NSArray<GYSku*> *skus;
@end


@implementation GYOffering (Private)

- (instancetype)initWithObject:(nonnull NSDictionary *)obj error:(NSError **)error {
    NSString *identifier;
    if ([obj[@"identifier"] isKindOfClass:NSString.class]) {
        identifier = obj[@"identifier"];
    }
    
    NSMutableArray<GYSku*> *skus = [NSMutableArray array];
    if ([obj[@"skus"] isKindOfClass:NSArray.class]) {
        NSArray *skusJSON = obj[@"skus"];
        for (NSDictionary *sku in skusJSON) {
            if (![sku isKindOfClass:NSDictionary.class]) {
                continue;
            }
            
            GYSku *s = [[GYSku alloc] initWithObject:sku error:nil];
            if (s) {
                s.offeringId = identifier;
                [skus addObject:s];
            }
        }
    }

    if (!identifier) {
        if (error) {
            *error = [GYError serverError:GYErrorCodeUnknow description:@"Unexpected GYOffering data format: missing identifier"];
        }
        
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.offeringId = identifier;
        self.skus = skus;
    }
    return self;
}

- (void)matchSkusWithProducts:(NSArray<SKProduct*> *)products
{
    self.skus = [GYSku matchSkus:self.skus withProducts:products];
}

@end


@implementation GYOffering

#pragma mark - Deprecations

- (NSString *)identifier
{
    return self.offeringId;
}

@end
