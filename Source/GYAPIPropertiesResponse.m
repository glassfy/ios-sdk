//
//  GYAPIPropertiesResponse.m
//  Glassfy
//
//  Created by Luca Garbolino on 28/05/21.
//

#import "GYAPIPropertiesResponse.h"
#import "GYUserProperties+Private.h"
#import "GYError.h"

@implementation GYAPIPropertiesResponse

- (instancetype _Nullable)initWithObject:(NSDictionary *)obj error:(NSError **)error
{
    self = [super initWithObject:obj error:error];
    if (error && *error) {
        return self;
    }
    
    if (self) {
        NSDictionary *prop = obj[@"property"];
        if ([prop isKindOfClass:NSDictionary.class]) {
            self.properties = [[GYUserProperties alloc] initWithObject:prop error:error];;
        }
        else {
            if (error) {
                *error = [GYError serverError:GYErrorCodeUnknow description:@"Unexpected data format"];
            }
        }
    }
    return self;
}
@end
