//
//	SubscriptionModel.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "SubscriptionModel.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>



NSString *const kSubscriptionModelAdditional = @"additional";
NSString *const kSubscriptionModelAllowedBillingCycles = @"allowedBillingCycles";
NSString *const kSubscriptionModelCreateDate = @"createDate";
NSString *const kSubscriptionModelFreeTrial = @"freeTrial";
NSString *const kSubscriptionModelIdField = @"id";
NSString *const kSubscriptionModelIdentifier = @"identifier";
NSString *const kSubscriptionModelPaymentProvider = @"paymentProvider";
NSString *const kSubscriptionModelRecurringEnabled = @"recurringEnabled";
NSString *const kSubscriptionModelState = @"state";
NSString *const kSubscriptionModelSubscriptionEnd = @"subscriptionEnd";
NSString *const kSubscriptionModelSubscriptionPlan = @"subscriptionPlan";
NSString *const kSubscriptionModelSubscriptionStart = @"subscriptionStart";
NSString *const kSubscriptionModelUsedBillingCycles = @"usedBillingCycles";
NSString *const kSubscriptionModelUserId = @"userId";

@interface SubscriptionModel ()
@end
@implementation SubscriptionModel




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSubscriptionModelAdditional] isKindOfClass:[NSNull class]])
    {
		self.additional = [[SubscriptionAdditional alloc] initWithDictionary:dictionary[kSubscriptionModelAdditional]];
	}

	if(![dictionary[kSubscriptionModelAllowedBillingCycles] isKindOfClass:[NSNull class]])
    {
		self.allowedBillingCycles = [dictionary[kSubscriptionModelAllowedBillingCycles] integerValue];
	}

	if(![dictionary[kSubscriptionModelCreateDate] isKindOfClass:[NSNull class]])
    {
		self.createDate = dictionary[kSubscriptionModelCreateDate];
	}	
	if(![dictionary[kSubscriptionModelFreeTrial] isKindOfClass:[NSNull class]])
    {
		self.freeTrial = dictionary[kSubscriptionModelFreeTrial];
	}	
	if(![dictionary[kSubscriptionModelIdField] isKindOfClass:[NSNull class]])
    {
		self.idField = dictionary[kSubscriptionModelIdField];
	}	
	if(![dictionary[kSubscriptionModelIdentifier] isKindOfClass:[NSNull class]])
    {
		self.idField = dictionary[kSubscriptionModelIdentifier];
	}	
	if(![dictionary[kSubscriptionModelPaymentProvider] isKindOfClass:[NSNull class]])
    {
		self.paymentProvider = dictionary[kSubscriptionModelPaymentProvider];
	}	
	if(![dictionary[kSubscriptionModelRecurringEnabled] isKindOfClass:[NSNull class]])
    {
		self.recurringEnabled = [dictionary[kSubscriptionModelRecurringEnabled] boolValue];
	}

	if(![dictionary[kSubscriptionModelState] isKindOfClass:[NSNull class]])
    {
		self.state = dictionary[kSubscriptionModelState];
	}	
	if(![dictionary[kSubscriptionModelSubscriptionEnd] isKindOfClass:[NSNull class]])
    {
		self.subscriptionEnd = dictionary[kSubscriptionModelSubscriptionEnd];
	}	
	if(![dictionary[kSubscriptionModelSubscriptionPlan] isKindOfClass:[NSNull class]]){
		self.subscriptionPlan = [[SubscriptionPlan alloc] initWithDictionary:dictionary[kSubscriptionModelSubscriptionPlan]];
	}

	if(![dictionary[kSubscriptionModelSubscriptionStart] isKindOfClass:[NSNull class]]){
		self.subscriptionStart = dictionary[kSubscriptionModelSubscriptionStart];
	}	
	if(![dictionary[kSubscriptionModelUsedBillingCycles] isKindOfClass:[NSNull class]]){
		self.usedBillingCycles = [dictionary[kSubscriptionModelUsedBillingCycles] integerValue];
	}

	if(![dictionary[kSubscriptionModelUserId] isKindOfClass:[NSNull class]]){
		self.userId = dictionary[kSubscriptionModelUserId];
	}
    
    if(![dictionary[kSubscriptionModelSubscriptionStart] isKindOfClass:[NSNull class]] && ![dictionary[kSubscriptionModelSubscriptionEnd] isKindOfClass:[NSNull class]] )
    {
        
    
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSDate *startDate = [dateFormatter dateFromString:dictionary[kSubscriptionModelSubscriptionStart]];
        NSDate *EndDate = [dateFormatter dateFromString:dictionary[kSubscriptionModelSubscriptionEnd]];
        NSDate *currentdate = [NSDate date];
        NSString *currentDateStr =[dateFormatter stringFromDate:currentdate];
        currentdate =[dateFormatter dateFromString:currentDateStr];
    
        if ([self.subscriptionStart containsString:@"."])
        {
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
            startDate =[dateFormatter dateFromString:self.subscriptionStart];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            self.subscriptionStart =[dateFormatter stringFromDate:startDate];
            startDate = [dateFormatter dateFromString:self.subscriptionStart];
        }
        
        if ([self.subscriptionEnd containsString:@"."])
        {
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
            EndDate =[dateFormatter dateFromString:self.subscriptionEnd];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            self.subscriptionEnd =[dateFormatter stringFromDate:EndDate];
            EndDate = [dateFormatter dateFromString:self.subscriptionEnd];
        }
    
      
        _isSubscriptionActive = [Utility isDate:currentdate inRangeFirstDate:startDate lastDate:EndDate];
        
    }
	return self;
}

