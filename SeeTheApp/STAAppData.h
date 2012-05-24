//
//  STAAppData.h
//  SeeTheApp
//
//  Created by Joe Bonniwell on 5/13/12.
//  Copyright (c) 2012 goVertex LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STAAppData : NSObject

@property (atomic, retain) NSNumber *appID;
@property (atomic, retain) NSString *appURLString;
@property (atomic, retain) NSString *screenshotURLString;
@property (atomic, retain) NSSet *categories;
@property (atomic, retain) NSString *country;
@property (atomic, retain) NSNumber *priceTier;

// Create app data from JSON dictionary...
@end
