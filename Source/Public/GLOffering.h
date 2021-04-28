//
//  GLOffering.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import <Foundation/Foundation.h>
@class GLSku;


NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.Offering)
@interface GLOffering : NSObject
@property(nullable, readonly, strong) NSString *name;
@property(readonly, strong) NSString *identifier;
@property(readonly, strong) NSArray<GLSku*> *skus;
@end

NS_ASSUME_NONNULL_END
