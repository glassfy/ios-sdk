//
//  GLSku.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <Foundation/Foundation.h>
@class SKProduct;

typedef NS_ENUM(NSUInteger, GLSkuEligibility) {
    GLSkuEligibilityEligible,
    GLSkuEligibilityNonEligible,
    GLSkuEligibilityUnknown
} NS_SWIFT_NAME(Glassfy.SkuEligibility);

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.Sku)
@interface GLSku : NSObject
@property(nonatomic, readonly) NSString *identifier;
@property(nonatomic, readonly) NSString *productId;
@property(nonatomic, readonly) GLSkuEligibility introductoryEligibility;
@property(nonatomic, readonly) GLSkuEligibility promotionalEligibility;
@property(nonatomic, readonly) NSDictionary<NSString*, NSString*>* extravars;
@property(nonatomic, readonly) SKProduct *product;
@end

NS_ASSUME_NONNULL_END
