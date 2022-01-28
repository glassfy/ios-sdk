//
//  GYFormatter.m
//  Glassfy
//
//  Created by Luca Garbolino on 27/10/21.
//

#import "GYFormatter.h"
#import "SKProduct+GYEncode.h"

@implementation GYFormatter

+ (NSString *)formatPrice:(NSNumber *)price locale:(NSLocale *)locale
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = locale;
    
    NSString *formattedPrice = [formatter stringFromNumber:price];
    return formattedPrice ?: [price stringValue];
}

+ (NSString *)formatPercentage:(NSNumber *)percentage locale:(NSLocale *)locale
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    formatter.numberStyle = NSNumberFormatterPercentStyle;
    formatter.minimumIntegerDigits = 1;
    formatter.maximumFractionDigits = 0;
    formatter.locale = locale;
    
    return [formatter stringFromNumber:percentage] ?: [percentage stringValue];
}

+ (NSString *)formatPeriod:(NSInteger)perdiod unit:(SKProductPeriodUnit)unit locale:(NSLocale *)locale
{
    NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
    formatter.maximumUnitCount = 1;
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
    formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropAll;
    
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.calendar = [NSCalendar calendarWithIdentifier:locale.calendarIdentifier];
    
    NSCalendarUnit calendarUnit;
    switch (unit) {
        case SKProductPeriodUnitDay:
            calendarUnit = NSCalendarUnitDay;
            break;
        case SKProductPeriodUnitWeek:
            calendarUnit = NSCalendarUnitWeekOfMonth;
            break;
        case SKProductPeriodUnitMonth:
            calendarUnit = NSCalendarUnitMonth;
            break;
        case SKProductPeriodUnitYear:
            calendarUnit = NSCalendarUnitYear;
            break;
    }
    formatter.allowedUnits = calendarUnit;
    
    [dateComponents setValue:perdiod forComponent:calendarUnit];
    
    return [formatter stringFromDateComponents:dateComponents];
}

+ (NSString *)formatUnit:(SKProductPeriodUnit)unit locale:(NSLocale *)locale
{
    NSString *unitStr = [self formatPeriod:1 unit:unit locale:locale];
    unitStr = [unitStr stringByTrimmingCharactersInSet:NSCharacterSet.letterCharacterSet.invertedSet];
    
    return unitStr;
}

@end
