//
//  STALocalAppImporter.h
//  SeeTheApp
//
//  Created by Joe Bonniwell on 5/12/12.
//  Copyright (c) 2012 goVertex LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STAAppData.h"
#import "STACategory.h"
#import "STAApp.h"

@interface STALocalAppImporter : NSObject

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)argPersistentStoreCoordinator;

// Startup Methods
- (void)createCategoriesWithCategoriesInfo:(NSDictionary*)argCategoriesInfo;
//- (void)createInitialApps;
- (void)convertExistingDisplayIndices;

// Ongoing Methods
- (void)importAppsWithData:(NSArray*)argAppsData asSearch:(BOOL)argAsSearch;

@end
