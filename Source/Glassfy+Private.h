//
//  Glassfy+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import "Glassfy.h"


NS_ASSUME_NONNULL_BEGIN

@interface Glassfy (Private)
@property (class, readonly) Glassfy *shared;
@property (readonly) dispatch_queue_t glqueue;
@end

NS_ASSUME_NONNULL_END
