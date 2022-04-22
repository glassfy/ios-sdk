//
//  GYAPIOfferingsResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 21/12/20.
//

#import <Foundation/Foundation.h>
#import "GYAPIBaseResponse.h"
@class GYSku;
@class GYOffering;


NS_ASSUME_NONNULL_BEGIN

@interface GYAPIOfferingsResponse: GYAPIBaseResponse
@property(nonatomic, strong) NSArray<GYOffering*> *offerings;
@end

NS_ASSUME_NONNULL_END
