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
@property(nullable, readonly, strong) NSString *name;
@property(readonly, strong) NSString *identifier;
@property(readonly, strong) NSArray<GYSku*> *skus;
@end

NS_ASSUME_NONNULL_END
