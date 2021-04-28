//
//  GLCacheManager.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface GLCacheManager : NSObject
@property(nonatomic, nullable, strong) NSString *userId;
@property(nonatomic, readonly) NSString *installationId;

- (instancetype)initWithUserId:(nullable NSString *)userId;
+ (void)resetIds;
@end

NS_ASSUME_NONNULL_END
