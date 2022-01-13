//
//  GYAPISignatureResponse.m
//  Glassfy
//
//  Created by Luca Garbolino on 17/03/21.
//

#import "GYAPISignatureResponse.h"
#import "GYError.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GYAPISignatureResponse

- (instancetype _Nullable)initWithObject:(NSDictionary *)obj error:(NSError **)error
{
    self = [super initWithObject:obj error:error];
    if (error && *error) {
        return self;
    }
    
    if (self) {
        NSString *signature = obj[@"signature"];
        if ([signature isKindOfClass:NSString.class] && signature.length > 0) {
            self.signature = signature;
        }
        
        NSString *keyidentifier = obj[@"keyidentifier"];
        if ([keyidentifier isKindOfClass:NSString.class] && keyidentifier.length > 0) {
            self.keyIdentifier = keyidentifier;
        }
        
        NSString *nonce = obj[@"nonce"];
        if ([nonce isKindOfClass:NSString.class] && nonce.length > 0) {
            self.nonce = [[NSUUID alloc] initWithUUIDString:nonce];
        }
        
        NSString *timestamp = obj[@"timestamp"];
        if ([timestamp isKindOfClass:NSString.class] && timestamp.integerValue > 0) {
            self.timestamp = @(timestamp.integerValue);
        }
        
        NSString *applicationUsername = obj[@"applicationusername"];
        if ([applicationUsername isKindOfClass:NSString.class] && applicationUsername.length > 0) {
            self.applicationUsername = applicationUsername;
        }
        
        // verify
        if (!self.signature || !self.keyIdentifier || !self.nonce || self.timestamp == nil) {
            if (error) {
                *error = [GYError serverError:GYErrorCodeUnknow description:@"Unexpected data format"];
            }
        }
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
