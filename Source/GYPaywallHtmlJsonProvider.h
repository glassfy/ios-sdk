//
//  GYPaywallHtmlJsonProvider.h
//  Glassfy
//
//  Created by Federico Curzel on 10/05/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface GYPaywallHtmlJsonProvider: NSObject
+ (NSDictionary *)jsonWithPwid:(NSString *)pwid
                        locale:(NSLocale * _Nullable)locale
                       uiStyle:(NSString *)uiStyle
                          skus:(NSArray *)skus;
@end
NS_ASSUME_NONNULL_END
