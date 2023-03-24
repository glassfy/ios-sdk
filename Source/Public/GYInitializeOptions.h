//
//  GYInitializeOptions.h
//  Glassfy
//
//  Created by Luca Garbolino on 23/03/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.InitializeOptions)
@interface GYInitializeOptions : NSObject

@property(nonatomic, assign) BOOL watcherMode;
@property(nonatomic, readonly, strong) NSString *apiKey;
@property(nonatomic, strong, nullable) NSString *crossPlatformSdkFramework;
@property(nonatomic, strong, nullable) NSString *crossPlatformSdkVersion;

+ (instancetype)initializeOptionsWithAPIKey:(NSString *)apiKey;

- (GYInitializeOptions *)watcherMode:(BOOL)mode;

- (GYInitializeOptions *)crossPlatformSdkFramework:(NSString *_Nullable)framework;
- (GYInitializeOptions *)crossPlatformSdkVersion:(NSString *_Nullable)version;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
