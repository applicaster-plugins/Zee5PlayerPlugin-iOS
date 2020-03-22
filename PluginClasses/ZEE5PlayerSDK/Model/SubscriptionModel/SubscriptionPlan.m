//
//	SubscriptionPlan.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "SubscriptionPlan.h"
#import "Utility.h"

NSString *const kSubscriptionPlanAssetIds = @"assetIds";
NSString *const kSubscriptionPlanAssetType = @"assetType";
NSString *const kSubscriptionPlanAssetTypes = @"assetTypes";
NSString *const kSubscriptionPlanBillingCycleType = @"billingCycleType";
NSString *const kSubscriptionPlanBillingFrequency = @"billingFrequency";
NSString *const kSubscriptionPlanChannelAudioLanguages = @"channelAudioLanguages";
NSString *const kSubscriptionPlanCountries = @"countries";
NSString *const kSubscriptionPlanCountry = @"country";
NSString *const kSubscriptionPlanCurrency = @"currency";
NSString *const kSubscriptionPlanDescriptionField = @"description";
NSString *const kSubscriptionPlanStart = @"start";
NSString *const kSubscriptionPlanEnd = @"end";
NSString *const kSubscriptionPlanIdField = @"id";
NSString *const kSubscriptionPlanMovieAudioLanguages = @"movieAudioLanguages";
NSString *const kSubscriptionPlanNumberOfSupportedDevices = @"numberOfSupportedDevices";
NSString *const kSubscriptionPlanOnlyAvailableWithPromotion = @"onlyAvailableWithPromotion";
NSString *const kSubscriptionPlanOriginalTitle = @"originalTitle";
NSString *const kSubscriptionPlanPaymentProviders = @"paymentProviders";
NSString *const kSubscriptionPlanPrice = @"price";
NSString *const kSubscriptionPlanPromotions = @"promotions";
NSString *const kSubscriptionPlanRecurring = @"recurring";
NSString *const kSubscriptionPlanSubscriptionPlanType = @"subscriptionPlanType";
NSString *const kSubscriptionPlanSystem = @"system";
NSString *const kSubscriptionPlanTitle = @"title";
NSString *const kSubscriptionPlanTvShowAudioLanguages = @"tvShowAudioLanguages";
NSString *const kSubscriptionPlanValidForAllCountries = @"validForAllCountries";

