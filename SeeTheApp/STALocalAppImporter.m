//
//  STALocalAppImporter.m
//  SeeTheApp
//
//  Created by Joe Bonniwell on 5/12/12.
//  Copyright (c) 2012 goVertex LLC. All rights reserved.
//

#import "STALocalAppImporter.h"

@interface STALocalAppImporter ()
{
    NSDictionary *affiliateCodesDictionary_gv;
}
//@property (atomic, retain) NSMutableSet *appsToImport;
@property (atomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (atomic, retain) NSOperationQueue *operationQueue;

@end

@implementation STALocalAppImporter

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)argPersistentStoreCoordinator;
{
    if ((self = [super init]))
    {
        //[self setAppsToImport:[NSMutableSet set]];
        [self setPersistentStoreCoordinator:argPersistentStoreCoordinator];
        
        [self setOperationQueue:[[[NSOperationQueue alloc] init] autorelease]];
        [[self operationQueue] setMaxConcurrentOperationCount:1];
        
        // Have a timer that every 10 or 20 seconds checks if we should import apps
    }
    return self;
}

- (void)createCategoriesWithCategoriesInfo:(NSDictionary*)argCategoriesInfo
{
    // Expecting a dictionary with category code keys (numbers) and category name (string) values
    
    [[self operationQueue] addOperationWithBlock:^
    {
        @autoreleasepool 
        {
            NSManagedObjectContext *context = [[[NSManagedObjectContext alloc] init] autorelease];
            [context setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
            [context setUndoManager:nil];
            
            NSFetchRequest *allCategoriesFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
            NSError *fetchError;
            NSArray *categories = [context executeFetchRequest:allCategoriesFetchRequest error:&fetchError];
            
            if ([categories count] < [[argCategoriesInfo allKeys] count])
            {
                NSMutableSet *allCategories = [NSMutableSet set];
                
                [allCategories addObjectsFromArray:[argCategoriesInfo allKeys]];
                
                for (STACategory *category in categories)
                {
                    [allCategories removeObject:[category categoryCode]];
                }
                
                for (NSNumber *categoryCode in allCategories)
                {                
                    STACategory *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
                    [newCategory setCategoryCode:categoryCode];
                    [newCategory setCategoryName:[argCategoriesInfo objectForKey:categoryCode]];
                }
                
                [context save:nil];
            }
        }
    }];
}

- (void)convertExistingDisplayIndices
{
    [[self operationQueue] addOperationWithBlock:^
     {
         @autoreleasepool 
         {
             NSManagedObjectContext *context = [[[NSManagedObjectContext alloc] init] autorelease];
             [context setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
             [context setUndoManager:nil];
             
             NSFetchRequest *allDisplayIndexesFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DisplayIndex"];
             
             NSSortDescriptor *positionIndexSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"positionIndex" ascending:YES];
             [allDisplayIndexesFetchRequest setSortDescriptors:[NSArray arrayWithObject:positionIndexSortDescriptor]];
             
             NSError *fetchError;
             
             NSArray *allDisplayIndexes = [context executeFetchRequest:allDisplayIndexesFetchRequest error:&fetchError];
             
             if (!allDisplayIndexesFetchRequest)
             {
                 NSLog(@"Error during all display indexes fetch: %@", [fetchError userInfo]);
                 return;
             }
             
             // Perform a fetch to get all categories
             NSFetchRequest *allCategoriesFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
             NSError *categoriesFetchError;
             NSArray *allCategories = [context executeFetchRequest:allCategoriesFetchRequest error:&categoriesFetchError];
             
             if (!allCategories)
             {
                 NSLog(@"Categories Fetch Error: %@", [categoriesFetchError localizedDescription]);
                 return;
             }
             
             NSMutableDictionary *categoryObjects = [NSMutableDictionary dictionary];
             
             for (STACategory *category in allCategories)
             {
                 [categoryObjects setObject:category forKey:[category categoryCode]];
             }
             
             NSInteger convertedAppCounter = 0;
             
             for (NSManagedObject *displayIndex in allDisplayIndexes)
             {
                 STAApp *replacementApp = [NSEntityDescription insertNewObjectForEntityForName:@"App" inManagedObjectContext:context];
                 
                 [replacementApp setAppID:[displayIndex valueForKey:STADisplayIndexAttributeAppID]];
                 [replacementApp setAppURLString:[displayIndex valueForKey:STADisplayIndexAttributeAppURL]];
                 [replacementApp setCountry:[displayIndex valueForKey:STADisplayIndexAttributeCountry]];
                 [replacementApp setCreationDate:[NSDate dateWithTimeIntervalSince1970:[[displayIndex valueForKey:STADisplayIndexAttributePositionIndex] integerValue]]];
                 [replacementApp setLastUpdatedDate:[NSDate date]];
                 [replacementApp setPriceTier:[displayIndex valueForKey:STADisplayIndexAttributePriceTier]];
                 [replacementApp setScreenshotURLString:[displayIndex valueForKey:STADisplayIndexAttributeScreenshotURL]];
                 
                 if ([[displayIndex valueForKey:STADisplayIndexAttributeCategory] integerValue] != STACategoryBrowse && [[displayIndex valueForKey:STADisplayIndexAttributeCategory] integerValue] !=STACategorySearchResult)
                 {
                     [replacementApp setCategories:[NSSet setWithObject:[categoryObjects objectForKey:[displayIndex valueForKey:STADisplayIndexAttributeCategory]]]];
                 }
                 
                 [context deleteObject:displayIndex];
                 
                 convertedAppCounter++;
                 
                 if (convertedAppCounter >= 18)
                 {
                     convertedAppCounter = 0;
                     [context save:nil];
                 }
             }
             
             NSError *saveError;
             if ([context save:&saveError] == NO)
                 NSLog(@"Save Error: %@", [saveError userInfo]);
         }
         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STADefaultsDisplayIndicesConverted];
     }];
}

