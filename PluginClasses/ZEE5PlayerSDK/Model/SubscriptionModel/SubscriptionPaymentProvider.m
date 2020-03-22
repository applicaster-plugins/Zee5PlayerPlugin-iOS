//
//	SubscriptionPaymentProvider.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "SubscriptionPaymentProvider.h"

NSString *const kSubscriptionPaymentProviderName = @"name";
NSString *const kSubscriptionPaymentProviderProductReference = @"productReference";

@interface SubscriptionPaymentProvider ()
@end
@implementation SubscriptionPaymentProvider




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kSubscriptionPaymentProviderName] isKindOfClass:[NSNull class]]){
		self.name = dictionary[kSubscriptionPaymentProviderName];
	}	
	if(![dictionary[kSubscriptionPaymentProviderProductReference] isKindOfClass:[NSNull class]]){
		self.productReference = dictionary[kSubscriptionPaymentProviderProductReference];
	}	
	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if(self.name != nil)
    {
		dictionary[kSubscriptionPaymentProviderName] = self.name;
	}
	if(self.productReference != nil)
    {
		dictionary[kSubscriptionPaymentProviderProductReference] = self.productReference;
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
	if(self.name != nil){
		[aCoder encodeObject:self.name forKey:kSubscriptionPaymentProviderName];
	}
	if(self.productReference != nil){
		[aCoder encodeObject:self.productReference forKey:kSubscriptionPaymentProviderProductReference];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.name = [aDecoder decodeObjectForKey:kSubscriptionPaymentProviderName];
	self.productReference = [aDecoder decodeObjectForKey:kSubscriptionPaymentProviderProductReference];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	SubscriptionPaymentProvider *copy = [SubscriptionPaymentProvider new];

	copy.name = [self.name copy];
	copy.productReference = [self.productReference copy];

	return copy;
}
@end
