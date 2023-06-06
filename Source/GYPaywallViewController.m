//
//  GYPaywallViewController.m
//  Glassfy
//
//  Created by Luca Garbolino on 13/10/21.
//

#import <StoreKit/StoreKit.h>
#import <WebKit/WebKit.h>
#import "GYPaywallViewController+Private.h"
#import "Glassfy+Private.h"
#import "GYAPIPaywallResponse.h"
#import "GYLogger.h"
#import "GYSku+Private.h"
#import "SKProduct+GYEncode.h"
#import "GYFormatter.h"
#import "GYPaywall+Private.h"
#import "GYSysInfo.h"

#if TARGET_OS_IPHONE

#define kMessageHandlerName @"GYMessageHandler"

@interface GYPaywallViewController() <WKScriptMessageHandler, WKNavigationDelegate>
@property(nonatomic, strong, nullable) NSURL *url;
@property(nonatomic, strong) NSString *pwid;
@property(nonatomic, strong) NSLocale *locale;
@property(nonatomic, strong) NSArray<GYSku*> *skus;
@property(nonatomic, strong) NSString *version;
@property(nonatomic, assign) GYPaywallType paywallType;
@property(nonatomic, strong) GYPaywall *paywall;
@property(nonatomic, weak) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, unsafe_unretained) WKWebView *webview;
@property(nonatomic, copy) GYPaywallCloseBlock closeHandler;
@property(nonatomic, copy) GYPaywallPurchaseBlock purchaseHandler;
@property(nonatomic, copy) GYPaywallLinkBlock linkHandler;
@property(nonatomic, copy) GYPaywallRestoreBlock restoreHandler;

- (void)loadView;
- (void)startLoadingPaywall;
@end

@implementation GYPaywallViewController (Private)

+ (GYPaywallViewController*)instanceWithPaywall:(GYPaywall *)paywall
{
    GYPaywallViewController *vc = [self new];
    vc.paywall = paywall;
    vc.url = paywall.contentUrl;
    vc.version = paywall.version;
    vc.paywallType = paywall.type;
    vc.skus = paywall.skus ?: @[];
    vc.pwid = paywall.pwid;
    vc.locale = paywall.locale;
    return vc;
}

@end

@implementation GYPaywallViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        // default handlers
        typeof(self) __weak weakSelf = self;
        _closeHandler = ^(GYTransaction *t, NSError *err) {
            GYLogInfo(@"PAYWALL Close default handler...");
        };
        
        _purchaseHandler = ^(GYSku *sku) {
            GYLogInfo(@"PAYWALL Purchase default handler...");
            [weakSelf.activityIndicator startAnimating];
            [Glassfy purchaseSku:sku completion:^(GYTransaction *t, NSError *err) {
                [weakSelf.activityIndicator stopAnimating];
                GYPaywallCloseBlock handler = weakSelf.closeHandler;
                if (handler) {
                    handler(t, err);
                }
            }];
        };
        
        _linkHandler = ^(NSURL *url) {
            GYLogInfo(@"PAYWALL Link default handler...");
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        };
        
        _restoreHandler = ^{
            GYLogInfo(@"PAYWALL Restore default handler...");
            [weakSelf.activityIndicator startAnimating];
            [Glassfy restorePurchasesWithCompletion:^(GYPermissions *p, NSError *err) {
                [weakSelf.activityIndicator stopAnimating];
                [weakSelf closeAndDismiss:YES];
            }];
        };
    }
    return self;
}

- (void)closeAndDismiss:(BOOL)dismiss
{
    typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        GYPaywallCloseBlock handler = weakSelf.closeHandler;
        if (handler) {
            handler(nil, nil);
        }
        [weakSelf setCloseHandler:^(GYTransaction * _Nullable t, NSError * _Nullable e) {}];
        if (dismiss) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.activityIndicator.center = self.view.center;
    [self startLoadingPaywall];
}

- (void)loadView
{
    UIView *view = [UIView new];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (@available(iOS 13.0, *)) {
        view.backgroundColor = UIColor.systemBackgroundColor;
    } else {
        view.backgroundColor = UIColor.whiteColor;
    }
    
    WKWebView *webview = [GYPaywallViewController buildWebView];
    [view addSubview:webview];
    
    UIActivityIndicatorView *activityIndicator = [self buildActivityIndicator];
    [view addSubview:activityIndicator];
    
    self.view = view;
    self.webview = webview;
    self.activityIndicator = activityIndicator;
}

- (UIActivityIndicatorView*)buildActivityIndicator
{
    UIActivityIndicatorViewStyle activityIndicatorStyle;
    if (@available(iOS 13.0, *)) {
        activityIndicatorStyle = UIActivityIndicatorViewStyleLarge;
    } else {
        activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
    }
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityIndicatorStyle];
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator startAnimating];
    return activityIndicator;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopLoadingPaywall];
    [self closeAndDismiss:NO];
    [super viewWillDisappear:animated];
}