- (void)importAppsWithData:(NSArray *)argAppsData asSearch:(BOOL)argAsSearch
{
    if (argAsSearch)
        NSLog(@"Importing search apps");
    
    if ([argAppsData count] == 0)
        return;
    
    //[[self appsToImport] addObjectsFromArray:argAppsData];
    
    NSSet *appsToImportCopy = [NSSet setWithArray:argAppsData];
    
    if ([[self operationQueue] operationCount] == 0)
    {
        // Start an operation to import the apps in argAppsData
        NSBlockOperation *importOperation = [NSBlockOperation blockOperationWithBlock:^
                                             {
                                                 @autoreleasepool 
                                                 {
                                                     
                                                     NSManagedObjectContext *context = [[[NSManagedObjectContext alloc] init] autorelease];
                                                     [context setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
                                                     [context setUndoManager:nil];
                                                     
                                                     //NSSet *appsToImportCopy = [[self appsToImport] copy];
                                                     
                                                     NSString *countryCodeForImport = [[appsToImportCopy anyObject] country];
                                                     
                                                     NSMutableDictionary *appsToImportBatch = [NSMutableDictionary dictionary];
                                                     
                                                     NSMutableArray *searchOrderedAppIDs = [NSMutableArray array];
                                                     
                                                     for (STAAppData *appData in appsToImportCopy)
                                                     {
                                                         if ([[appData country] isEqualToString:countryCodeForImport])
                                                         {
                                                             [appsToImportBatch setObject:appData forKey:[appData appID]];
                                                             
                                                             if (argAsSearch)
                                                                 [searchOrderedAppIDs addObject:[appData appID]];
                                                         }
                                                     }
                                                     
                                                     //[[self appsToImport] minusSet:[NSSet setWithArray:[appsToImportBatch allValues]]];
                                                     
                                                     NSPredicate *existingAppsFromLookupPredicate = [NSPredicate predicateWithFormat:@"country like %@ AND appID IN %@", countryCodeForImport, [appsToImportBatch allKeys]];
                                                     
                                                     NSFetchRequest *existingAppsFromLookupFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"App"];
                                                     [existingAppsFromLookupFetchRequest setPredicate:existingAppsFromLookupPredicate];
                                                     
                                                     NSError *fetchError;
                                                     
                                                     NSArray *existingAppsFromLookup = [context executeFetchRequest:existingAppsFromLookupFetchRequest error:&fetchError];
                                                     
                                                     if (!existingAppsFromLookup)
                                                     {
                                                         NSLog(@"Existing Apps fetch error: %@", [fetchError localizedDescription]);
                                                         return;
                                                     }
                                                     
                                                     // Perform a fetch to get all categories
                                                     NSFetchRequest *allCategoriesFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
                                                     NSError *categoriesFetchError;
                                                     NSArray *allCategories = [context executeFetchRequest:allCategoriesFetchRequest error:&categoriesFetchError];
                                                     
                                                     if (!allCategories)
                                                     {
                                                         NSLog(@"Categories Fetch Error: %@", [categoriesFetchError localizedDescription]);
                                                         return;
                                                     }
                                                     
                                                     NSMutableDictionary *categoryObjects = [NSMutableDictionary dictionary];
                                                     
                                                     for (STACategory *category in allCategories)
                                                     {
                                                         [categoryObjects setObject:category forKey:[category categoryCode]];
                                                     }
                                                     
                                                     NSMutableArray *keysToRemove = [NSMutableArray array];
                                                     
                                                     for (STAApp *existingApp in existingAppsFromLookup)
                                                     {
                                                         NSNumber *appID = [existingApp appID];
                                                         
                                                         STAAppData *appData = [appsToImportBatch objectForKey:appID];
                                                         
                                                         [keysToRemove addObject:appID];
                                                         
                                                         NSString *baseAppURLString = [appData appURLString];
                                                         
                                                         NSString *countryCode = [appData country];
                                                         
                                                         NSMutableString *affiliateAppURLString = [baseAppURLString mutableCopy];
                                                         
                                                         if ([[[self affiliateCodesDictionary] allKeys] containsObject:countryCode])
                                                         {
                                                             NSRange locationOfQuestionMark = [affiliateAppURLString rangeOfString:@"?" options:NSBackwardsSearch];
                                                             NSRange locationOfSlash = [affiliateAppURLString rangeOfString:@"/" options:NSBackwardsSearch];
                                                             
                                                             if (locationOfQuestionMark.location != NSNotFound && locationOfQuestionMark.location > locationOfSlash.location)
                                                                 [affiliateAppURLString appendString:@"&"];
                                                             else 
                                                                 [affiliateAppURLString appendString:@"?"];
                                                             [affiliateAppURLString appendString:[[self affiliateCodesDictionary] objectForKey:countryCode]];
                                                         }
                                                                                                                  
                                                         [existingApp setAppURLString:affiliateAppURLString];
                                                         [affiliateAppURLString release];
                                                         
                                                         [existingApp setPriceTier:[appData priceTier]];
                                                         [existingApp setScreenshotURLString:[appData screenshotURLString]];
                                                         
                                                         NSMutableSet *categories = [NSMutableSet set];
                                                         
                                                         for (NSString *categoryCodeString in [appData categories])
                                                         {
                                                             NSNumber *categoryCode = [NSNumber numberWithInteger:[categoryCodeString integerValue]];
                                                             
                                                             STACategory *category = [categoryObjects objectForKey:categoryCode];
                                                             if (category)
                                                                 [categories addObject:category];
                                                         }
                                                         
                                                         if ([categories count])
                                                             [existingApp setCategories:categories];
                                                     }
                                                     
                                                     [appsToImportBatch removeObjectsForKeys:keysToRemove];
                                                     
                                                     for (NSNumber *appID in [appsToImportBatch allKeys])
                                                     {     
                                                         STAAppData *appData = [appsToImportBatch objectForKey:appID];
                                                         
                                                         NSMutableSet *categories = [NSMutableSet set];
                                                         
                                                         for (NSNumber *categoryCodeString in [appData categories])
                                                         {
                                                             NSNumber *categoryCode = [NSNumber numberWithInteger:[categoryCodeString integerValue]];
                                                             STACategory *category = [categoryObjects objectForKey:categoryCode];
                                                             if (category)
                                                                 [categories addObject:category];
                                                         }
                                                         
                                                         if ([categories count])
                                                         {
                                                             STAApp *newApp = [NSEntityDescription insertNewObjectForEntityForName:@"App" inManagedObjectContext:context];
                                                             
                                                             [newApp setAppID:appID];
                                                             [newApp setCountry:[appData country]];
                                                             
                                                             NSString *baseAppURLString = [appData appURLString];
                                                             
                                                             NSString *countryCode = [appData country];
                                                             
                                                             NSMutableString *affiliateAppURLString = [baseAppURLString mutableCopy];
                                                             
                                                             if ([[[self affiliateCodesDictionary] allKeys] containsObject:countryCode])
                                                             {
                                                                 NSRange locationOfQuestionMark = [affiliateAppURLString rangeOfString:@"?" options:NSBackwardsSearch];
                                                                 NSRange locationOfSlash = [affiliateAppURLString rangeOfString:@"/" options:NSBackwardsSearch];
                                                                 
                                                                 if (locationOfQuestionMark.location != NSNotFound && locationOfQuestionMark.location > locationOfSlash.location)
                                                                     [affiliateAppURLString appendString:@"&"];
                                                                 else 
                                                                     [affiliateAppURLString appendString:@"?"];
                                                                 [affiliateAppURLString appendString:[[self affiliateCodesDictionary] objectForKey:countryCode]];
                                                             }
                                                             [newApp setAppURLString:affiliateAppURLString];
                                                             [affiliateAppURLString release];
                                                             
                                                             [newApp setPriceTier:[appData priceTier]];
                                                             [newApp setScreenshotURLString:[appData screenshotURLString]];
                                                             [newApp setCreationDate:[NSDate date]];
                                                             [newApp setCategories:categories];
                                                             
                                                             if (argAsSearch)
                                                                 [searchOrderedAppIDs addObject:appID];
                                                         }
                                                     }
                                                     
                                                     NSError *saveError;
                                                     if ([context save:&saveError] == NO)
                                                     {
                                                         NSLog(@"Error saving context: %@", [saveError userInfo]);
                                                         [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:STASearchErrorNotification waitUntilDone:NO];
                                                     }
                                                     
                                                     if (argAsSearch)
                                                     {
                                                         [[NSUserDefaults standardUserDefaults] setObject:searchOrderedAppIDs forKey:STADefaultsLastSearchAppIDsKey];
                                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                                         
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:STASearchCompleteNotification object:searchOrderedAppIDs];
                                                     }
                                                 }
                                             }];
        
        [[self operationQueue] addOperation:importOperation];
    }
}

