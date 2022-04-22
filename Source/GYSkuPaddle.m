//
//  GYSkuPaddle.m
//  Glassfy
//
//  Created by Luca Garbolino on 22/04/22.
//

#import "GYSkuPaddle+Private.h"
#import "GYSkuBase+Private.h"
#import "GYError.h"
#import "SKProduct+GYEncode.h"
#import "GYUtils.h"

@interface GYSkuPaddle()
@property(nonatomic, strong) NSString *name;

@property(nonatomic, strong) NSDecimalNumber *initialPrice;
@property(nonatomic, strong) NSLocale *initialPriceLocale;
@property(nonatomic, strong) NSString *initialPriceCode;        // three-letter ISO currency code

@property(nonatomic, strong) NSDecimalNumber *recurringPrice;
@property(nonatomic, strong) NSLocale *recurringPriceLocale;
@property(nonatomic, strong) NSString *recurringPriceCode;      // three-letter ISO currency code
@end

@implementation GYSkuPaddle (Private)

- (instancetype)initWithObject:(nonnull NSDictionary *)obj error:(NSError **)error {
    self = [super initWithObject:obj error:error];
    if (self) {
        NSString *name;
        if ([obj[@"name"] isKindOfClass:NSString.class]) {
            name = obj[@"name"];
        }
        
        NSLocale *initialPriceLocale;
        NSString *initialPriceCode;
        NSDecimalNumber *initialPrice;
        NSDictionary *initialPriceJSON = obj[@"initialprice"];
        if ([initialPriceJSON isKindOfClass:NSDictionary.class]) {
            NSNumber *price = initialPriceJSON[@"price"];
            if ([price isKindOfClass:NSNumber.class]) {
                initialPrice = [NSDecimalNumber decimalNumberWithDecimal:price.decimalValue];
            }
            
            if ([initialPriceJSON[@"locale"] isKindOfClass:NSString.class]) {
                initialPriceCode = initialPriceJSON[@"locale"];
                initialPriceLocale = [GYUtils localeFromCurrencyCode:initialPriceCode];
            }
        }
        
        NSLocale *recurringPriceLocale;
        NSString *recurringPriceCode;
        NSDecimalNumber *recurringPrice;
        NSDictionary *recurringPriceJSON = obj[@"recurringprice"];
        if ([recurringPriceJSON isKindOfClass:NSDictionary.class]) {
            NSNumber *price = recurringPriceJSON[@"price"];
            if ([price isKindOfClass:NSNumber.class]) {
                recurringPrice = [NSDecimalNumber decimalNumberWithDecimal:price.decimalValue];
            }
            
            if ([recurringPriceJSON[@"locale"] isKindOfClass:NSString.class]) {
                recurringPriceCode = recurringPriceJSON[@"locale"];
                recurringPriceLocale = [GYUtils localeFromCurrencyCode:recurringPriceCode];
            }
        }
        
        if (initialPriceCode && initialPriceCode.length) {
            self.initialPrice = initialPrice;
            self.initialPriceCode = initialPriceCode;
            self.initialPriceLocale = initialPriceLocale;
        }
        
        if (recurringPriceCode && recurringPriceCode.length) {
            self.recurringPrice = recurringPrice;
            self.recurringPriceCode = recurringPriceCode;
            self.recurringPriceLocale = recurringPriceLocale;
        }
        
        self.name = name;
    }
    return self;
}


@end

@implementation GYSkuPaddle

@end
