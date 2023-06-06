//
//  Glassfy.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//


#import "Glassfy.h"
#import "GYManager.h"
#import "GYLogger.h"

@interface Glassfy()
@property (nonnull, nonatomic, strong) dispatch_queue_t glqueue;
@property (nullable, nonatomic, strong) GYManager *manager;
@end

@implementation Glassfy

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.glqueue = dispatch_queue_create("com.glassfy.sdk", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (Glassfy *)shared
{
    static Glassfy *sharedInstance = nil;
    static dispatch_once_t initOnceToken;
    dispatch_once(&initOnceToken, ^{
        sharedInstance = [[Glassfy alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public methods

+ (NSString *)sdkVersion
{
    return @"1.4.0";
}

+ (void)initializeWithAPIKey:(NSString *)apiKey
{
    [self initializeWithAPIKey:apiKey watcherMode:NO];
}

+ (void)initializeWithAPIKey:(NSString *)apiKey watcherMode:(BOOL)watcherMode
{
    GYInitializeOptions *opt = [GYInitializeOptions initializeOptionsWithAPIKey:apiKey];
    opt.watcherMode = watcherMode;
    
    [self initializeWithOptions:opt];
}

+ (void)initializeWithOptions:(GYInitializeOptions *)options
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        Glassfy.shared.manager = [GYManager managerWithOptions:options];
    });
}

+ (void)loginUser:(NSString *_Nullable)userId withCompletion:(GYErrorCompletion _Nullable)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager loginUser:userId withCompletion:block];
    });
}

+ (void)logoutWithCompletion:(GYErrorCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager logoutWithCompletion:block];
    });
}

+ (void)permissionsWithCompletion:(GYPermissionsCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager permissionsWithCompletion:block];
    });
}

+ (void)offeringsWithCompletion:(GYOfferingsCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager offeringsWithCompletion:block];
    });
}

+ (void)skuWithId:(NSString *)skuid completion:(GYSkuBlock)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager skuWithId:skuid completion:block];
    });
}

+ (void)skuWithProductId:(NSString *)productid promotionalId:(NSString *)promoid completion:(GYSkuBlock)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager skuWithProductId:productid promotionalId:promoid completion:block];
    });
}

+ (void)skuWithId:(NSString *)skuid store:(GYStore)store completion:(GYSkuBaseCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager skuWithId:skuid store:store completion:block];
    });
}

+ (void)purchaseSku:(GYSku *)sku completion:(GYPaymentTransactionBlock)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager purchaseSku:sku completion:block];
    });
}

+ (void)purchaseSku:(GYSku *)sku withDiscount:(SKProductDiscount *)discount completion:(GYPaymentTransactionBlock)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager purchaseSku:sku withDiscount:discount completion:block];
    });
}

+ (void)restorePurchasesWithCompletion:(GYPermissionsCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager restorePurchasesWithCompletion:block];
    });
}

+ (void)setEmailUserProperty:(NSString *)email completion:(GYErrorCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager setEmailUserProperty:email completion:block];
    });
}

+ (void)setDeviceToken:(NSString *_Nullable)deviceToken completion:(GYErrorCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager setDeviceToken:deviceToken completion:block];
    });
}

+ (void)setExtraUserProperty:(NSDictionary *)extra completion:(GYErrorCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager setExtraUserProperty:extra completion:block];
    });
}

+ (void)getUserProperties:(GYUserPropertiesCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager getUserProperties:block];
    });
}

+ (void)paywallWithRemoteConfigurationId:(NSString *)remoteConfigId
                              completion:(GYPaywallCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager paywallWithRemoteConfigurationId:remoteConfigId
                                                      completion:block];
    });
}

+ (void)paywallViewControllerWithRemoteConfigurationId:(NSString *)remoteConfigId
                                           completion:(GYPaywallViewControllerCompletion)block
{
    [self paywallViewControllerWithRemoteConfigurationId:remoteConfigId
                                            awaitLoading:false
                                              completion:block];
}

+ (void)paywallViewControllerWithRemoteConfigurationId:(NSString *)remoteConfigId
                                          awaitLoading:(BOOL)awaitLoading
                                            completion:(GYPaywallViewControllerCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager paywallViewControllerWithRemoteConfigurationId:remoteConfigId
                                                                  awaitLoading:awaitLoading
                                                                    completion:block];
    });
}

+ (void)setLogLevel:(GYLogLevel)level
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        GYLogSetLevel(level);
    });
}

+ (void)setPurchaseDelegate:(id<GYPurchaseDelegate>)delegate
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager setPurchaseDelegate:delegate];
    });
}

+ (void)connectPaddleLicenseKey:(NSString *)licenseKey completion:(GYErrorCompletion)block
{
    [self connectPaddleLicenseKey:licenseKey force:NO completion:block];
}

+ (void)connectPaddleLicenseKey:(NSString *)licenseKey force:(BOOL)force completion:(GYErrorCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager connectPaddleLicenseKey:licenseKey force:force completion:block];
    });
}

+ (void)connectCustomSubscriber:(NSString *_Nullable)customId completion:(GYErrorCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager connectCustomSubscriber:customId completion:block];
    });
}

+ (void)storeInfo:(GYStoreCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager storeInfo:block];
    });
}

+ (void)setAttributionWithType:(GYAttributionType)type value:(NSString *)value completion:(GYErrorCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager setAttributionWithType:type value:value completion:block];
    });
}

+ (void)setAttributions:(NSArray<GYAttributionItem*> *)attributions completion:(GYErrorCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager setAttributions:attributions completion:block];
    });
}

+ (void)purchaseHistoryWithCompletion:(GYPurchaseHistoryCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager purchaseHistoryWithCompletion:block];
    });
}

+ (void)connectGlassfyUniversalCode:(NSString*)universalCode
                              force:(BOOL)force
                     withCompletion:(GYErrorCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager connectGlassfyUniversalCode:universalCode
                                                      force:force
                                             withCompletion:block];
    });
}

#pragma mark - Deprecations

+ (void)skuWithIdentifier:(NSString *)skuid completion:(GYSkuBlock)block
{
    [self skuWithId:skuid completion:block];
}

+ (void)paywallWithId:(NSString *)paywallid completion:(GYPaywallViewControllerCompletion)block
{
    [self paywallViewControllerWithRemoteConfigurationId:paywallid completion:block];
}

@end
