//
//  STAApp.h
//  SeeTheApp
//
//  Created by goVertex on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface STAApp : NSManagedObject

@property (nonatomic, retain) NSNumber *appID;
@property (nonatomic, retain) NSString *appURLString;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSDate *lastUpdatedDate;
@property (nonatomic, retain) NSNumber *priceTier;
@property (nonatomic, retain) NSString *screenshotURLString;
@property (nonatomic, retain) NSSet *categories;

@end
