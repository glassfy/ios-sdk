//
//  GLAPIPermissionsResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 07/01/21.
//

#import <Foundation/Foundation.h>
#import "GLAPIBaseResponse.h"
@class GLPermission;


NS_ASSUME_NONNULL_BEGIN

@interface GLAPIPermissionsResponse: GLAPIBaseResponse
@property(nonatomic, strong) NSArray<GLPermission *> *permissions;
@property(nonatomic, strong) NSString *originalApplicationVersion;
@property(nonatomic, strong) NSDate *originalApplicationDate;
@end

NS_ASSUME_NONNULL_END