/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if(self.additional != nil)
    {
		dictionary[kSubscriptionModelAdditional] = [self.additional toDictionary];
	}
	dictionary[kSubscriptionModelAllowedBillingCycles] = @(self.allowedBillingCycles);
	if(self.createDate != nil)
    {
		dictionary[kSubscriptionModelCreateDate] = self.createDate;
	}
	if(self.freeTrial != nil){
		dictionary[kSubscriptionModelFreeTrial] = self.freeTrial;
	}
	if(self.idField != nil){
		dictionary[kSubscriptionModelIdField] = self.idField;
	}
	if(self.idField != nil){
		dictionary[kSubscriptionModelIdentifier] = self.idField;
	}
	if(self.paymentProvider != nil){
		dictionary[kSubscriptionModelPaymentProvider] = self.paymentProvider;
	}
	dictionary[kSubscriptionModelRecurringEnabled] = @(self.recurringEnabled);
	if(self.state != nil){
		dictionary[kSubscriptionModelState] = self.state;
	}
	if(self.subscriptionEnd != nil){
		dictionary[kSubscriptionModelSubscriptionEnd] = self.subscriptionEnd;
	}
	if(self.subscriptionPlan != nil)
    {
		dictionary[kSubscriptionModelSubscriptionPlan] = [self.subscriptionPlan toDictionary];
	}
	if(self.subscriptionStart != nil){
		dictionary[kSubscriptionModelSubscriptionStart] = self.subscriptionStart;
	}
	dictionary[kSubscriptionModelUsedBillingCycles] = @(self.usedBillingCycles);
	if(self.userId != nil){
		dictionary[kSubscriptionModelUserId] = self.userId;
	}
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
	if(self.additional != nil){
		[aCoder encodeObject:self.additional forKey:kSubscriptionModelAdditional];
	}
	[aCoder encodeObject:@(self.allowedBillingCycles) forKey:kSubscriptionModelAllowedBillingCycles];	if(self.createDate != nil){
		[aCoder encodeObject:self.createDate forKey:kSubscriptionModelCreateDate];
	}
	if(self.freeTrial != nil){
		[aCoder encodeObject:self.freeTrial forKey:kSubscriptionModelFreeTrial];
	}
	if(self.idField != nil){
		[aCoder encodeObject:self.idField forKey:kSubscriptionModelIdField];
	}
	if(self.idField != nil){
		[aCoder encodeObject:self.idField forKey:kSubscriptionModelIdentifier];
	}
	if(self.paymentProvider != nil){
		[aCoder encodeObject:self.paymentProvider forKey:kSubscriptionModelPaymentProvider];
	}
	[aCoder encodeObject:@(self.recurringEnabled) forKey:kSubscriptionModelRecurringEnabled];	if(self.state != nil){
		[aCoder encodeObject:self.state forKey:kSubscriptionModelState];
	}
	if(self.subscriptionEnd != nil){
		[aCoder encodeObject:self.subscriptionEnd forKey:kSubscriptionModelSubscriptionEnd];
	}
	if(self.subscriptionPlan != nil){
		[aCoder encodeObject:self.subscriptionPlan forKey:kSubscriptionModelSubscriptionPlan];
	}
	if(self.subscriptionStart != nil){
		[aCoder encodeObject:self.subscriptionStart forKey:kSubscriptionModelSubscriptionStart];
	}
	[aCoder encodeObject:@(self.usedBillingCycles) forKey:kSubscriptionModelUsedBillingCycles];	if(self.userId != nil){
		[aCoder encodeObject:self.userId forKey:kSubscriptionModelUserId];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.additional = [aDecoder decodeObjectForKey:kSubscriptionModelAdditional];
	self.allowedBillingCycles = [[aDecoder decodeObjectForKey:kSubscriptionModelAllowedBillingCycles] integerValue];
	self.createDate = [aDecoder decodeObjectForKey:kSubscriptionModelCreateDate];
	self.freeTrial = [aDecoder decodeObjectForKey:kSubscriptionModelFreeTrial];
	self.idField = [aDecoder decodeObjectForKey:kSubscriptionModelIdField];
	self.idField = [aDecoder decodeObjectForKey:kSubscriptionModelIdentifier];
	self.paymentProvider = [aDecoder decodeObjectForKey:kSubscriptionModelPaymentProvider];
	self.recurringEnabled = [[aDecoder decodeObjectForKey:kSubscriptionModelRecurringEnabled] boolValue];
	self.state = [aDecoder decodeObjectForKey:kSubscriptionModelState];
	self.subscriptionEnd = [aDecoder decodeObjectForKey:kSubscriptionModelSubscriptionEnd];
	self.subscriptionPlan = [aDecoder decodeObjectForKey:kSubscriptionModelSubscriptionPlan];
	self.subscriptionStart = [aDecoder decodeObjectForKey:kSubscriptionModelSubscriptionStart];
	self.usedBillingCycles = [[aDecoder decodeObjectForKey:kSubscriptionModelUsedBillingCycles] integerValue];
	self.userId = [aDecoder decodeObjectForKey:kSubscriptionModelUserId];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	SubscriptionModel *copy = [SubscriptionModel new];

	copy.additional = [self.additional copy];
	copy.allowedBillingCycles = self.allowedBillingCycles;
	copy.createDate = [self.createDate copy];
	copy.freeTrial = [self.freeTrial copy];
	copy.idField = [self.idField copy];
	copy.idField = [self.idField copy];
	copy.paymentProvider = [self.paymentProvider copy];
	copy.recurringEnabled = self.recurringEnabled;
	copy.state = [self.state copy];
	copy.subscriptionEnd = [self.subscriptionEnd copy];
	copy.subscriptionPlan = [self.subscriptionPlan copy];
	copy.subscriptionStart = [self.subscriptionStart copy];
	copy.usedBillingCycles = self.usedBillingCycles;
	copy.userId = [self.userId copy];

	return copy;
}
@end
