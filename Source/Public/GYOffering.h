//
//  GYOffering.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <Foundation/Foundation.h>
@class GYSku;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.Offering)
@interface GYOffering : NSObject
@property(readonly, strong) NSString *offeringId;
@property(readonly, strong) NSArray<GYSku*> *skus;


/// Deprecations
@property(nonatomic, readonly) NSString *identifier __attribute__((deprecated("Renamed to offeringId")));

@end

NS_ASSUME_NONNULL_END