#pragma mark - Affiliate Codes

- (NSDictionary*)affiliateCodesDictionary
{
    if (affiliateCodesDictionary_gv)
        return affiliateCodesDictionary_gv;
    affiliateCodesDictionary_gv = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   @"partnerId=30&siteID=XcCW00SXEtY", @"US",
                                   @"partnerId=30&siteID=XcCW00SXEtY", @"CA",
                                   @"partnerId=30&siteID=XcCW00SXEtY", @"MX",
                                   @"partnerId=1002&affToken=64309", @"AU",
                                   @"partnerId=1002&affToken=64309", @"NZ",
                                   @"partnerId=2003&tduid=AT2037976", @"AT",
                                   @"partnerId=2003&tduid=BE2037978", @"BE",
                                   @"partnerId=2003&tduid=CH2037979", @"CH",
                                   @"partnerId=2003&tduid=DE2037980", @"DE",
                                   @"partnerId=2003&tduid=DK2037982", @"DK",
                                   @"partnerId=2003&tduid=ES2037985", @"ES",
                                   @"partnerId=2003&tduid=FI2037987", @"FI",
                                   @"partnerId=2003&tduid=FR2037988", @"FR",
                                   @"partnerId=2003&tduid=IE2037989", @"IE",
                                   @"partnerId=2003&tduid=IT2037991", @"IT",
                                   @"partnerId=2003&tduid=LT2037999", @"LT",
                                   @"partnerId=2003&tduid=NL2037993", @"NL",
                                   @"partnerId=2003&tduid=NO2037995", @"NO",
                                   @"partnerId=2003&tduid=PL2038001", @"PL",
                                   @"partnerId=2003&tduid=PT2038002", @"PT",
                                   @"partnerId=2003&tduid=SE2037997", @"SE",
                                   @"partnerId=2003&tduid=UK2031437", @"GB",
                                   @"partnerId=2003&tduid=BG2038003", @"BG",
                                   @"partnerId=2003&tduid=CY2038003", @"CY",
                                   @"partnerId=2003&tduid=CZ2038003", @"CZ",
                                   @"partnerId=2003&tduid=EE2038003", @"EE",
                                   @"partnerId=2003&tduid=GR2038003", @"GR",
                                   @"partnerId=2003&tduid=HU2038003", @"HU",
                                   @"partnerId=2003&tduid=LU2038003", @"LU",
                                   @"partnerId=2003&tduid=LV2038003", @"LV",
                                   @"partnerId=2003&tduid=MT2038003", @"MT",
                                   @"partnerId=2003&tduid=RO2038003", @"RO",
                                   @"partnerId=2003&tduid=SI2038003", @"SI",
                                   @"partnerId=2003&tduid=SK2038003", @"SK",
                                   @"partnerId=2003&tduid=BR2048953", @"BR",
                                   @"partnerId=2003&tduid=AR2110103", @"AR",
                                   @"partnerId=2003&tduid=CL2110105", @"CL",
                                   @"partnerId=2003&tduid=CO2110107", @"CO",
                                   @"partnerId=2003&tduid=CR2110109", @"CR",
                                   @"partnerId=2003&tduid=SV2110110", @"SV",
                                   @"partnerId=2003&tduid=HN2110112", @"HN",
                                   @"partnerId=2003&tduid=PA2110114", @"PA",
                                   @"partnerId=2003&tduid=PY2110115", @"PY",
                                   @"partnerId=2003&tduid=PE2110116", @"PE",
                                   nil];
    return affiliateCodesDictionary_gv;
}

#pragma mark - Property Synthesis

//@synthesize appsToImport;
@synthesize persistentStoreCoordinator;
@synthesize operationQueue;

@end
