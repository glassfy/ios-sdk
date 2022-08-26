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

#if TARGET_OS_IPHONE

@interface GYPaywallViewController () <WKScriptMessageHandler, WKNavigationDelegate>
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSString *pwid;
@property(nonatomic, strong) NSLocale *locale;
@property(nonatomic, strong) NSArray<GYSku*> *skus;

@property(nonatomic, weak) UIView *activityView;
@property(nonatomic, unsafe_unretained) WKWebView *webview;

@property(nonatomic, copy) GYPaywallCloseBlock closeHandler;
@property(nonatomic, copy) GYPaywallPurchaseBlock purchaseHandler;
@property(nonatomic, copy) GYPaywallLinkBlock linkHandler;
@property(nonatomic, copy) GYPaywallRestoreBlock restoreHandler;
@end

@implementation GYPaywallViewController (Private)

+ (instancetype)paywallWithResponse:(GYAPIPaywallResponse *)res
{
    GYPaywallViewController *vc = [self new];
    vc.content = res.content;
    vc.skus = res.skus;
    vc.pwid = res.pwid;
    vc.locale = [NSLocale localeWithLocaleIdentifier:res.locale ?: @"en-US"];
    
    return vc;
}

@end

@implementation GYPaywallViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        // default handlers
        __weak typeof(self) weakSelf = self;
        _closeHandler = ^(GYTransaction *t, NSError *err) {
            GYLogInfo(@"PAYWALL Close default handler...");
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };

        _purchaseHandler = ^(GYSku *sku) {
            GYLogInfo(@"PAYWALL Purchase default handler...");
            [weakSelf.activityView removeFromSuperview];
            
            UIView *activityView = [weakSelf buildActivityView:weakSelf.view.bounds];
            [weakSelf.view addSubview:activityView];
            weakSelf.activityView = activityView;
            [Glassfy purchaseSku:sku completion:^(GYTransaction *t, NSError *err) {
                [weakSelf.activityView removeFromSuperview];
                weakSelf.closeHandler(t, err);
            }];
        };
        
        _linkHandler = ^(NSURL *url) {
            GYLogInfo(@"PAYWALL Link default handler...");
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        };
        
        _restoreHandler = ^{
            GYLogInfo(@"PAYWALL Restore default handler...");
            [weakSelf.activityView removeFromSuperview];
            
            UIView *activityView = [weakSelf buildActivityView:weakSelf.view.bounds];
            [weakSelf.view addSubview:activityView];
            weakSelf.activityView = activityView;
            
            [Glassfy restorePurchasesWithCompletion:^(GYPermissions *p, NSError *err) {
                [weakSelf.activityView removeFromSuperview];
                weakSelf.closeHandler(nil, err);
            }];
        };
    }
    return self;
}

- (void)loadView
{
    UIView *view = [UIView new];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // webview
    WKWebView *webview = [GYPaywallViewController buildWebView];
    [view addSubview:webview];
    
    self.view = view;
    self.webview = webview;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self startLoadingPaywall];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopLoadingPaywall];
    
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
    
    return webview;
}

