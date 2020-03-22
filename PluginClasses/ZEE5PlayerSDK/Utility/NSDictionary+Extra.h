//
//  NSDictionary+Extra.h
//  HungamaMusic
//
//  Created by Mukesh Verma on 01/07/16.
//  Copyright © 2016 Hungama.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
  * @discussion A Category class for doing extra work on to NSDictionary.
  */

@interface NSDictionary (Extra)
/*!
  * @discussion A Method to check for NULL Object for key and if it is NULL then it will replace it with nil.
  * @param key ->  key to check the value
  * @return nil or actual object.
  */

-(id)ObjectForKeyWithNullChecking:(id)key;

/*!
  * @discussion A Method to check for NULL value for key and if it is NULL then it will replace it with nil.
  * @param key ->  key to check the value
  * @return nil or actual value.
  */
-(id)ValueForKeyWithNullChecking:(id)key;
@end
