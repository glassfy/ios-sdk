//
//  GYAPIPaywallResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 13/10/21.
//

#import <Foundation/Foundation.h>
#import "GYAPIBaseResponse.h"
@class GYSku;

NS_ASSUME_NONNULL_BEGIN

@interface GYAPIPaywallResponse: GYAPIBaseResponse
@property(nonatomic, strong) NSString *content;
@property(nullable, nonatomic, strong) NSString *locale;
@property(nullable, nonatomic, strong) NSString *pwid;
@property(nonatomic, strong) NSArray<GYSku*> *skus;
@end

NS_ASSUME_NONNULL_END
