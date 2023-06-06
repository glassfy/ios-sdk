//
//  GYPaywallHtmlJsonProvider.h
//  Glassfy
//
//  Created by Federico Curzel on 10/05/23.
//

#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>
#import "Glassfy+Private.h"
#import "GYFormatter.h"
#import "GYPaywallHtmlJsonProvider.h"
#import "GYSku+Private.h"
#import "GYSysInfo.h"
#import "SKProduct+GYEncode.h"

@implementation GYPaywallHtmlJsonProvider
+ (NSDictionary *)jsonWithPwid:(NSString *)pwid
                        locale:(NSLocale * _Nullable)locale
                       uiStyle:(NSString *)uiStyle
                          skus:(NSArray *)skus
{
    NSMutableDictionary *skusDetails = [NSMutableDictionary new];
    NSMutableDictionary *commonMsg = [NSMutableDictionary new];
    if (@available(iOS 11.2, *)) {
        commonMsg[@"DAY"] = [GYFormatter formatUnit:SKProductPeriodUnitDay locale:locale];
        commonMsg[@"WEEK"] = [GYFormatter formatUnit:SKProductPeriodUnitWeek locale:locale];
        commonMsg[@"MONTH"] = [GYFormatter formatUnit:SKProductPeriodUnitMonth locale:locale];
        commonMsg[@"YEAR"] = [GYFormatter formatUnit:SKProductPeriodUnitYear locale:locale];
    }
    
    NSMutableArray<NSNumber*> *priceCorrections = [NSMutableArray array];
    for (GYSku *s in skus) {
        SKProduct *p = s.product;
        
        NSMutableDictionary *msg = [NSMutableDictionary new];
        msg[@"TITLE"] = p.localizedTitle;
        msg[@"DESCRIPTION"] = p.localizedDescription;
        msg[@"ORIGINAL_PRICE"] = [self formatPrice:p.price locale:p.priceLocale];
        
        float priceCorrection = 1.0f;
        if (@available(iOS 11.2, *)) {
            float k = 1.0f;
            switch (p.subscriptionPeriod.unit) {
                case (SKProductPeriodUnitDay):
                    msg[@"ORIGINAL_PERIOD"] = commonMsg[@"DAY"];
                    k = 1.0f;
                    
                    break;
                case (SKProductPeriodUnitWeek):
                    msg[@"ORIGINAL_PERIOD"] = commonMsg[@"WEEK"];
                    k = 1.0f / 7.0f;
                    
                    break;
                case (SKProductPeriodUnitMonth):
                    msg[@"ORIGINAL_PERIOD"] = commonMsg[@"MONTH"];
                    k = 12.0f / 365.0f;
                    
                    break;
                case (SKProductPeriodUnitYear):
                    msg[@"ORIGINAL_PERIOD"] = commonMsg[@"YEAR"];
                    k = 1.0f / 365.0f;
                    
                    break;
            }
            priceCorrection = k;
            
            float priceDaily = p.price.floatValue * k / p.subscriptionPeriod.numberOfUnits;
            float priceWeekly = priceDaily * 7.0f;
            float priceYearly = priceDaily * 365.0f;
            float priceMonthly = priceYearly / 12.0f;
            
            msg[@"ORIGINAL_DURATION"] = [GYFormatter formatPeriod:p.subscriptionPeriod.numberOfUnits unit:p.subscriptionPeriod.unit locale:locale];
            
            msg[@"ORIGINAL_DAILY"] = [self formatPrice:@(priceDaily) locale:p.priceLocale];
            msg[@"ORIGINAL_WEEKLY"] = [self formatPrice:@(priceWeekly) locale:p.priceLocale];
            msg[@"ORIGINAL_MONTHLY"] = [self formatPrice:@(priceMonthly) locale:p.priceLocale];
            msg[@"ORIGINAL_YEARLY"] = [self formatPrice:@(priceYearly) locale:p.priceLocale];
            
            if (p.introductoryPrice) {
                float k = 1.0f;
                switch (p.introductoryPrice.subscriptionPeriod.unit) {
                    case (SKProductPeriodUnitDay):
                        msg[@"INTRO_PERIOD"] = commonMsg[@"DAY"];
                        k = 1.0f;
                        
                        break;
                    case (SKProductPeriodUnitWeek):
                        msg[@"INTRO_PERIOD"] = commonMsg[@"WEEK"];
                        k = 1.0f / 7.0f;
                        
                        break;
                    case (SKProductPeriodUnitMonth):
                        msg[@"INTRO_PERIOD"] = commonMsg[@"MONTH"];
                        k = 12.0f / 365.0f;
                        
                        break;
                    case (SKProductPeriodUnitYear):
                        msg[@"INTRO_PERIOD"] = commonMsg[@"YEAR"];
                        k = 1.0f / 365.0f;
                        
                        break;
                }
                
                float introDaily = p.introductoryPrice.price.floatValue * k / p.introductoryPrice.subscriptionPeriod.numberOfUnits;
                float introWeekly = introDaily * 7.0f;
                float introYearly = introDaily * 365.0f;
                float introMonthly = introYearly / 12.0f;
                float introDiscount = introDaily / priceDaily;
                
                msg[@"INTRO_PRICE"] = [self formatPrice:p.introductoryPrice.price locale:p.introductoryPrice.priceLocale];
                msg[@"INTRO_DURATION"] = [GYFormatter formatPeriod:p.introductoryPrice.subscriptionPeriod.numberOfUnits
                                                              unit:p.introductoryPrice.subscriptionPeriod.unit
                                                            locale:locale];
                
                msg[@"INTRO_DAILY"] = [self formatPrice:@(introDaily) locale:p.introductoryPrice.priceLocale];
                msg[@"INTRO_WEEKLY"] = [self formatPrice:@(introWeekly) locale:p.introductoryPrice.priceLocale];
                msg[@"INTRO_MONTHLY"] = [self formatPrice:@(introMonthly) locale:p.introductoryPrice.priceLocale];
                msg[@"INTRO_YEARLY"] = [self formatPrice:@(introYearly) locale:p.introductoryPrice.priceLocale];
                
                msg[@"INTRO_DISCOUNT"] = [GYFormatter formatPercentage:@(introDiscount) locale:locale];
            }
            
            if (s.promotionalId) {
                NSPredicate *p = [NSPredicate predicateWithFormat:@"identifier = %@", s.promotionalId];
                if (@available(iOS 12.2, *)) {
                    SKProductDiscount *promo = [[s.product.discounts filteredArrayUsingPredicate:p] firstObject];
                    
                    if (promo) {
                        float k = 1.0f;
                        switch (promo.subscriptionPeriod.unit) {
                            case (SKProductPeriodUnitDay):
                                msg[@"PROMO_PERIOD"] = commonMsg[@"DAY"];
                                k = 1.0f;
                                
                                break;
                            case (SKProductPeriodUnitWeek):
                                msg[@"PROMO_PERIOD"] = commonMsg[@"WEEK"];
                                k = 1.0f / 7.0f;
                                
                                break;
                            case (SKProductPeriodUnitMonth):
                                msg[@"PROMO_PERIOD"] = commonMsg[@"MONTH"];
                                k = 12.0f / 365.0f;
                                
                                break;
                            case (SKProductPeriodUnitYear):
                                msg[@"PROMO_PERIOD"] = commonMsg[@"YEAR"];
                                k = 1.0f / 365.0f;
                                
                                break;
                        }
                        
                        float promoDaily = promo.price.floatValue * k / promo.subscriptionPeriod.numberOfUnits;
                        float promoWeekly = promoDaily * 7.0f;
                        float promoYearly = promoDaily * 365.0f;
                        float promoMonthly = promoYearly / 12.0f;
                        float promoDiscount = promoDaily / priceDaily;
                        
                        msg[@"PROMO_PRICE"] = [self formatPrice:promo.price locale:promo.priceLocale];
                        msg[@"PROMO_DURATION"] = [GYFormatter formatPeriod:promo.subscriptionPeriod.numberOfUnits
                                                                      unit:promo.subscriptionPeriod.unit
                                                                    locale:locale];
                        
                        msg[@"PROMO_DAILY"] = [self formatPrice:@(promoDaily) locale:promo.priceLocale];
                        msg[@"PROMO_WEEKLY"] = [self formatPrice:@(promoWeekly) locale:promo.priceLocale];
                        msg[@"PROMO_MONTHLY"] = [self formatPrice:@(promoMonthly) locale:promo.priceLocale];
                        msg[@"PROMO_YEARLY"] = [self formatPrice:@(promoYearly) locale:promo.priceLocale];
                        
                        msg[@"PROMO_DISCOUNT"] = [GYFormatter formatPercentage:@(promoDiscount) locale:locale];
                    }
                }
            }
        }
        [priceCorrections addObject:@(priceCorrection)];
        
        if (s.promotionalEligibility == GYSkuEligibilityEligible && msg[@"PROMO_PRICE"]) {
            msg[@"PERIOD"] = msg[@"PROMO_PERIOD"];
            msg[@"PRICE"] = msg[@"PROMO_PRICE"];
            msg[@"DURATION"] = msg[@"PROMO_DURATION"];
            msg[@"DAILY"] = msg[@"PROMO_DAILY"];
            msg[@"WEEKLY"] = msg[@"PROMO_WEEKLY"];
            msg[@"MONTHLY"] = msg[@"PROMO_MONTHLY"];
            msg[@"YEARLY"] = msg[@"PROMO_YEARLY"];
            msg[@"DISCOUNT"] = msg[@"PROMO_DISCOUNT"];
        } else if (s.introductoryEligibility == GYSkuEligibilityEligible && msg[@"INTRO_PRICE"]) {
            msg[@"PERIOD"] = msg[@"INTRO_PERIOD"];
            msg[@"PRICE"] = msg[@"INTRO_PRICE"];
            msg[@"DURATION"] = msg[@"INTRO_DURATION"];
            msg[@"DAILY"] = msg[@"INTRO_DAILY"];
            msg[@"WEEKLY"] = msg[@"INTRO_WEEKLY"];
            msg[@"MONTHLY"] = msg[@"INTRO_MONTHLY"];
            msg[@"YEARLY"] = msg[@"INTRO_YEARLY"];
            msg[@"DISCOUNT"] = msg[@"INTRO_DISCOUNT"];
        } else {
            msg[@"PERIOD"] = msg[@"ORIGINAL_PERIOD"];
            msg[@"PRICE"] = msg[@"ORIGINAL_PRICE"];
            msg[@"DURATION"] = msg[@"ORIGINAL_DURATION"];
            msg[@"DAILY"] = msg[@"ORIGINAL_DAILY"];
            msg[@"WEEKLY"] = msg[@"ORIGINAL_WEEKLY"];
            msg[@"MONTHLY"] = msg[@"ORIGINAL_MONTHLY"];
            msg[@"YEARLY"] = msg[@"ORIGINAL_YEARLY"];
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
    for (int i = 0; i < skus.count; i++) {
        GYSku *sku = skus[i];
        
        int units = 1;
        if (@available(iOS 11.2, *)) {
            if (sku.product.subscriptionPeriod.numberOfUnits != 0) {
                units = (int) sku.product.subscriptionPeriod.numberOfUnits;
            }
        }
        float originalSkuPrice = sku.product.price.floatValue * priceCorrections[i].floatValue / units;
        
        for (int j = 0; j < skus.count; j++) {
            GYSku *otherSku = skus[j];
            
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
            
            NSString *key = [NSString stringWithFormat:@"ORIGINAL_DISCOUNT_%d", j+1];
            skusDetails[sku.skuId][@"msg"][key] = [GYFormatter formatPercentage:@(discount) locale:locale];
        }
    }
    
    NSDictionary *settings = @{
        @"pwid": pwid,
        @"locale": locale.languageCode,
        @"uiStyle": uiStyle,
        @"sdkVersion": Glassfy.sdkVersion,
        @"appVersion": GYSysInfo.appVersion,
        @"subplatform": @(GYSysInfo.subplatform),
        @"store": @(GYStoreAppStore),
        @"systemVersion": GYSysInfo.systemVersion,
        @"sysInfo": GYSysInfo.sysInfo
    };
    
    return @{@"gy": @{@"skus": skusDetails, @"msg": commonMsg, @"settings": settings}};
}

+ (NSString *)formatPrice:(NSNumber *)price locale:(NSLocale *)locale
{
    if (price.floatValue == 0.0f) {
        return @"$GL_FREE"; // will be translated by js
    }
    return [GYFormatter formatPrice:price locale:locale];
}

@end
