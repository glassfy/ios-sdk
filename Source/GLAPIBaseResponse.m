//
//  GLAPIBaseResponse.m
//  Glassfy
//
//  Created by Luca Garbolino on 21/12/20.
//

#import "GLAPIBaseResponse.h"
#import "GLError.h"

@implementation GLAPIBaseResponse

- (instancetype)initWithObject:(NSDictionary *)obj error:(NSError **)error {
    if ([obj isKindOfClass:NSDictionary.class]) {
        NSDictionary *err = obj[@"error"];
        if ([err isKindOfClass:NSDictionary.class]) {
            NSInteger errorCode = [err[@"code"] integerValue];
            if (errorCode < GLErrorCodeInvalidAPIToken || errorCode > GLErrorCodeInvalidFieldNameError) {
                errorCode = GLErrorCodeUnknow;
            }
            NSString *description;
            if ([err[@"description"] isKindOfClass:NSString.class]) {
                description = err[@"description"];
            }
            if (error) {
                *error = [GLError serverError:errorCode description:description];
            }
        }
        else {
            self = [super init];
            if (self) {
                self.status = [obj[@"status"] integerValue];
            }
        }
    }
    else {
        if (error) {
            *error = [GLError serverError:GLErrorCodeUnknow description:@"Unexpected data format"];
        }
    }
    
    return self;
}

@end
