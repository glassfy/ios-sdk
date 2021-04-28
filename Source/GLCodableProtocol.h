//
//  GLCodableProtocol.h
//  Glassfy
//
//  Created by Luca Garbolino on 22/12/20.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol GLDecodeProtocol <NSObject>
- (instancetype _Nullable)initWithObject:(NSDictionary *)obj error:(NSError ** _Nullable)error;
@end

@protocol GLEncodeProtocol <NSObject>
- (id)encodedObject;
@end

NS_ASSUME_NONNULL_END
