//
//  NSDictionary+EmptyString.h
//  CityGuide
//
//  Created by Mac Mini on 4/27/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(EmptyString)

- (NSDictionary *) dictionaryByReplacingNullsWithStrings;

@end
