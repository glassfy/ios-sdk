//
//  GLAPIOfferingsResponse.m
//  Glassfy
//
//  Created by Luca Garbolino on 21/12/20.
//

#import "GLAPIOfferingsResponse.h"
#import "GLOffering+Private.h"

@implementation GLAPIOfferingsResponse

- (instancetype)initWithObject:(NSDictionary *)obj error:(NSError **)error
{
    self = [super initWithObject:obj error:error];
    if (error && *error) {
        return self;
    }
    
    if (self) {
        NSMutableArray *offerings = [NSMutableArray array];
        NSArray *offeringsJSON = obj[@"offerings"];
        if ([offeringsJSON isKindOfClass:NSArray.class]) {
            for (NSDictionary *offeringJSON in offeringsJSON) {
                if (![offeringJSON isKindOfClass:NSDictionary.class]) {
                    continue;
                }
                
                GLOffering *offering = [[GLOffering alloc] initWithObject:offeringJSON error:nil];
                if (offering) {
                    [offerings addObject:offering];
                }
            }
        }
        self.offerings = offerings;
    }
    return self;
}

@end
