//
//  GYSku+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 11/01/21.
//

#import "GYSku.h"
#import "GYCodableProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GYSku (Private) <GYDecodeProtocol, GYEncodeProtocol>
+ (instancetype)skuWithProduct:(SKProduct *)product;

@property(nonatomic, strong) NSString *skuId;
@property(nonatomic, strong) NSString *productId;
@property(nonatomic, nullable, strong) NSString *promotionalId;
@property(nonatomic, nullable, strong) NSString *offeringId;
@property(nonatomic, assign) GYSkuEligibility introductoryEligibility;
@property(nonatomic, assign) GYSkuEligibility promotionalEligibility;
@property(nonatomic, strong) NSDictionary<NSString*, NSString*>* extravars;
@property(nonatomic, nullable, strong) SKProduct *product;
@end

NS_ASSUME_NONNULL_END
