//
//  GYOfferings.h
//  Glassfy
//
//  Created by Luca Garbolino on 23/02/21.
//

#import <Foundation/Foundation.h>
@class GYOffering;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.Offerings)
@interface GYOfferings : NSObject
@property(nonatomic, readonly) NSArray<GYOffering*> *all;

// Custom Keyed Subscripting method
- (nullable GYOffering *)objectForKeyedSubscript:(NSString *)offeringid;
@end

NS_ASSUME_NONNULL_END
