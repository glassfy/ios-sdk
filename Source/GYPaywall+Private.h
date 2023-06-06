//
//  GYPaywall+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 27/06/22.
//

#import "GYPaywall.h"
@class GYAPIPaywallResponse;

NS_ASSUME_NONNULL_BEGIN

@interface GYPaywall (Private)

@property(nullable, nonatomic, strong) NSString *preloadedContent;
@property(nullable, nonatomic, strong) NSURL *contentUrl;
@property(nullable, nonatomic, strong) NSString *version;
@property(nullable, nonatomic, strong) NSString *pwid;
@property(nullable, nonatomic, strong) NSLocale *locale;
@property(nullable, nonatomic, strong) NSArray<GYSku*> *skus;
@property(nonatomic, assign) GYPaywallType type;

+ (instancetype)paywallWithResponse:(GYAPIPaywallResponse *)res;

- (NSDictionary *)config;

@end

NS_ASSUME_NONNULL_END
