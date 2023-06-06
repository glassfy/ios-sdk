//
//  GYPaywall.m
//  Glassfy
//
//  Created by Luca Garbolino on 27/06/22.
//

#import "GYPaywall+Private.h"
#import "Glassfy+Private.h"
#import "GYSku+Private.h"
#import "GYAPIPaywallResponse.h"
#import "GYPaywallJsonProvider.h"
#import "GYPaywallViewController+Private.h"

@interface GYPaywall ()
@property(nullable, nonatomic, strong) NSString *preloadedContent;
@property(nullable, nonatomic, strong) NSURL *contentUrl;
@property(nullable, nonatomic, strong) NSString *version;
@property(nullable, nonatomic, strong) NSString *pwid;
@property(nullable, nonatomic, strong) NSLocale *locale;
@property(nullable, nonatomic, strong) NSArray<GYSku*> *skus;
@property(nonatomic, assign) GYPaywallType type;
@property(nonatomic, copy) GYPaywallViewControllerCompletion contentAvailableHandler;
@end

@implementation GYPaywall (Private)

+ (instancetype)paywallWithResponse:(GYAPIPaywallResponse *)res
{
    GYPaywall *p = [self new];
    p.contentUrl = res.contentUrl;
    p.skus = res.skus;
    p.pwid = res.pwid;
    p.locale = [NSLocale localeWithLocaleIdentifier:res.locale ?: @"en-US"];
    p.type = res.type;
    p.version = res.version;
    [p startLoading];
    return p;
}

- (NSDictionary *)config
{
    return [GYPaywallJsonProvider json:self];
}

- (void)startLoading {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *err = nil;
        self.preloadedContent = [NSString stringWithContentsOfURL:self.contentUrl
                                                         encoding:NSUTF8StringEncoding
                                                            error:&err];
        if (self.contentAvailableHandler) {
            typeof(self) __weak weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                GYPaywallViewControllerCompletion completion = weakSelf.contentAvailableHandler;
                if (completion) {
                    if (err) {
                        completion(nil, err);
                    } else {
                        #if TARGET_OS_IPHONE
                        completion([self viewController], err);
                        #else
                        completion(nil, GYError.notSupported);
                        #endif
                    }
                }
            });
        }
    });
}

@end

@implementation GYPaywall

#if TARGET_OS_IPHONE
- (void)setContentAvailableHandler:(GYPaywallViewControllerCompletion)handler
{
    self->_contentAvailableHandler = handler;
    if (self.preloadedContent) {
        typeof(self) __weak weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            GYPaywallViewControllerCompletion completion = weakSelf.contentAvailableHandler;
            if (completion) {
                completion([weakSelf viewController], nil);
            }
        });
    }
}

- (GYPaywallViewController *)viewController {
    return [GYPaywallViewController instanceWithPaywall:self];
}
#endif

@end
