//
//  GLAPIInitResponse.m
//  Glassfy
//
//  Created by Luca Garbolino on 21/12/20.
//

#import "GLAPIInitResponse.h"
#import "GLSku+Private.h"

@implementation GLAPIInitResponse

- (instancetype _Nullable)initWithObject:(NSDictionary *)obj error:(NSError **)error
{
    self = [super initWithObject:obj error:error];
    if (error && *error) {
        return self;
    }
    
    if (self) {
        self.hasReceipt = [obj[@"hasreceipt"] boolValue];

        NSMutableArray *skus = [NSMutableArray array];
        NSArray *skusJSON = obj[@"skus"];
        if ([skusJSON isKindOfClass:NSArray.class]) {
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
        self.skus = skus;
    }
    return self;
}

@end
