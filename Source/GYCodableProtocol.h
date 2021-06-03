//
//  GYCodableProtocol.h
//  Glassfy
//
//  Created by Luca Garbolino on 22/12/20.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol GYDecodeProtocol <NSObject>
- (instancetype _Nullable)initWithObject:(NSDictionary *)obj error:(NSError ** _Nullable)error;
@end

@protocol GYEncodeProtocol <NSObject>
- (id)encodedObject;
@end

NS_ASSUME_NONNULL_END
