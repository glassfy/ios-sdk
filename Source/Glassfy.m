//
//  Glassfy.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//


#import "Glassfy.h"
#import "GLManager.h"
#import "GLLogger.h"

@interface Glassfy()
@property (nonnull, nonatomic, strong) dispatch_queue_t glqueue;
@property (nullable, nonatomic, strong) GLManager *manager;
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
    return @"1.1.2";
}

+ (void)initializeWithAPIKey:(NSString *)apiKey
{
    [self initializeWithAPIKey:apiKey completion:nil];
}

+ (void)initializeWithAPIKey:(NSString *)apiKey completion:(GLErrorCompletion)block
{
    [self initializeWithAPIKey:apiKey userId:nil completion:block];
}

+ (void)initializeWithAPIKey:(NSString *)apiKey userId:(NSString *)userId completion:(GLErrorCompletion)block
{
    [self initializeWithAPIKey:apiKey userId:userId watcherMode:NO completion:block];
}

+ (void)initializeWithAPIKey:(NSString *)apiKey userId:(NSString *_Nullable)userId watcherMode:(BOOL)watcherMode completion:(GLErrorCompletion _Nullable)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        Glassfy.shared.manager = [GLManager managerWithApiKey:apiKey userId:userId watcherMode:watcherMode completion:block];
    });
}

+ (void)setUserId:(NSString *)userId
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        Glassfy.shared.manager.userId = userId;
    });
}

+ (void)logoutWithCompletion:(GLErrorCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager logoutWithCompletion:block];
    });
}

+ (void)permissionsWithCompletion:(GLPermissionsCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager permissionsWithCompletion:block];
    });
}

+ (void)permissionWithIdentifier:(NSString *)identifier completion:(GLPermissionsCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager permissionWithIdentifier:identifier completion:block];
    });
}

+ (void)offeringsWithCompletion:(GLOfferingsCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager offeringsWithCompletion:block];
    });
}

+ (void)offeringWithIdentifier:(NSString *)identifier completion:(GLOfferingsCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager offeringWithIdentifier:identifier completion:block];
    });
}

+ (void)purchaseSku:(GLSku *)sku completion:(GLPaymentTransactionBlock)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager purchaseSku:sku completion:block];
    });
}

+ (void)purchase:(NSString *)productId completion:(GLPaymentTransactionBlock)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager purchase:productId completion:block];
    });
}

+ (void)purchaseProduct:(SKProduct *)product completion:(GLPaymentTransactionBlock)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager purchaseProduct:product completion:block];
    });
}

+ (void)purchaseProduct:(SKProduct *)product withDiscount:(SKProductDiscount *)discount completion:(GLPaymentTransactionBlock)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager purchaseProduct:product withDiscount:discount completion:block];
    });
}

+ (void)restorePurchasesWithCompletion:(GLPermissionsCompletion)block
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        [Glassfy.shared.manager restorePurchasesWithCompletion:block];
    });
}

+ (void)setLogLevel:(GLLogLevel)level
{
    dispatch_async(Glassfy.shared.glqueue, ^{
        GLLogSetLevel(level);
    });
}

@end
