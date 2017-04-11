//
//  STACategory.h
//  SeeTheApp
//
//  Created by goVertex on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface STACategory : NSManagedObject

@property (nonatomic, retain) NSNumber *categoryCode;
@property (nonatomic, retain) NSString *categoryName;

@end
