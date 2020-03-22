//
//	SubscriptionAdditional.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "SubscriptionAdditional.h"

NSString *const kSubscriptionAdditionalPaymentinfo = @"paymentinfo";
NSString *const kSubscriptionAdditionalPaymentMode = @"paymentmode";
NSString *const kSubscriptionAdditionalCouponCode = @"couponcode";

@interface SubscriptionAdditional ()
@end
@implementation SubscriptionAdditional




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSubscriptionAdditionalPaymentinfo] isKindOfClass:[NSNull class]])
    {
		self.paymentinfo = dictionary[kSubscriptionAdditionalPaymentinfo];
	}
    if(![dictionary[kSubscriptionAdditionalPaymentMode] isKindOfClass:[NSNull class]])
    {
        self.paymentMode = dictionary[kSubscriptionAdditionalPaymentinfo];
    }
    if(![dictionary[kSubscriptionAdditionalPaymentinfo] isKindOfClass:[NSNull class]])
    {
        self.paymentinfo = dictionary[kSubscriptionAdditionalPaymentinfo];
    }
	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if(self.paymentinfo != nil)
    {
		dictionary[kSubscriptionAdditionalPaymentinfo] = self.paymentinfo;
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
	if(self.paymentinfo != nil)
    {
		[aCoder encodeObject:self.paymentinfo forKey:kSubscriptionAdditionalPaymentinfo];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.paymentinfo = [aDecoder decodeObjectForKey:kSubscriptionAdditionalPaymentinfo];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	SubscriptionAdditional *copy = [SubscriptionAdditional new];

	copy.paymentinfo = [self.paymentinfo copy];

	return copy;
}
@end