+ (WKWebView *)buildWebView
{
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.allowsInlineMediaPlayback = YES;
    if (@available(iOS 10.0, *)) {
        config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
        if (@available(iOS 13.0, *)) {
            WKWebpagePreferences *pref = [WKWebpagePreferences new];
            if (@available(iOS 14.0, *)) {
                pref.allowsContentJavaScript = YES;
            }
            config.defaultWebpagePreferences = pref;
        }
    }
    
    // create webview
    WKWebView *webview = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webview.scrollView.showsVerticalScrollIndicator = NO;
    webview.scrollView.showsHorizontalScrollIndicator = NO;
    webview.alpha = 0;
    
    return webview;
}

#pragma mark - handlers

- (void)setCloseHandler:(GYPaywallCloseBlock)handler
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        self->_closeHandler = handler;
    });
}

- (void)setLinkHandler:(GYPaywallLinkBlock)handler
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        self->_linkHandler = handler;
    });
}

- (void)setPurchaseHandler:(GYPaywallPurchaseBlock)handler
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        self->_purchaseHandler = handler;
    });
}

- (void)setRestoreHandler:(GYPaywallRestoreBlock)handler
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        self->_restoreHandler = handler;
    });
}


#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if (![message.name isEqualToString:kMessageHandlerName]) {
        return;
    }
    
    NSDictionary *body = message.body;
    if (![body isKindOfClass:NSDictionary.class]) {
        GYLogErr(@"PAYWALL Wrong message format from paywall's js");
        return;
    }
    
    NSString *action = body[@"action"];
    if (![action isKindOfClass:NSString.class] || !action.length) {
        GYLogErr(@"PAYWALL Missing action from paywall's js");
        return;
    }
    
    NSDictionary *data = body[@"data"];
    if (![data isKindOfClass:NSDictionary.class]) {
        data = @{};
    }
    
    typeof(self) __weak weakSelf = self;
    if ([action isEqualToString:@"close"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf closeAndDismiss:YES];
        });
    }
    else if ([action isEqualToString:@"purchase"]) {
        NSString *skuIdentifier = data[@"sku"];
        GYSku *sku;
        for (GYSku *s in self.skus) {
            if ([skuIdentifier isEqualToString:s.skuId]) {
                sku = s;
            }
        }
        if (!sku) {
            GYLogErr(@"PAYWALL Purchase action err: SKU not found");
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            GYPaywallPurchaseBlock handler = weakSelf.purchaseHandler;
            if (sku && handler) {
                handler(sku);
            }
        });
    }
    else if ([action isEqualToString:@"link"]) {
        NSString *urlStr = data[@"url"];
        if (![urlStr isKindOfClass:NSString.class]) {
            GYLogErr(@"PAYWALL Link action: url is missing");
            return;
        }
        
        NSURL *url = [NSURL URLWithString:urlStr];
        if (!url) {
            GYLogErr(@"PAYWALL Link action: url malformed");
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            GYPaywallLinkBlock handler = weakSelf.linkHandler;
            if (url && handler) {
                handler(url);
            }
        });
    }
    else if ([action isEqualToString:@"restore"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GYPaywallRestoreBlock handler = weakSelf.restoreHandler;
            if (handler) {
                handler();
            }
        });
    }
    else {
        GYLogErr(@"PAYWALL Paywall message not handled: %@", body);
        
        [self updatePaywallTags];
        return;
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if ([webView.URL isEqual:_paywall.contentUrl]) {
        GYLogDebug(@"PAYWALL Finished loading");
        [UIView animateWithDuration:0.1 animations:^{
            self.webview.alpha = 1;
        }];
        [self.activityIndicator stopAnimating];
    }
    [self updatePaywallTags];
}

#pragma mark - utils

- (void)evaluateJs:(nonnull NSString *)action data:(nullable id)obj completion:(void(^_Nullable)(id _Nullable, NSError * _Nullable))completion
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"action"] = action;
    if (obj) {
        params[@"data"] = obj;
    }
    
    NSError *err;
    NSData *paramData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&err];
    if (err) {
        return completion(nil, err);
    }
    
    NSString *paramsStr = [paramData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *js = [NSString stringWithFormat:@"callJs('%@')", paramsStr];
    
    [self.webview evaluateJavaScript:js completionHandler:completion];
}

- (void)startLoadingPaywall
{
    GYLogInfo(@"PAYWALL Start loading");
    [self.webview.configuration.userContentController addScriptMessageHandler:self name:kMessageHandlerName];
    [self.webview setNavigationDelegate:self];
    
    if (_paywall.preloadedContent) {
        GYLogInfo(@"PAYWALL Loading preloaded content");
        [self.webview loadHTMLString:_paywall.preloadedContent baseURL:_paywall.contentUrl];
    } else {
        GYLogInfo(@"PAYWALL Loading content from url");
        NSURLRequest *request = [NSURLRequest requestWithURL:_paywall.contentUrl];
        [self.webview loadRequest:request];
    }
}

- (void)stopLoadingPaywall
{
    GYLogInfo(@"PAYWALL Stop loading");
    [self.webview.configuration.userContentController removeScriptMessageHandlerForName:kMessageHandlerName];
    [self.webview setNavigationDelegate:nil];
    [self.webview stopLoading];
}

- (void)updatePaywallTags
{
    [self evaluateJs:@"setSkuDetails"
                data: [_paywall config]
          completion:^(id res, NSError *error) {
        if (error) {
            GYLogErr(@"PAYWALL Error evaluating js:\n%@", error);
        }
    }];
}

@end

#endif