@interface SubscriptionPlan ()
@end
@implementation SubscriptionPlan




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSubscriptionPlanAssetIds] isKindOfClass:[NSNull class]]){
		self.assetIds = dictionary[kSubscriptionPlanAssetIds];
	}	
	if(![dictionary[kSubscriptionPlanAssetType] isKindOfClass:[NSNull class]]){
		self.assetType = [dictionary[kSubscriptionPlanAssetType] integerValue];
	}

	if(![dictionary[kSubscriptionPlanAssetTypes] isKindOfClass:[NSNull class]]){
		self.assetTypes = dictionary[kSubscriptionPlanAssetTypes];
	}	
	if(![dictionary[kSubscriptionPlanBillingCycleType] isKindOfClass:[NSNull class]]){
		self.billingCycleType = dictionary[kSubscriptionPlanBillingCycleType];
	}	
	if(![dictionary[kSubscriptionPlanBillingFrequency] isKindOfClass:[NSNull class]]){
		self.billingFrequency = [dictionary[kSubscriptionPlanBillingFrequency] integerValue];
	}

	if(![dictionary[kSubscriptionPlanChannelAudioLanguages] isKindOfClass:[NSNull class]])
    {
		self.channelAudioLanguages = dictionary[kSubscriptionPlanChannelAudioLanguages];
	}	
	if(![dictionary[kSubscriptionPlanCountries] isKindOfClass:[NSNull class]]){
		self.countries = dictionary[kSubscriptionPlanCountries];
	}	
	if(![dictionary[kSubscriptionPlanCountry] isKindOfClass:[NSNull class]]){
		self.country = dictionary[kSubscriptionPlanCountry];
	}	
	if(![dictionary[kSubscriptionPlanCurrency] isKindOfClass:[NSNull class]]){
		self.currency = dictionary[kSubscriptionPlanCurrency];
	}	
	if(![dictionary[kSubscriptionPlanDescriptionField] isKindOfClass:[NSNull class]]){
		self.descriptionField = dictionary[kSubscriptionPlanDescriptionField];
	}	
	if(![dictionary[kSubscriptionPlanEnd] isKindOfClass:[NSNull class]]){
		self.end = dictionary[kSubscriptionPlanEnd];
	}	
	if(![dictionary[kSubscriptionPlanIdField] isKindOfClass:[NSNull class]]){
		self.idField = dictionary[kSubscriptionPlanIdField];
	}	
	if(![dictionary[kSubscriptionPlanMovieAudioLanguages] isKindOfClass:[NSNull class]]){
		self.movieAudioLanguages = dictionary[kSubscriptionPlanMovieAudioLanguages];
	}	
	if(![dictionary[kSubscriptionPlanNumberOfSupportedDevices] isKindOfClass:[NSNull class]]){
		self.numberOfSupportedDevices = [dictionary[kSubscriptionPlanNumberOfSupportedDevices] integerValue];
	}

	if(![dictionary[kSubscriptionPlanOnlyAvailableWithPromotion] isKindOfClass:[NSNull class]]){
		self.onlyAvailableWithPromotion = [dictionary[kSubscriptionPlanOnlyAvailableWithPromotion] boolValue];
	}

	if(![dictionary[kSubscriptionPlanOriginalTitle] isKindOfClass:[NSNull class]]){
		self.originalTitle = dictionary[kSubscriptionPlanOriginalTitle];
	}	
	if(dictionary[kSubscriptionPlanPaymentProviders] != nil && [dictionary[kSubscriptionPlanPaymentProviders] isKindOfClass:[NSArray class]]){
		NSArray * paymentProvidersDictionaries = dictionary[kSubscriptionPlanPaymentProviders];
		NSMutableArray * paymentProvidersItems = [NSMutableArray array];
		for(NSDictionary * paymentProvidersDictionary in paymentProvidersDictionaries){
			SubscriptionPaymentProvider * paymentProvidersItem = [[SubscriptionPaymentProvider alloc] initWithDictionary:paymentProvidersDictionary];
			[paymentProvidersItems addObject:paymentProvidersItem];
		}
		self.paymentProviders = paymentProvidersItems;
	}
	if(![dictionary[kSubscriptionPlanPrice] isKindOfClass:[NSNull class]]){
		self.price = [dictionary[kSubscriptionPlanPrice] integerValue];
	}

	if(![dictionary[kSubscriptionPlanPromotions] isKindOfClass:[NSNull class]]){
		self.promotions = dictionary[kSubscriptionPlanPromotions];
	}	
	if(![dictionary[kSubscriptionPlanRecurring] isKindOfClass:[NSNull class]]){
		self.recurring = [dictionary[kSubscriptionPlanRecurring] boolValue];
	}

	if(![dictionary[kSubscriptionPlanStart] isKindOfClass:[NSNull class]]){
		self.start = dictionary[kSubscriptionPlanStart];
	}	
	if(![dictionary[kSubscriptionPlanSubscriptionPlanType] isKindOfClass:[NSNull class]]){
		self.subscriptionPlanType = dictionary[kSubscriptionPlanSubscriptionPlanType];
	}	
	if(![dictionary[kSubscriptionPlanSystem] isKindOfClass:[NSNull class]]){
		self.system = dictionary[kSubscriptionPlanSystem];
	}	
	if(![dictionary[kSubscriptionPlanTitle] isKindOfClass:[NSNull class]]){
		self.title = dictionary[kSubscriptionPlanTitle];
	}	
	if(![dictionary[kSubscriptionPlanTvShowAudioLanguages] isKindOfClass:[NSNull class]]){
		self.tvShowAudioLanguages = dictionary[kSubscriptionPlanTvShowAudioLanguages];
	}	
	if(![dictionary[kSubscriptionPlanValidForAllCountries] isKindOfClass:[NSNull class]]){
		self.validForAllCountries = [dictionary[kSubscriptionPlanValidForAllCountries] boolValue];
	}
    
    // Cheack date Format if not then change in to time zone format
    if(![dictionary[kSubscriptionPlanStart] isKindOfClass:[NSNull class]] && ![dictionary[kSubscriptionPlanEnd] isKindOfClass:[NSNull class]] )
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSDate *startDate = [dateFormatter dateFromString:dictionary[kSubscriptionPlanStart]];
        NSDate *EndDate = [dateFormatter dateFromString:dictionary[kSubscriptionPlanEnd]];
        NSDate *currentdate = [NSDate date];
        NSString *currentDateStr =[dateFormatter stringFromDate:currentdate];
        currentdate =[dateFormatter dateFromString:currentDateStr];
        
        if ([self.start containsString:@"."])
               {
                   [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
                   startDate =[dateFormatter dateFromString:self.start];
                   [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                   self.start =[dateFormatter stringFromDate:startDate];
                   startDate = [dateFormatter dateFromString:self.start];
               }
               
               if ([self.end containsString:@"."])
               {
                   [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
                   EndDate =[dateFormatter dateFromString:self.end];
                   [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                   self.end =[dateFormatter stringFromDate:EndDate];
                   EndDate = [dateFormatter dateFromString:self.end];
               }
        
        
        // To check subscription active or Not.
        _isSubscriptionPlanActive = [Utility isDate:currentdate inRangeFirstDate:startDate lastDate:EndDate];
    
        
    }
    

	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if(self.assetIds != nil){
		dictionary[kSubscriptionPlanAssetIds] = self.assetIds;
	}
	dictionary[kSubscriptionPlanAssetType] = @(self.assetType);
	if(self.assetTypes != nil){
		dictionary[kSubscriptionPlanAssetTypes] = self.assetTypes;
	}
	if(self.billingCycleType != nil){
		dictionary[kSubscriptionPlanBillingCycleType] = self.billingCycleType;
	}
	dictionary[kSubscriptionPlanBillingFrequency] = @(self.billingFrequency);
	if(self.channelAudioLanguages != nil){
		dictionary[kSubscriptionPlanChannelAudioLanguages] = self.channelAudioLanguages;
	}
	if(self.countries != nil){
		dictionary[kSubscriptionPlanCountries] = self.countries;
	}
	if(self.country != nil){
		dictionary[kSubscriptionPlanCountry] = self.country;
	}
	if(self.currency != nil){
		dictionary[kSubscriptionPlanCurrency] = self.currency;
	}
	if(self.descriptionField != nil){
		dictionary[kSubscriptionPlanDescriptionField] = self.descriptionField;
	}
	if(self.end != nil){
		dictionary[kSubscriptionPlanEnd] = self.end;
	}
	if(self.idField != nil){
		dictionary[kSubscriptionPlanIdField] = self.idField;
	}
	if(self.movieAudioLanguages != nil){
		dictionary[kSubscriptionPlanMovieAudioLanguages] = self.movieAudioLanguages;
	}
	dictionary[kSubscriptionPlanNumberOfSupportedDevices] = @(self.numberOfSupportedDevices);
	dictionary[kSubscriptionPlanOnlyAvailableWithPromotion] = @(self.onlyAvailableWithPromotion);
	if(self.originalTitle != nil){
		dictionary[kSubscriptionPlanOriginalTitle] = self.originalTitle;
	}
	if(self.paymentProviders != nil){
		NSMutableArray * dictionaryElements = [NSMutableArray array];
		for(SubscriptionPaymentProvider * paymentProvidersElement in self.paymentProviders){
			[dictionaryElements addObject:[paymentProvidersElement toDictionary]];
		}
		dictionary[kSubscriptionPlanPaymentProviders] = dictionaryElements;
	}
	dictionary[kSubscriptionPlanPrice] = @(self.price);
	if(self.promotions != nil){
		dictionary[kSubscriptionPlanPromotions] = self.promotions;
	}
	dictionary[kSubscriptionPlanRecurring] = @(self.recurring);
	if(self.start != nil){
		dictionary[kSubscriptionPlanStart] = self.start;
	}
	if(self.subscriptionPlanType != nil){
		dictionary[kSubscriptionPlanSubscriptionPlanType] = self.subscriptionPlanType;
	}
	if(self.system != nil){
		dictionary[kSubscriptionPlanSystem] = self.system;
	}
	if(self.title != nil){
		dictionary[kSubscriptionPlanTitle] = self.title;
	}
	if(self.tvShowAudioLanguages != nil){
		dictionary[kSubscriptionPlanTvShowAudioLanguages] = self.tvShowAudioLanguages;
	}
	dictionary[kSubscriptionPlanValidForAllCountries] = @(self.validForAllCountries);
	return dictionary;

}

/**
 * Implementation of NSCoding encoding method
 */
/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if(self.assetIds != nil){
		[aCoder encodeObject:self.assetIds forKey:kSubscriptionPlanAssetIds];
	}
	[aCoder encodeObject:@(self.assetType) forKey:kSubscriptionPlanAssetType];	if(self.assetTypes != nil){
		[aCoder encodeObject:self.assetTypes forKey:kSubscriptionPlanAssetTypes];
	}
	if(self.billingCycleType != nil){
		[aCoder encodeObject:self.billingCycleType forKey:kSubscriptionPlanBillingCycleType];
	}
	[aCoder encodeObject:@(self.billingFrequency) forKey:kSubscriptionPlanBillingFrequency];	if(self.channelAudioLanguages != nil){
		[aCoder encodeObject:self.channelAudioLanguages forKey:kSubscriptionPlanChannelAudioLanguages];
	}
	if(self.countries != nil){
		[aCoder encodeObject:self.countries forKey:kSubscriptionPlanCountries];
	}
	if(self.country != nil){
		[aCoder encodeObject:self.country forKey:kSubscriptionPlanCountry];
	}
	if(self.currency != nil){
		[aCoder encodeObject:self.currency forKey:kSubscriptionPlanCurrency];
	}
	if(self.descriptionField != nil){
		[aCoder encodeObject:self.descriptionField forKey:kSubscriptionPlanDescriptionField];
	}
	if(self.end != nil){
		[aCoder encodeObject:self.end forKey:kSubscriptionPlanEnd];
	}
	if(self.idField != nil){
		[aCoder encodeObject:self.idField forKey:kSubscriptionPlanIdField];
	}
	if(self.movieAudioLanguages != nil){
		[aCoder encodeObject:self.movieAudioLanguages forKey:kSubscriptionPlanMovieAudioLanguages];
	}
	[aCoder encodeObject:@(self.numberOfSupportedDevices) forKey:kSubscriptionPlanNumberOfSupportedDevices];	[aCoder encodeObject:@(self.onlyAvailableWithPromotion) forKey:kSubscriptionPlanOnlyAvailableWithPromotion];	if(self.originalTitle != nil){
		[aCoder encodeObject:self.originalTitle forKey:kSubscriptionPlanOriginalTitle];
	}
	if(self.paymentProviders != nil){
		[aCoder encodeObject:self.paymentProviders forKey:kSubscriptionPlanPaymentProviders];
	}
	[aCoder encodeObject:@(self.price) forKey:kSubscriptionPlanPrice];	if(self.promotions != nil){
		[aCoder encodeObject:self.promotions forKey:kSubscriptionPlanPromotions];
	}
	[aCoder encodeObject:@(self.recurring) forKey:kSubscriptionPlanRecurring];	if(self.start != nil){
		[aCoder encodeObject:self.start forKey:kSubscriptionPlanStart];
	}
	if(self.subscriptionPlanType != nil){
		[aCoder encodeObject:self.subscriptionPlanType forKey:kSubscriptionPlanSubscriptionPlanType];
	}
	if(self.system != nil){
		[aCoder encodeObject:self.system forKey:kSubscriptionPlanSystem];
	}
	if(self.title != nil){
		[aCoder encodeObject:self.title forKey:kSubscriptionPlanTitle];
	}
	if(self.tvShowAudioLanguages != nil){
		[aCoder encodeObject:self.tvShowAudioLanguages forKey:kSubscriptionPlanTvShowAudioLanguages];
	}
	[aCoder encodeObject:@(self.validForAllCountries) forKey:kSubscriptionPlanValidForAllCountries];
}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.assetIds = [aDecoder decodeObjectForKey:kSubscriptionPlanAssetIds];
	self.assetType = [[aDecoder decodeObjectForKey:kSubscriptionPlanAssetType] integerValue];
	self.assetTypes = [aDecoder decodeObjectForKey:kSubscriptionPlanAssetTypes];
	self.billingCycleType = [aDecoder decodeObjectForKey:kSubscriptionPlanBillingCycleType];
	self.billingFrequency = [[aDecoder decodeObjectForKey:kSubscriptionPlanBillingFrequency] integerValue];
	self.channelAudioLanguages = [aDecoder decodeObjectForKey:kSubscriptionPlanChannelAudioLanguages];
	self.countries = [aDecoder decodeObjectForKey:kSubscriptionPlanCountries];
	self.country = [aDecoder decodeObjectForKey:kSubscriptionPlanCountry];
	self.currency = [aDecoder decodeObjectForKey:kSubscriptionPlanCurrency];
	self.descriptionField = [aDecoder decodeObjectForKey:kSubscriptionPlanDescriptionField];
	self.end = [aDecoder decodeObjectForKey:kSubscriptionPlanEnd];
	self.idField = [aDecoder decodeObjectForKey:kSubscriptionPlanIdField];
	self.movieAudioLanguages = [aDecoder decodeObjectForKey:kSubscriptionPlanMovieAudioLanguages];
	self.numberOfSupportedDevices = [[aDecoder decodeObjectForKey:kSubscriptionPlanNumberOfSupportedDevices] integerValue];
	self.onlyAvailableWithPromotion = [[aDecoder decodeObjectForKey:kSubscriptionPlanOnlyAvailableWithPromotion] boolValue];
	self.originalTitle = [aDecoder decodeObjectForKey:kSubscriptionPlanOriginalTitle];
	self.paymentProviders = [aDecoder decodeObjectForKey:kSubscriptionPlanPaymentProviders];
	self.price = [[aDecoder decodeObjectForKey:kSubscriptionPlanPrice] integerValue];
	self.promotions = [aDecoder decodeObjectForKey:kSubscriptionPlanPromotions];
	self.recurring = [[aDecoder decodeObjectForKey:kSubscriptionPlanRecurring] boolValue];
	self.start = [aDecoder decodeObjectForKey:kSubscriptionPlanStart];
	self.subscriptionPlanType = [aDecoder decodeObjectForKey:kSubscriptionPlanSubscriptionPlanType];
	self.system = [aDecoder decodeObjectForKey:kSubscriptionPlanSystem];
	self.title = [aDecoder decodeObjectForKey:kSubscriptionPlanTitle];
	self.tvShowAudioLanguages = [aDecoder decodeObjectForKey:kSubscriptionPlanTvShowAudioLanguages];
	self.validForAllCountries = [[aDecoder decodeObjectForKey:kSubscriptionPlanValidForAllCountries] boolValue];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	SubscriptionPlan *copy = [SubscriptionPlan new];

	copy.assetIds = [self.assetIds copy];
	copy.assetType = self.assetType;
	copy.assetTypes = [self.assetTypes copy];
	copy.billingCycleType = [self.billingCycleType copy];
	copy.billingFrequency = self.billingFrequency;
	copy.channelAudioLanguages = [self.channelAudioLanguages copy];
	copy.countries = [self.countries copy];
	copy.country = [self.country copy];
	copy.currency = [self.currency copy];
	copy.descriptionField = [self.descriptionField copy];
	copy.end = [self.end copy];
	copy.idField = [self.idField copy];
	copy.movieAudioLanguages = [self.movieAudioLanguages copy];
	copy.numberOfSupportedDevices = self.numberOfSupportedDevices;
	copy.onlyAvailableWithPromotion = self.onlyAvailableWithPromotion;
	copy.originalTitle = [self.originalTitle copy];
	copy.paymentProviders = [self.paymentProviders copy];
	copy.price = self.price;
	copy.promotions = [self.promotions copy];
	copy.recurring = self.recurring;
	copy.start = [self.start copy];
	copy.subscriptionPlanType = [self.subscriptionPlanType copy];
	copy.system = [self.system copy];
	copy.title = [self.title copy];
	copy.tvShowAudioLanguages = [self.tvShowAudioLanguages copy];
	copy.validForAllCountries = self.validForAllCountries;

	return copy;
}
@end