- (UIView *)buildActivityView:(CGRect)frame
{
    UIView *activity = [[UIView alloc] initWithFrame:frame];;
    activity.backgroundColor = [UIColor colorWithWhite:.3f alpha:.7f];
    activity.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIActivityIndicatorView *activityIndicator;
    if (@available(iOS 13, *)) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    }
    else {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    activityIndicator.color = UIColor.whiteColor;
    activityIndicator.center = activity.center;
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
                                            UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [activityIndicator startAnimating];
    
    [activity addSubview:activityIndicator];
    
    return activity;
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
    if (![message.name isEqualToString:@"GYMessageHandler"]) {
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
    
    __weak typeof(self) weakSelf = self;
    if ([action isEqualToString:@"close"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GYPaywallCloseBlock handler = weakSelf.closeHandler;
            if (handler) {
                handler(nil, nil);
            }
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
    [self.webview.configuration.userContentController addScriptMessageHandler:self name:@"GYMessageHandler"];
    [self.webview setNavigationDelegate:self];
    
    [self.webview loadHTMLString:self.content baseURL:nil];
}

- (void)stopLoadingPaywall
{
    GYLogInfo(@"PAYWALL Stop loading");
    [self.webview.configuration.userContentController removeScriptMessageHandlerForName:@"GYMessageHandler"];
    [self.webview setNavigationDelegate:nil];

    [self.webview stopLoading];
}

- (void)updatePaywallTags
{
    NSDictionary *skusDetails = [self skuDetails];
    [self evaluateJs:@"setSkuDetails" data:skusDetails completion:^(id res, NSError *error) {
        if (error) {
            GYLogErr(@"PAYWALL Error evaluating js:\n%@", error);
        }
    }];
}

- (NSDictionary *)skuDetails
{
    NSMutableDictionary *skusDetails = [NSMutableDictionary new];
    NSMutableDictionary *commonMsg = [NSMutableDictionary new];
    if (@available(iOS 11.2, *)) {
        commonMsg[@"$DAY"] = [GYFormatter formatUnit:SKProductPeriodUnitDay locale:self.locale];
        commonMsg[@"$WEEK"] = [GYFormatter formatUnit:SKProductPeriodUnitWeek locale:self.locale];
        commonMsg[@"$MONTH"] = [GYFormatter formatUnit:SKProductPeriodUnitMonth locale:self.locale];
        commonMsg[@"$YEAR"] = [GYFormatter formatUnit:SKProductPeriodUnitYear locale:self.locale];
    }
    
    NSMutableArray<NSNumber*> *priceCorrections = [NSMutableArray array];
    for (GYSku *s in self.skus) {
        SKProduct *p = s.product;
        
        NSMutableDictionary *msg = [NSMutableDictionary new];
        msg[@"$TITLE"] = p.localizedTitle;
        msg[@"$DESCRIPTION"] = p.localizedDescription;
        msg[@"$ORIGINAL_PRICE"] = [self formatPrice:p.price locale:p.priceLocale];
        
        float priceCorrection = 1.0f;
        if (@available(iOS 11.2, *)) {
            float k = 1.0f;
            switch (p.subscriptionPeriod.unit) {
                case (SKProductPeriodUnitDay):
                    msg[@"$ORIGINAL_PERIOD"] = commonMsg[@"$DAY"];
                    k = 1.0f;
                    
                    break;
                case (SKProductPeriodUnitWeek):
                    msg[@"$ORIGINAL_PERIOD"] = commonMsg[@"$WEEK"];
                    k = 1.0f / 7.0f;
                    
                    break;
                case (SKProductPeriodUnitMonth):
                    msg[@"$ORIGINAL_PERIOD"] = commonMsg[@"$MONTH"];
                    k = 12.0f / 365.0f;
                    
                    break;
                case (SKProductPeriodUnitYear):
                    msg[@"$ORIGINAL_PERIOD"] = commonMsg[@"$YEAR"];
                    k = 1.0f / 365.0f;
                    
                    break;
            }
            priceCorrection = k;
            
            float priceDaily = p.price.floatValue * k / p.subscriptionPeriod.numberOfUnits;
            float priceWeekly = priceDaily * 7.0f;
            float priceYearly = priceDaily * 365.0f;
            float priceMonthly = priceYearly / 12.0f;
            
            msg[@"$ORIGINAL_DURATION"] = [GYFormatter formatPeriod:p.subscriptionPeriod.numberOfUnits unit:p.subscriptionPeriod.unit locale:self.locale];
            
            msg[@"$ORIGINAL_DAILY"] = [self formatPrice:@(priceDaily) locale:p.priceLocale];
            msg[@"$ORIGINAL_WEEKLY"] = [self formatPrice:@(priceWeekly) locale:p.priceLocale];
            msg[@"$ORIGINAL_MONTHLY"] = [self formatPrice:@(priceMonthly) locale:p.priceLocale];
            msg[@"$ORIGINAL_YEARLY"] = [self formatPrice:@(priceYearly) locale:p.priceLocale];
            
            if (p.introductoryPrice) {
                float k = 1.0f;
                switch (p.introductoryPrice.subscriptionPeriod.unit) {
                    case (SKProductPeriodUnitDay):
                        msg[@"$INTRO_PERIOD"] = commonMsg[@"$DAY"];
                        k = 1.0f;
                        
                        break;
                    case (SKProductPeriodUnitWeek):
                        msg[@"$INTRO_PERIOD"] = commonMsg[@"$WEEK"];
                        k = 1.0f / 7.0f;
                        
                        break;
                    case (SKProductPeriodUnitMonth):
                        msg[@"$INTRO_PERIOD"] = commonMsg[@"$MONTH"];
                        k = 12.0f / 365.0f;
                        
                        break;
                    case (SKProductPeriodUnitYear):
                        msg[@"$INTRO_PERIOD"] = commonMsg[@"$YEAR"];
                        k = 1.0f / 365.0f;
                        
                        break;
                }
                
                float introDaily = p.introductoryPrice.price.floatValue * k / p.introductoryPrice.subscriptionPeriod.numberOfUnits;
                float introWeekly = introDaily * 7.0f;
                float introYearly = introDaily * 365.0f;
                float introMonthly = introYearly / 12.0f;
                float introDiscount = introDaily / priceDaily;
                
                msg[@"$INTRO_PRICE"] = [self formatPrice:p.introductoryPrice.price locale:p.introductoryPrice.priceLocale];
                msg[@"$INTRO_DURATION"] = [GYFormatter formatPeriod:p.introductoryPrice.subscriptionPeriod.numberOfUnits
                                                               unit:p.introductoryPrice.subscriptionPeriod.unit
                                                             locale:self.locale];

                msg[@"$INTRO_DAILY"] = [self formatPrice:@(introDaily) locale:p.introductoryPrice.priceLocale];
                msg[@"$INTRO_WEEKLY"] = [self formatPrice:@(introWeekly) locale:p.introductoryPrice.priceLocale];
                msg[@"$INTRO_MONTHLY"] = [self formatPrice:@(introMonthly) locale:p.introductoryPrice.priceLocale];
                msg[@"$INTRO_YEARLY"] = [self formatPrice:@(introYearly) locale:p.introductoryPrice.priceLocale];
                
                msg[@"$INTRO_DISCOUNT"] = [GYFormatter formatPercentage:@(introDiscount) locale:self.locale];
            }
            
            if (s.promotionalId) {
                NSPredicate *p = [NSPredicate predicateWithFormat:@"identifier = %@", s.promotionalId];
                if (@available(iOS 12.2, *)) {
                    SKProductDiscount *promo = [[s.product.discounts filteredArrayUsingPredicate:p] firstObject];
                    
                    if (promo) {
                        float k = 1.0f;
                        switch (promo.subscriptionPeriod.unit) {
                            case (SKProductPeriodUnitDay):
                                msg[@"$PROMO_PERIOD"] = commonMsg[@"$DAY"];
                                k = 1.0f;
                                
                                break;
                            case (SKProductPeriodUnitWeek):
                                msg[@"$PROMO_PERIOD"] = commonMsg[@"$WEEK"];
                                k = 1.0f / 7.0f;
                                
                                break;
                            case (SKProductPeriodUnitMonth):
                                msg[@"$PROMO_PERIOD"] = commonMsg[@"$MONTH"];
                                k = 12.0f / 365.0f;
                                
                                break;
                            case (SKProductPeriodUnitYear):
                                msg[@"$PROMO_PERIOD"] = commonMsg[@"$YEAR"];
                                k = 1.0f / 365.0f;
                                
                                break;
                        }
                        
                        float promoDaily = promo.price.floatValue * k / promo.subscriptionPeriod.numberOfUnits;
                        float promoWeekly = promoDaily * 7.0f;
                        float promoYearly = promoDaily * 365.0f;
                        float promoMonthly = promoYearly / 12.0f;
                        float promoDiscount = promoDaily / priceDaily;
                        
                        msg[@"$PROMO_PRICE"] = [self formatPrice:promo.price locale:promo.priceLocale];
                        msg[@"$PROMO_DURATION"] = [GYFormatter formatPeriod:promo.subscriptionPeriod.numberOfUnits
                                                                       unit:promo.subscriptionPeriod.unit
                                                                     locale:self.locale];
                        
                        msg[@"$PROMO_DAILY"] = [self formatPrice:@(promoDaily) locale:promo.priceLocale];
                        msg[@"$PROMO_WEEKLY"] = [self formatPrice:@(promoWeekly) locale:promo.priceLocale];
                        msg[@"$PROMO_MONTHLY"] = [self formatPrice:@(promoMonthly) locale:promo.priceLocale];
                        msg[@"$PROMO_YEARLY"] = [self formatPrice:@(promoYearly) locale:promo.priceLocale];
                        
                        msg[@"$PROMO_DISCOUNT"] = [GYFormatter formatPercentage:@(promoDiscount) locale:self.locale];
                    }
                }
            }
        }
        [priceCorrections addObject:@(priceCorrection)];
        
        if (s.promotionalEligibility == GYSkuEligibilityEligible && msg[@"$PROMO_PRICE"]) {
            msg[@"$PERIOD"] = msg[@"$PROMO_PERIOD"];
            msg[@"$PRICE"] = msg[@"$PROMO_PRICE"];
            msg[@"$DURATION"] = msg[@"$PROMO_DURATION"];
            msg[@"$DAILY"] = msg[@"$PROMO_DAILY"];
            msg[@"$WEEKLY"] = msg[@"$PROMO_WEEKLY"];
            msg[@"$MONTHLY"] = msg[@"$PROMO_MONTHLY"];
            msg[@"$YEARLY"] = msg[@"$PROMO_YEARLY"];
            msg[@"$DISCOUNT"] = msg[@"$PROMO_DISCOUNT"];
        } else if (s.introductoryEligibility == GYSkuEligibilityEligible && msg[@"$INTRO_PRICE"]) {
            msg[@"$PERIOD"] = msg[@"$INTRO_PERIOD"];
            msg[@"$PRICE"] = msg[@"$INTRO_PRICE"];
            msg[@"$DURATION"] = msg[@"$INTRO_DURATION"];
            msg[@"$DAILY"] = msg[@"$INTRO_DAILY"];
            msg[@"$WEEKLY"] = msg[@"$INTRO_WEEKLY"];
            msg[@"$MONTHLY"] = msg[@"$INTRO_MONTHLY"];
            msg[@"$YEARLY"] = msg[@"$INTRO_YEARLY"];
            msg[@"$DISCOUNT"] = msg[@"$INTRO_DISCOUNT"];
        } else {
            msg[@"$PERIOD"] = msg[@"$ORIGINAL_PERIOD"];
            msg[@"$PRICE"] = msg[@"$ORIGINAL_PRICE"];
            msg[@"$DURATION"] = msg[@"$ORIGINAL_DURATION"];
            msg[@"$DAILY"] = msg[@"$ORIGINAL_DAILY"];
            msg[@"$WEEKLY"] = msg[@"$ORIGINAL_WEEKLY"];
            msg[@"$MONTHLY"] = msg[@"$ORIGINAL_MONTHLY"];
            msg[@"$YEARLY"] = msg[@"$ORIGINAL_YEARLY"];
        }
        
        NSMutableDictionary *skusDetail = [NSMutableDictionary new];
        skusDetail[@"product"] = [s.product encodedObject];
        skusDetail[@"msg"] = msg;
        skusDetail[@"identifier"] = s.skuId;
        skusDetail[@"offeringid"] = s.offeringId;
        skusDetail[@"promotionalid"] = s.promotionalId;
        skusDetail[@"introductoryeligibility"] = @(s.introductoryEligibility);
        skusDetail[@"promotionaleligibility"] = @(s.promotionalEligibility);
        skusDetail[@"extravars"] = s.extravars;
        
        skusDetails[s.skuId] = skusDetail;
    }

    // Add discount towards other skus
    for (int i = 0; i < self.skus.count; i++) {
        GYSku *sku = self.skus[i];
        
        int units = 1;
        if (@available(iOS 11.2, *)) {
            if (sku.product.subscriptionPeriod.numberOfUnits != 0) {
                units = (int) sku.product.subscriptionPeriod.numberOfUnits;
            }
        }
        float originalSkuPrice = sku.product.price.floatValue * priceCorrections[i].floatValue / units;

        for (int j = 0; j < self.skus.count; j++) {
            GYSku *otherSku = self.skus[j];
            
            units = 1;
            if (@available(iOS 11.2, *)) {
                if (otherSku.product.subscriptionPeriod.numberOfUnits != 0) {
                    units = (int) otherSku.product.subscriptionPeriod.numberOfUnits;
                }
            }
            float originalOtherSkuPrice = otherSku.product.price.floatValue * priceCorrections[j].floatValue / units;
            
            float discount = 0.0f;
            if (originalSkuPrice > 0 && originalOtherSkuPrice > 0) {
                discount = 1.0f - originalSkuPrice / originalOtherSkuPrice;
            }
            
            NSString *key = [NSString stringWithFormat:@"$ORIGINAL_DISCOUNT_%d", j+1];
            skusDetails[sku.skuId][@"msg"][key] = [GYFormatter formatPercentage:@(discount) locale:self.locale];
        }
    }
    
    NSString *uiStyle = @"light";
    if (@available(iOS 13.0, *)) {
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            uiStyle = @"dark";
        }
    }
    
    NSDictionary *settings = @{
        @"pwid": self.pwid,
        @"locale": self.locale.languageCode,
        @"uiStyle": uiStyle
    };
    
    return @{@"skus": skusDetails, @"msg": commonMsg, @"settings": settings};
}

- (NSString *)formatPrice:(NSNumber *)price locale:(NSLocale *)locale
{
    if (price.floatValue == 0.0f) {
        return @"$GL_FREE"; // will be translated by js
    }
    return [GYFormatter formatPrice:price locale:locale];
}

@end

#endif
