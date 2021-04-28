//
//  GLTransaction.h
//  Glassfy
//
//  Created by Luca Garbolino on 24/12/20.
//

#import <Foundation/Foundation.h>
@class SKPaymentTransaction;
@class GLPermission;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.Transaction)
@interface GLTransaction : NSObject
@property(nonatomic, readonly) SKPaymentTransaction *paymentTransaction;
@property(nonatomic, readonly) NSString *productIdentifier;
@property(nonatomic, readonly) BOOL receiptValidated;
@property(nonatomic, readonly) NSArray<GLPermission *> *permissions;
@end

NS_ASSUME_NONNULL_END
