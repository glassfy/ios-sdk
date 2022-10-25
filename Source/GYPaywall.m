//
//  GYPaywall.m
//  Glassfy
//
//  Created by Luca Garbolino on 27/06/22.
//

#import "GYPaywall+Private.h"
#import "GYSku.h"
#import "Glassfy+Private.h"
#import "GYAPIPaywallResponse.h"
#import "GYPaywallViewController+Private.h"

@interface GYPaywall()
@property(nonatomic, strong) NSURL *contentUrl;
@property(nonatomic, strong) NSString *version;
@property(nonatomic, strong) NSString *pwid;
@property(nonatomic, strong) NSLocale *locale;
@property(nonatomic, strong) NSArray<GYSku*> *skus;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, assign) GYPaywallType type;

@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, assign) BOOL isLoaded;

@end

@implementation GYPaywall (Private)

+ (instancetype)paywallWithResponse:(GYAPIPaywallResponse *)res
{
    GYPaywall *p = [self new];
    
    p.content = res.content;
    p.contentUrl = [NSURL URLWithString:res.contentUrl];
    
    p.skus = res.skus;
    p.pwid = res.pwid;
    p.locale = [NSLocale localeWithLocaleIdentifier:res.locale ?: @"en-US"];
    
    p.type = res.type;
    p.version = res.version;
    
    return p;
}

@end

@implementation GYPaywall

#if TARGET_OS_IPHONE
- (void)loadPaywallViewController:(void(^)(GYPaywallViewController *_Nullable, NSError *_Nullable))completion
{
    [self startLoading:^(NSError *err) {
        GYPaywallViewController *vc = nil;
        if (!err) {
            vc = [GYPaywallViewController paywallViewController:self];
        }
        
        completion(vc, err);
    }];
}

- (GYPaywallViewController *)paywallViewController
{
    return [GYPaywallViewController paywallViewController:self];
}
#endif

- (void)startLoading:(void(^_Nonnull)(NSError *))completion
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        if (self.content || self.isLoaded || self.isLoading) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
            return;
        }
        
        self.isLoading = YES;
        
        NSError *err = nil;
        self.content = [NSString stringWithContentsOfURL:self.contentUrl encoding:NSUTF8StringEncoding error:&err];
        
        self.isLoading = NO;

        if (!err) {
            self.isLoaded = YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(err);
        });
    });
}

@end
