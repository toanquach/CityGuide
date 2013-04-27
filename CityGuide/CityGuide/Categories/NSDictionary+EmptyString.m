//
//  NSDictionary+EmptyString.m
//  CityGuide
//
//  Created by Mac Mini on 4/27/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "NSDictionary+EmptyString.h"

@implementation NSDictionary(EmptyString)

- (NSDictionary *) dictionaryByReplacingNullsWithStrings
{    
    const NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary:self];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    
    for(NSString *key in self)
    {
        const id object = [self objectForKey:key];
        if(object == nul)
        {
            //pointer comparison is way faster than -isKindOfClass:
            //since [NSNull null] is a singleton, they'll all point to the same
            //location in memory.
            [replaced setObject:blank
                         forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:(NSDictionary *)replaced];
}
@end
