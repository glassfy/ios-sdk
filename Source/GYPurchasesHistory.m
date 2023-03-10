//
//  GYPurchasesHistory.m
//  Glassfy
//
//  Created by Luca Garbolino on 06/03/23.
//

#import "GYPurchaseHistory+Private.h"
#import "GYPurchasesHistory+Private.h"
#import "GYAPIPurchaseHistoryResponse.h"

@interface GYPurchasesHistory()
@property(nonatomic, readwrite, strong) NSArray<GYPurchaseHistory*> *all;
@property(nonatomic, readwrite, strong) NSString *subscriberId;
@property(nonatomic, readwrite, strong, nullable) NSString *customId;
@end

@implementation GYPurchasesHistory (Private)

+ (instancetype)purchasesHistoryWithResponse:(GYAPIPurchaseHistoryResponse *)response
{
    GYPurchasesHistory *history = [[self alloc] init];
    history.all = response.purchasesHistory ?: @[];
    history.subscriberId = response.subscriberId;
    history.customId = response.customId;
    
    return history;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.all = @[];
    }
    return self;
}

@end


@implementation GYPurchasesHistory
@end
