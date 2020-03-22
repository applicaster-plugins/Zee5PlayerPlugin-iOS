#import <UIKit/UIKit.h>
#import "SubscriptionPaymentProvider.h"

@interface SubscriptionPlan : NSObject

@property (nonatomic, strong) NSArray * assetIds;
@property (nonatomic, assign) NSInteger assetType;
@property (nonatomic, strong) NSArray * assetTypes;
@property (nonatomic, strong) NSString * billingCycleType;
@property (nonatomic, assign) NSInteger billingFrequency;
@property (nonatomic, strong) NSArray * channelAudioLanguages;
@property (nonatomic, strong) NSArray * countries;
@property (nonatomic, strong) NSString * country;
@property (nonatomic, strong) NSString * currency;
@property (nonatomic, strong) NSString * descriptionField;
@property (nonatomic, strong) NSString * end;
@property (nonatomic, strong) NSString * idField;
@property (nonatomic, strong) NSArray * movieAudioLanguages;
@property (nonatomic, assign) NSInteger numberOfSupportedDevices;
@property (nonatomic, assign) BOOL onlyAvailableWithPromotion;
@property (nonatomic, strong) NSString * originalTitle;
@property (nonatomic, strong) NSArray * paymentProviders;
@property (nonatomic, assign) NSInteger price;
@property (nonatomic, strong) NSArray * promotions;
@property (nonatomic, assign) BOOL recurring;
@property (nonatomic, strong) NSString * start;
@property (nonatomic, strong) NSString * subscriptionPlanType;
@property (nonatomic, strong) NSString * system;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSArray * tvShowAudioLanguages;
@property (nonatomic, assign) BOOL validForAllCountries;
@property (nonatomic, assign) BOOL isSubscriptionPlanActive;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end
