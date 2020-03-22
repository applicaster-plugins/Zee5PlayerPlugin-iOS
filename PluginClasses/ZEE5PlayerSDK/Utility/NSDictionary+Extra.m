//
//  NSDictionary+Extra.m
//  HungamaMusic
//
//  Created by Mukesh Verma on 01/07/16.
//  Copyright © 2016 Hungama.com. All rights reserved.
//

#import "NSDictionary+Extra.h"

@implementation NSDictionary (Extra)

-(id)ObjectForKeyWithNullChecking:(id)key
{
    return ((![self valueForKey:key]) ||[[self objectForKey:key] isKindOfClass:[NSNull class]] || [self objectForKey:key]==nil)?@"":[self objectForKey:key];
}

-(id)ValueForKeyWithNullChecking:(id)key
{
    return ((![self valueForKey:key])|| key == [NSNull null] ||[[self valueForKey:key] isKindOfClass:[NSNull class]] || [self objectForKey:key]==nil )?@"":[self valueForKey:key];
}

@end
