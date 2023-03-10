//
//  GYPurchaseHistory.m
//  Glassfy
//
//  Created by Luca Garbolino on 06/03/23.
//

#import "GYPurchaseHistory+Private.h"
#import "GYError.h"

@interface GYPurchaseHistory()
@property(nonatomic, readwrite, strong) NSString *productId;
@property(nonatomic, readwrite, strong, nullable) NSString *skuId;

@property(nonatomic, readwrite, assign) GYEventType type;
@property(nonatomic, readwrite, assign) GYStore store;

@property(nonatomic, readwrite, strong, nullable) NSDate *purchaseDate;
@property(nonatomic, readwrite, strong, nullable) NSDate *expireDate;

@property(nonatomic, readwrite, strong, nullable) NSString *transactionId;
@property(nonatomic, readwrite, strong, nullable) NSString *subscriberId;
@property(nonatomic, readwrite, strong, nullable) NSString *currencyCode;
@property(nonatomic, readwrite, strong, nullable) NSString *countryCode;

@property(nonatomic, readwrite, assign) BOOL isInIntroOfferPeriod;
@property(nonatomic, readwrite, strong, nullable) NSString *promotionalOfferId;
@property(nonatomic, readwrite, strong, nullable) NSString *offerCodeRefName;
@property(nonatomic, readwrite, strong, nullable) NSString *licenseCode;
@property(nonatomic, readwrite, strong, nullable) NSString *webOrderLineItemId;
@end

@implementation GYPurchaseHistory (Private)

- (instancetype)initWithObject:(NSDictionary *)purchaseJSON error:(NSError ** _Nullable)error
{
    self = [super init];
    if (self) {
        NSString *productid = purchaseJSON[@"productid"];
        if ([productid isKindOfClass:NSString.class] && productid.length) {
            self.productId = productid;
        }
        NSString *skuid = purchaseJSON[@"skuid"];
        if ([skuid isKindOfClass:NSString.class] && skuid.length) {
            self.skuId = skuid;
        }
        
        NSNumber *type = purchaseJSON[@"type"];
        if ([type isKindOfClass:NSNumber.class] && type.integerValue > 0) {
            self.type = type.integerValue;
        }
        NSString *store = purchaseJSON[@"store"];
        if ([store isKindOfClass:NSString.class] && store.integerValue > 0) {
            self.store = store.integerValue;
        }
        
        NSNumber *date_ms = purchaseJSON[@"date_ms"];
        if ([date_ms isKindOfClass:NSNumber.class] && date_ms.integerValue > 0) {
            self.purchaseDate = [NSDate dateWithTimeIntervalSince1970:(date_ms.integerValue/1000)];
        }
        NSNumber *expire_date_ms = purchaseJSON[@"expire_date_ms"];
        if ([expire_date_ms isKindOfClass:NSNumber.class] && expire_date_ms.integerValue > 0) {
            self.expireDate = [NSDate dateWithTimeIntervalSince1970:(expire_date_ms.integerValue/1000)];
        }
        
        NSString *transaction_id = purchaseJSON[@"transaction_id"];
        if ([transaction_id isKindOfClass:NSString.class] && transaction_id.length) {
            self.transactionId = transaction_id;
        }
        NSString *subscriberid = purchaseJSON[@"subscriberid"];
        if ([subscriberid isKindOfClass:NSString.class] && subscriberid.length) {
            self.subscriberId = subscriberid;
        }
        NSString *currency_code = purchaseJSON[@"currency_code"];
        if ([currency_code isKindOfClass:NSString.class] && currency_code.length) {
            self.currencyCode = currency_code;
        }
        NSString *country_code = purchaseJSON[@"country_code"];
        if ([country_code isKindOfClass:NSString.class] && country_code.length) {
            self.countryCode = country_code;
        }
        
        NSNumber *is_in_intro_offer_period = purchaseJSON[@"is_in_intro_offer_period"];
        if ([is_in_intro_offer_period isKindOfClass:NSNumber.class]) {
            self.isInIntroOfferPeriod = is_in_intro_offer_period.boolValue;
        }
        NSString *promotional_offer_id = purchaseJSON[@"promotional_offer_id"];
        if ([promotional_offer_id isKindOfClass:NSString.class] && promotional_offer_id.length) {
            self.promotionalOfferId = promotional_offer_id;
        }
        NSString *offer_code_ref_name = purchaseJSON[@"offer_code_ref_name"];
        if ([offer_code_ref_name isKindOfClass:NSString.class] && offer_code_ref_name.length) {
            self.offerCodeRefName = offer_code_ref_name;
        }
        NSString *licensecode = purchaseJSON[@"licensecode"];
        if ([licensecode isKindOfClass:NSString.class] && licensecode.length) {
            self.licenseCode = licensecode;
        }
        NSString *web_order_line_item_id = purchaseJSON[@"web_order_line_item_id"];
        if ([web_order_line_item_id isKindOfClass:NSString.class] && web_order_line_item_id.length) {
            self.webOrderLineItemId = web_order_line_item_id;
        }
    }
    
    if (!self.productId.length || self.type == 0 || self.store == 0) {
        if (error) {
            *error = [GYError serverError:GYErrorCodeUnknow description:@"Unexpected PurchaseHistory data format: missing productId, type or store"];
        }
        return nil;
    }
    return self;
}

@end

@implementation GYPurchaseHistory

@end
