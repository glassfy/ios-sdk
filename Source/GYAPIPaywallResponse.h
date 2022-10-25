//
//  GYAPIPaywallResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 27/06/22.
//

#import <Foundation/Foundation.h>
#import "GYAPIBaseResponse.h"
#import "GYInternalType.h"
@class GYSku;

NS_ASSUME_NONNULL_BEGIN

@interface GYAPIPaywallResponse : GYAPIBaseResponse

@property(nullable, nonatomic, strong) NSString *content;
@property(nullable, nonatomic, strong) NSString *contentUrl;

@property(nullable, nonatomic, strong) NSString *version;
@property(nonatomic, assign) GYPaywallType type;
@property(nullable, nonatomic, strong) NSString *locale;
@property(nullable, nonatomic, strong) NSString *pwid;
@property(nonatomic, strong) NSArray<GYSku*> *skus;
@end

NS_ASSUME_NONNULL_END
