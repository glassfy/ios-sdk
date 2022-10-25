//
//  GYPaywall+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 27/06/22.
//

#import "GYPaywall.h"
#import "GYInternalType.h"
@class GYAPIPaywallResponse;
@class GYSku;

NS_ASSUME_NONNULL_BEGIN

@interface GYPaywall (Private)

+ (instancetype)paywallWithResponse:(GYAPIPaywallResponse *)res;

@property(nullable, nonatomic, strong) NSURL *contentUrl;
@property(nullable, nonatomic, strong) NSString *version;
@property(nullable, nonatomic, strong) NSString *pwid;
@property(nullable, nonatomic, strong) NSLocale *locale;
@property(nullable, nonatomic, strong) NSArray<GYSku*> *skus;
@property(nullable, nonatomic, strong) NSString *content;
@property(nonatomic, assign) GYPaywallType type;

@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, assign) BOOL isLoaded;

@end

NS_ASSUME_NONNULL_END
