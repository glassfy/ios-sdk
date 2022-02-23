//
//  GYTransaction.h
//  Glassfy
//
//  Created by Luca Garbolino on 24/12/20.
//

#import <Foundation/Foundation.h>
@class SKPaymentTransaction;
@class GYPermissions;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.Transaction)
@interface GYTransaction : NSObject
@property(nonatomic, readonly) BOOL receiptValidated;
@property(nonatomic, readonly) GYPermissions *permissions;

@property(nonatomic, readonly) NSString *productId;
@property(nonatomic, readonly, nullable) NSString *promotionalId API_AVAILABLE(ios(12.2), macos(10.14.4), watchos(6.2));

@property(nonatomic, readonly) SKPaymentTransaction *paymentTransaction;


/// Deprecations
@property(nonatomic, readonly) NSString *productIdentifier __attribute__((deprecated("Renamed to productId:")));
@end

NS_ASSUME_NONNULL_END
