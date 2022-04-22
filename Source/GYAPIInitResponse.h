//
//  GYAPIInitResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 21/12/20.
//

#import <Foundation/Foundation.h>
#import "GYAPIBaseResponse.h"
@class GYSku;


NS_ASSUME_NONNULL_BEGIN

@interface GYAPIInitResponse: GYAPIBaseResponse
@property(nonatomic, strong) NSArray<GYSku*> *skus;
@property(nonatomic, assign) BOOL hasReceipt;
@end

NS_ASSUME_NONNULL_END
