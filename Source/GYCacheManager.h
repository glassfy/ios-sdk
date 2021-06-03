//
//  GYCacheManager.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface GYCacheManager : NSObject
@property(nonatomic, readonly) NSString *installationId;

+ (void)resetIds;
@end

NS_ASSUME_NONNULL_END
