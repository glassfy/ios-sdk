//
//  GYStoreInfo+Private.h.h
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import "GYStoresInfo.h"
#import "GYCodableProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GYStoresInfo (Private) <GYDecodeProtocol>
+ (instancetype)storesInfoWithResponse:(GYAPIStoreInfoResponse *_Nullable)response;
@end

NS_ASSUME_NONNULL_END
