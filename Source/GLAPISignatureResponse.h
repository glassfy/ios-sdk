//
//  GLAPISignatureResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 17/03/21.
//

#import <Foundation/Foundation.h>
#import "GLAPIBaseResponse.h"


NS_ASSUME_NONNULL_BEGIN

@interface GLAPISignatureResponse : GLAPIBaseResponse
@property(nonatomic, strong) NSString *signature;
@property(nonatomic, strong) NSString *keyIdentifier;
@property(nonatomic, strong) NSUUID *nonce;
@property(nonatomic, strong) NSNumber *timestamp;
@end

NS_ASSUME_NONNULL_END
