//
//  GLOfferings.h
//  Glassfy
//
//  Created by Luca Garbolino on 23/02/21.
//

#import <Foundation/Foundation.h>
@class GLOffering;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.Offerings)
@interface GLOfferings : NSObject
@property(nonatomic, readonly) NSArray<GLOffering*> *all;
@end

NS_ASSUME_NONNULL_END
