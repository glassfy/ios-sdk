//
//  SKProductSubscriptionPeriod+Encode.m
//  Glassfy
//
//  Created by Luca Garbolino on 22/12/20.
//

#import "SKProductSubscriptionPeriod+GYEncode.h"

@implementation SKProductSubscriptionPeriod (GYEncode)

API_AVAILABLE(ios(11.2), macos(10.13.2), watchos(6.2))
NSString * GYProductPeriodUnit(SKProductPeriodUnit unit) {
    NSString *productUnitStr;
    switch (unit) {
        case SKProductPeriodUnitDay:
            productUnitStr = @"day";
            break;
        case SKProductPeriodUnitWeek:
            productUnitStr = @"week";
            break;
        case SKProductPeriodUnitMonth:
            productUnitStr = @"month";
            break;
        case SKProductPeriodUnitYear:
            productUnitStr = @"year";
            break;
        default:
            productUnitStr = @"unknow";
    }
    return productUnitStr;
};

- (id)encodedObject
{
    NSMutableDictionary *periodInfo = [NSMutableDictionary dictionary];
    
    periodInfo[@"numberofunits"] = @(self.numberOfUnits);
    periodInfo[@"unit"] = GYProductPeriodUnit(self.unit);
    
    return periodInfo;
}

@end
