//
//  SeeTheAppAppDelegate.m
//  SeeTheApp
//
//  Created by goVertex on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SeeTheAppAppDelegate.h"
#include <sys/xattr.h>

@implementation UINavigationBar (UINavigationBarCategory)

- (void)drawRect:(CGRect)rect
{
    UIImage *img;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        img = [UIImage imageNamed:@"STANavigationBarHD.png"];
    else
        img = [UIImage imageNamed:@"STANavigationBar.png"];
    [img drawInRect:rect];
}

@end

@implementation SeeTheAppAppDelegate

#pragma mark - Property Synthesis

@synthesize window=_window;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

#pragma mark - Application Lifecycle

+ (void)initialize
{
    NSString *preferenceListPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
    
    NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:preferenceListPath];
    
    NSMutableArray *settingsArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *defaultSettingsDictionary = [NSMutableDictionary dictionary];
    
    for (NSDictionary *settingDict in settingsArray)
    {
        NSString *settingKey = [settingDict objectForKey:@"Key"];
        if (settingKey)
        {
            id settingDefaultValue = [settingDict objectForKey:@"DefaultValue"];
            [defaultSettingsDictionary setObject:settingDefaultValue forKey:settingKey];
        }
    }
    
    // State Defaults
    [defaultSettingsDictionary setObject:[NSNumber numberWithInteger:STACategoryNone] forKey:STADefaultsLastCategoryKey];
    [defaultSettingsDictionary setObject:[NSNumber numberWithInteger:STAPriceTierAll] forKey:STADefaultsLastListPriceTierKey];
    [defaultSettingsDictionary setObject:[NSDictionary dictionary] forKey:STADefaultsLastPositionsDictionaryKey];
    [defaultSettingsDictionary setObject:@"None" forKey:STADefaultsLastAppStoreCountryKey];
    [defaultSettingsDictionary setObject:[NSNumber numberWithBool:STAPriceTierAll] forKey:STADefaultsLastSearchPriceTierKey];
    [defaultSettingsDictionary setObject:[NSString stringWithFormat:@""] forKey:STADefaultsLastSearchTermKey];
    [defaultSettingsDictionary setObject:[NSNumber numberWithInteger:0] forKey:STADefaultsLastSearchCategoryKey];
    [defaultSettingsDictionary setObject:[NSNumber numberWithInteger:STASearchStateNone] forKey:STADefaultsLastSearchStateKey];
    [defaultSettingsDictionary setObject:[NSDate dateWithTimeIntervalSince1970:0] forKey:STADefaultsLastXMLDownloadDateKey];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultSettingsDictionary];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{        
    #ifdef LOG_ApplicationLifecycle
        NSLog(@"DID FINISH LAUNCHING **************************************");
    #endif
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    NSString *appFirstStartOfVersionKey = [NSString stringWithFormat:@"first_start_%@", bundleVersion];
    
    NSNumber *alreadyStartedOnVersion = [defaults objectForKey:appFirstStartOfVersionKey];
    if(!alreadyStartedOnVersion || [alreadyStartedOnVersion boolValue] == NO) 
    {        
        NSDictionary *lastDisplayedIndexDictionary = [defaults valueForKey:@"LastDisplayedIndexDictionaryKey"];
        if ([[lastDisplayedIndexDictionary allKeys] count] > 0)
        {
            NSMutableDictionary *newLastPositionsDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults valueForKey:STADefaultsLastPositionsDictionaryKey]];
            for (NSString *key in [lastDisplayedIndexDictionary allKeys])
            {
                NSInteger displayIndexValue = [[lastDisplayedIndexDictionary valueForKey:key] integerValue];
                NSString *newKey = [key substringToIndex:6];
                
                [newLastPositionsDictionary setValue:[NSNumber numberWithInteger:displayIndexValue] forKey:newKey];
            }
            [defaults setValue:[NSDictionary dictionary] forKey:@"LastDisplayedIndexDictionaryKey"];
            [defaults setValue:newLastPositionsDictionary forKey:STADefaultsLastPositionsDictionaryKey];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:appFirstStartOfVersionKey];
    }
    
    NSString *lastAppStoreCountryCode = [defaults objectForKey:STADefaultsLastAppStoreCountryKey];
    
    NSString *userSelectedAppStoreCountryCode = [defaults objectForKey:STADefaultsAppStoreCountryKey];
    
    #ifdef LOG_AppStoreCountryChanges
        NSLog(@"App Launching - Last App Store: %@ | User App Store: %@", lastAppStoreCountryCode, userSelectedAppStoreCountryCode);
    #endif
    
    if ([lastAppStoreCountryCode isEqual:@"None"])
    {
        NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        if ([[self appStoreCountryCodes] containsObject:countryCode])
        {
            #ifdef LOG_AppStoreCountryChanges
                NSLog(@"App Store country was None, changing to %@ based on user country code of: %@", countryCode, countryCode);
            #endif
            
            [[NSUserDefaults standardUserDefaults] setValue:countryCode forKey:STADefaultsLastAppStoreCountryKey];
            [[NSUserDefaults standardUserDefaults] setValue:countryCode forKey:STADefaultsAppStoreCountryKey];
            [[NSUserDefaults standardUserDefaults] synchronize];            
        }
        else
        {
            #ifdef LOG_AppStoreCountryChanges
                NSLog(@"App Store country was None, changing to US based on user country code of: %@", countryCode);
            #endif
            
            [[NSUserDefaults standardUserDefaults] setValue:@"US" forKey:STADefaultsLastAppStoreCountryKey];
            [[NSUserDefaults standardUserDefaults] setValue:@"US" forKey:STADefaultsAppStoreCountryKey];
            [[NSUserDefaults standardUserDefaults] synchronize];            
        }
        
        [self performSelector:@selector(populateInitialAppsForCurrentCountry) withObject:nil afterDelay:0.1];        
    }
    else if ([lastAppStoreCountryCode isEqual:userSelectedAppStoreCountryCode] == NO)
    {
        #ifdef LOG_AppStoreCountryChanges
            NSLog(@"App Store country changed from: %@ to %@", lastAppStoreCountryCode, userSelectedAppStoreCountryCode);
        #endif
        
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"UserChangedAppStore" attributes:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@_to_%@", lastAppStoreCountryCode, userSelectedAppStoreCountryCode] forKey:@"CountryChange"]];
        
        [[NSUserDefaults standardUserDefaults] setValue:userSelectedAppStoreCountryCode forKey:STADefaultsLastAppStoreCountryKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSelector:@selector(populateInitialAppsForCurrentCountry) withObject:nil afterDelay:0.1];
    }
    
    // Views
    [[self window] setBackgroundColor:[UIColor blackColor]];
    [[self window] setRootViewController:[self navigationController]];
    [self.window makeKeyAndVisible];
    [self restoreLastDisplayMode];  
        
    // Start Localytics
    [[LocalyticsSession sharedLocalyticsSession] startSession:AnaylticsID];

    // Reachability
    Reachability *tempReachability = [Reachability reachabilityForInternetConnection];
    [self setReachability:tempReachability];
    
    NetworkStatus status = [[self reachability] currentReachabilityStatus];
    if (status == ReachableViaWiFi || status == ReachableViaWWAN)
        [self setHasNetworkConnection:YES];
    else
        [self setHasNetworkConnection:NO];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [tempReachability startNotifier];
        
    [self startDownloadStarterTimer];
    
    if ([[NSDate date] timeIntervalSinceDate:[defaults objectForKey:STADefaultsLastXMLDownloadDateKey]] > 14400)
        [self startXMLDownloads];
    
    [[NSNotificationCenter defaultCenter] addObserver:[self managedObjectContext] selector:@selector(mergeChangesFromContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    #ifdef LOG_ApplicationLifecycle
        NSLog(@"WILL ENTER FOREGROUND **************************************");
    #endif
    
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *lastCountryCode = [[NSUserDefaults standardUserDefaults] objectForKey:STADefaultsLastAppStoreCountryKey];
    NSString *currentCountryCode = [[NSUserDefaults standardUserDefaults] objectForKey:STADefaultsAppStoreCountryKey];
    
    #ifdef LOG_AppStoreCountryChanges
        NSLog(@"App returning from background - Last App Store: %@ | User App Store: %@", lastCountryCode, currentCountryCode);
    #endif
    
    if ([lastCountryCode isEqualToString:currentCountryCode] == NO)
    {
        #ifdef LOG_AppStoreCountryChanges
            NSLog(@"App Store country changed from: %@ to %@", lastCountryCode, currentCountryCode);
        #endif
        
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"UserChangedAppStore" attributes:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@_to_%@", lastCountryCode, currentCountryCode] forKey:@"CountryChange"]];
        
        // Get the last viewed category..... regardless of country.... because it should still be the same...
        
        enum STADisplayMode lastDisplayMode = (enum STADisplayMode)[[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastModeKey] integerValue];
        [self updateAppStoreCountry:currentCountryCode];
        
        if (lastDisplayMode == STADisplayModeList)
        {
            [[self galleryViewController] displayMode:STADisplayModeList];
            NSInteger lastCategory = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastCategoryKey] integerValue];
            [[self galleryViewController] displayCategory:lastCategory forAppStoreCountryCode:currentCountryCode];   
        }
        else if (lastDisplayMode == STADisplayModeBrowse)
        {
            [[self galleryViewController] displayMode:STADisplayModeBrowse];
            [[self galleryViewController] displayCategory:STACategoryBrowse forAppStoreCountryCode:currentCountryCode];
        }
        else
        {
            [[self galleryViewController] displayMode:STADisplayModeSearch];
            
            NSInteger lastSearchCategory = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastSearchCategoryKey] integerValue];
            if (lastSearchCategory == 0)
                [[self galleryViewController] displayCategory:STACategorySearchResult forAppStoreCountryCode:currentCountryCode];
            else
                [[self galleryViewController] displayCategory:lastSearchCategory forAppStoreCountryCode:currentCountryCode];
        }
        
        [self performSelector:@selector(populateInitialAppsForCurrentCountry) withObject:nil afterDelay:0.1];
    }
    
    [[[self galleryViewController] galleryView] reloadData];
    [[self galleryViewController] updateDownloads];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[self reachability] startNotifier];
    
    NetworkStatus status = [[self reachability] currentReachabilityStatus];
    if (status == ReachableViaWiFi || status == ReachableViaWWAN)
        [self setHasNetworkConnection:YES];
    else
        [self setHasNetworkConnection:NO];
    
    [self startDownloadStarterTimer];
    
    if ([[NSDate date] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:STADefaultsLastXMLDownloadDateKey]] > 14400)
        [self startXMLDownloads];
    
    if (optionsViewController_gv)
        [[self optionsViewController] refreshAppStoreCountryLabel];
    
    [self relocalizeText];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    #ifdef LOG_ApplicationLifecycle
        NSLog(@"DID ENTER BACKGROUND *************************************");
    #endif
    
    if ([[[self navigationController] visibleViewController] isEqual:galleryViewController_gv])
        [self updateLastPosition:[[self galleryViewController] positionOfCurrentRow]];
    
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    // if we are doing a core data save...... we have to save for background task
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[self reachability] stopNotifier];
    
    [self stopDownloadStarterTimer];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(presentRateAndFeedbackAlert) object:nil];    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    #ifdef LOG_ApplicationLifecycle
        NSLog(@"WILL TERMINATE **************************************");
    #endif
    
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
    if ([[[self navigationController] visibleViewController] isEqual:galleryViewController_gv])
        [self updateLastPosition:[[self galleryViewController] positionOfCurrentRow]];
    
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
        
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[self reachability] stopNotifier];
    
    // cancel core data save, or try to get extra time to finish it 
    
    [self stopDownloadStarterTimer];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc
{
    if (currentListDownloadConnections_gv)
        CFRelease(currentListDownloadConnections_gv);
    [pendingListDownloadURLStrings_gv release];
    
    if (currentImageDownloadConnections_gv)
        CFRelease(currentImageDownloadConnections_gv);
    [pendingImageDownloadURLStrings_gv release];
    
    if (currentXMLDownloadConnections_gv)
        CFRelease(currentXMLDownloadConnections_gv);
    [pendingXMLDownloadURLStrings_gv release];
    
    if (currentListJSONDownloadConnections_gv)
        CFRelease(currentListJSONDownloadConnections_gv);
    [pendingListJSONDownloadURLStrings_gv release];
    
    [pathForImageDataDirectory_gv release];
    
    [appStoreCountryCodes_gv release];
    [affiliateCodesDictionary_gv release];
    
    [applicationLibrarySTADirectory_gv release];
    
    [categories_gv release];
    
    [self setReachability:nil];
    
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

- (void)restoreLastDisplayMode
{
    enum STADisplayMode lastDisplayMode = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastModeKey] integerValue];
    NSString *currentCountry = [[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsAppStoreCountryKey];
    enum STACategory lastCategory = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastCategoryKey] integerValue];
    NSInteger lastPosition = [self lastPositionForCategory:lastCategory];
    
    switch (lastDisplayMode) 
    {
        case STADisplayModeBrowse:
        {
            [[self galleryViewController] view];
            [[self galleryViewController] displayMode:STADisplayModeBrowse];
            [[self galleryViewController] displayCategory:lastCategory forAppStoreCountryCode:currentCountry];
            [[self navigationController] pushViewController:[self galleryViewController] animated:NO];
            [[self galleryViewController] displayPosition:lastPosition forPriceTier:STAPriceTierAll];
            [[self galleryViewController] updateDownloads];
            break;
        }
        case STADisplayModeList:
        {
            [[self navigationController] pushViewController:[self categoriesMenuViewController] animated:NO];
            if (lastCategory >= STACategoryGamesAction || lastCategory == STACategoryGames)
                [[self navigationController] pushViewController:[self gamesSubcategoriesMenuViewController] animated:NO];
            enum STAPriceTier lastPriceTier = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastListPriceTierKey] integerValue];
            [[self galleryViewController] view];
            [[self galleryViewController] displayMode:STADisplayModeList];
            [[self galleryViewController] displayCategory:lastCategory forAppStoreCountryCode:currentCountry];
            [[self navigationController] pushViewController:[self galleryViewController] animated:NO];
            [[self galleryViewController] displayPosition:lastPosition forPriceTier:lastPriceTier];
            [[self galleryViewController] updateDownloads];
            break;
        }
        case STADisplayModeCategoriesMenu:
            [[self navigationController] pushViewController:[self categoriesMenuViewController] animated:NO];
            break;
        case STADisplayModeGameCategoriesMenu:
            [[self navigationController] pushViewController:[self categoriesMenuViewController] animated:NO];
            [[self navigationController] pushViewController:[self gamesSubcategoriesMenuViewController] animated:NO];
            break;
        case STADisplayModeOptionsMenu:
            [[self navigationController] pushViewController:[self optionsViewController] animated:NO];
            break;
        case STADisplayModeSearch:
        {
            [[self galleryViewController] view];
            [[self galleryViewController] displayMode:STADisplayModeSearch];
            
            NSInteger lastSearchCategory = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastSearchCategoryKey] integerValue];
            if (lastSearchCategory == 0)
                [[self galleryViewController] displayCategory:lastCategory forAppStoreCountryCode:currentCountry];
            else
                [[self galleryViewController] displayCategory:lastSearchCategory forAppStoreCountryCode:currentCountry];
            
            [[self navigationController] pushViewController:[self galleryViewController] animated:NO];
            [[self galleryViewController] displayPosition:lastPosition forPriceTier:[[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastSearchPriceTierKey] integerValue]];
            [[self galleryViewController] updateDownloads];
            break;
        }
        default:
            break;
    }
}

- (void)relocalizeText
{
    //NSLog(@"Relocalizing text");
    
    if (categoriesInfo_gv)
    {
        [categoriesInfo_gv release];
        categoriesInfo_gv = nil;
        [self categoriesInfo];
    }
    
    if (gameCategoriesInfo_gv)
    {
        [gameCategoriesInfo_gv release];
        gameCategoriesInfo_gv = nil;
        [self gameCategoriesInfo];
    }

    if (mainMenuViewController_gv)
        [[self mainMenuViewController] resetText];
    
    if (categoriesMenuViewController_gv)
        [[self categoriesMenuViewController] resetText];
    
    if (gamesSubcategoriesMenuViewController_gv)
        [[self gamesSubcategoriesMenuViewController] resetText];
    
    if (optionsViewController_gv)
        [[self optionsViewController] resetText];
    
    if (galleryViewController_gv)
    {
        enum STADisplayMode lastDisplayMode = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastModeKey] integerValue];
        if (lastDisplayMode == STADisplayModeList)
        {            
            enum STACategory currentCategory = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastCategoryKey] integerValue];
            
            if (currentCategory >= STACategoryGamesAction || currentCategory == STACategoryGames)
            {
                
                NSUInteger indexOfCategory = [[self gameCategoriesInfo] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
                    
                    if([[(NSDictionary*)obj valueForKey:@"CategoryCode"] integerValue] == currentCategory)
                        return YES;
                    return NO;
                }];
                
                if (indexOfCategory == NSNotFound)
                    NSLog(@"Category Not Found");
                else
                {
                    NSString *categoryName = [[[self gameCategoriesInfo] objectAtIndex:indexOfCategory] valueForKey:@"CategoryName"];
                    [[self galleryViewController] setTitle:categoryName];
                }
            }
            else
            {
                NSUInteger indexOfCategory = [[self categoriesInfo] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
                    
                    if([[(NSDictionary*)obj valueForKey:@"CategoryCode"] integerValue] == currentCategory)
                        return YES;
                    return NO;
                }];
                
                if (indexOfCategory == NSNotFound)
                    NSLog(@"Category Not Found");
                else
                {
                    NSString *categoryName = [[[self categoriesInfo] objectAtIndex:indexOfCategory] valueForKey:@"CategoryName"];
                    //[[[self galleryViewController] navigationItem] setTitle:categoryName];
                    [[self galleryViewController] setTitle:categoryName];
                }
            }
        }
        else if (lastDisplayMode == STADisplayModeSearch)
            [[self galleryViewController] setTitle:@""];
        else
            [[self galleryViewController] setTitle:NSLocalizedString(@"All Apps", @"All Apps")];
        
        [[self galleryViewController] resetText];
        [[[self galleryViewController] galleryView] reloadData];
    }
}

#pragma mark - Core Data Save

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}

#pragma mark - App Download Methods

- (void)startXMLDownloads
{
    // Should really keep track of failure... and only update the last updated date once we have successfully retreived the apps...
    
    [[self pendingXMLDownloadURLStrings] removeAllObjects];
    // TODO: Generate the pending XML download URLs
    
    for (NSDictionary *categoryInfo in [self categoriesInfo])
    {
        
    }
    for (NSDictionary *gameCategoryInfo in [self gameCategoriesInfo])
    {
        // skip the all games category
    }
    
    // for each category
        // for each listtype
            // construct xmlString
            // add to pending downloads
    
    // Add the pending XML download URLs
    [self startPendingXMLDownloads];
}

#pragma mark - Download Starter Timed Evaluation

- (void)startDownloadStarterTimer
{
    NSTimer *tempDownloadStarterTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timedDownloadStartEvaluation) userInfo:nil repeats:YES];
    [self setDownloadStarterTimer:tempDownloadStarterTimer];
}

- (void)stopDownloadStarterTimer
{
    [[self downloadStarterTimer] invalidate];
    [self setDownloadStarterTimer:nil];
}

- (void)timedDownloadStartEvaluation
{
    [self checkPendingConnections];
}

#pragma mark - Reachability

- (void)reachabilityChanged:(NSNotification*)reachabilityNotification
{
    NetworkStatus status = [[self reachability] currentReachabilityStatus];
    if (status == ReachableViaWiFi || status == ReachableViaWWAN)
    {
        #ifdef LOG_ReachabilityChangeNotifications
            NSLog(@"Reachability changed to reachable");
        #endif
        BOOL previousHasNetworkConnectionValue = [self hasNetworkConnection];
        [self setHasNetworkConnection:YES];
        if (previousHasNetworkConnectionValue == NO)
            [[[self galleryViewController] galleryView] reloadData];
    }
    else
    {
        #ifdef LOG_ReachabilityChangeNotifications
            NSLog(@"Reachability changed to unreachable");
        #endif
        BOOL previousHasNetworkConnectionValue = [self hasNetworkConnection];
        [self setHasNetworkConnection:NO];
        if (previousHasNetworkConnectionValue == YES)
            [[[self galleryViewController] galleryView] reloadData];
    }
}

#pragma mark - Connection Start

- (void)checkPendingConnections
{    
    if ([[self pendingListDownloadURLStrings] count] > 0)
    {
        if (CFDictionaryGetCount([self currentListDownloadConnections]) == 0)
        {
            #ifdef LOG_DownloadActivity
                NSLog(@"List download starting");
            #endif
            
            NSString *connectionURLStringToStart = [[self pendingListDownloadURLStrings] objectAtIndex:0];
            NSURL *url = [NSURL URLWithString:connectionURLStringToStart];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setValue:@"STAClient" forHTTPHeaderField:@"User-Agent"];
            
            NSMutableDictionary *connectionDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:connectionURLStringToStart, STAConnectionURLStringKey, [NSMutableData data], STAConnectionDataKey, nil];
            
            NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
            
            CFDictionaryAddValue([self currentListDownloadConnections], connection, connectionDict);
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];     
            
            [request release];
            
            [[self pendingListDownloadURLStrings] removeObjectAtIndex:0];
        }
    }
    
    if ([[self pendingImageDownloadURLStrings] count] > 0)
    {
        NSInteger currentConnections = CFDictionaryGetCount([self currentImageDownloadConnections]);
        if (currentConnections < 3)
        {
            for (int connectionCounter = 0; connectionCounter < (3 - currentConnections); connectionCounter++)
            {
                if ([[self pendingImageDownloadURLStrings] count] == 0)
                    break;
                
                #ifdef LOG_DownloadActivity
                    NSLog(@"Image download starting");
                #endif
                
                NSString *imageURLString = [[self pendingImageDownloadURLStrings] objectAtIndex:0];
                NSURL *imageURL = [NSURL URLWithString:imageURLString];
                NSURLRequest *imageRequest = [NSURLRequest requestWithURL:imageURL];
                
                NSMutableDictionary *connectionDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:imageURLString, STAConnectionURLStringKey, [NSMutableData data], STAConnectionDataKey, nil];
                
                NSURLConnection *imageDownloadConnection = [NSURLConnection connectionWithRequest:imageRequest delegate:self];
                
                CFDictionaryAddValue([self currentImageDownloadConnections], imageDownloadConnection, connectionDict);
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                
                [[self pendingImageDownloadURLStrings] removeObjectAtIndex:0];
            }
        }
    }
}

#pragma mark - Populate Initial Apps for Current Country

- (void)populateInitialAppsForCurrentCountry
{
    NSFetchRequest *currentDisplayIndexesFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DisplayIndex"];
    
    NSString *currentCountry = [[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsAppStoreCountryKey];
    
    NSString *predicateString = [NSString stringWithFormat:@"positionIndex == 0 AND country like '%@'", currentCountry];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    
    [currentDisplayIndexesFetchRequest setPredicate:predicate];
    
    NSArray *currentDisplayIndices = [[self managedObjectContext] executeFetchRequest:currentDisplayIndexesFetchRequest error:nil];
    [currentDisplayIndexesFetchRequest release];
    
    if ([currentDisplayIndices count] == 0)
    {
        // Add seaquations
                
        NSString *countryCode = [[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsAppStoreCountryKey];
        
        NSString *seaquationsScreenshotImageURLString; 
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            seaquationsScreenshotImageURLString = [NSString stringWithFormat:@"http://a2.mzstatic.com/%@/r1000/083/Purple/bc/70/b5/mzl.nqygrekj.1024x1024-65.jpg", countryCode];
            NSString *screenshotBundlePath = [[NSBundle mainBundle] pathForResource:@"SeaquationsScreenshotHD" ofType:@"png"];
            NSString *destinationPath = [self filePathOfImageDataForURLString:seaquationsScreenshotImageURLString];
            
            NSError *fileCopyError = nil;
            if(![[NSFileManager defaultManager] copyItemAtPath:screenshotBundlePath toPath:destinationPath error:&fileCopyError])
                [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"FailedToCopySeaquationsScreenshot" attributes:[NSDictionary dictionaryWithObject:[fileCopyError localizedDescription] forKey:@"ErrorDescription"]];
        }
        else
        {
            seaquationsScreenshotImageURLString = [NSString stringWithFormat:@"http://a3.mzstatic.com/%@/r1000/102/Purple/60/e0/30/mzl.mujovijy.png", countryCode];
            NSString *screenshotBundlePath = [[NSBundle mainBundle] pathForResource:@"SeaquationsScreenshot" ofType:@"png"];
            NSString *destinationPath = [self filePathOfImageDataForURLString:seaquationsScreenshotImageURLString];
            
            NSError *fileCopyError = nil;
            if(![[NSFileManager defaultManager] copyItemAtPath:screenshotBundlePath toPath:destinationPath error:&fileCopyError])
                [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"FailedToCopySeaquationsScreenshot" attributes:[NSDictionary dictionaryWithObject:[fileCopyError localizedDescription] forKey:@"ErrorDescription"]];
        }
        
        NSString *affiliateString = @"";
            if ([[[self affiliateCodesDictionary] allKeys] containsObject:countryCode])
                affiliateString = [[self affiliateCodesDictionary] objectForKey:countryCode];
        
        NSString *appURLString = [NSString stringWithFormat:@"http://itunes.apple.com/%@/app/id447974258?mt=8&uo=4%@", countryCode, affiliateString];
                
        NSArray *seaquationsCategories = [NSArray arrayWithObjects:
                                          [NSNumber numberWithInteger:STACategoryBrowse], 
                                          [NSNumber numberWithInteger:STACategoryGames],
                                          [NSNumber numberWithInteger:STACategoryGamesEducational],
                                          [NSNumber numberWithInteger:STACategoryGamesKids],
                                          [NSNumber numberWithInteger:STACategoryEducation],
                                          nil];
        
        for (NSNumber *category in seaquationsCategories)
        {
            NSManagedObject *seaquationsDisplayIndex = [NSEntityDescription insertNewObjectForEntityForName:@"DisplayIndex" inManagedObjectContext:[self managedObjectContext]];
            [seaquationsDisplayIndex setValue:[NSNumber numberWithInteger:447974258] forKey:STADisplayIndexAttributeAppID];
            [seaquationsDisplayIndex setValue:appURLString forKey:STADisplayIndexAttributeAppURL];
            [seaquationsDisplayIndex setValue:seaquationsScreenshotImageURLString forKey:STADisplayIndexAttributeScreenshotURL];
            [seaquationsDisplayIndex setValue:[NSNumber numberWithInteger:0] forKey:STADisplayIndexAttributePositionIndex];
            [seaquationsDisplayIndex setValue:[NSNumber numberWithInteger:1] forKey:STADisplayIndexAttributePriceTier];
            [seaquationsDisplayIndex setValue:category forKey:STADisplayIndexAttributeCategory];
            [seaquationsDisplayIndex setValue:countryCode forKey:STADisplayIndexAttributeCountry];
        }
                
        [self saveContext];
    }
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection*)argConnection didReceiveResponse:(NSURLResponse*)argResponse
{    
    [self updateNetworkActivityIndicator];
    
    NSMutableDictionary *connectionDictionary = CFDictionaryGetValue([self currentListDownloadConnections], argConnection);
    if (connectionDictionary != NULL)
    {                
        [connectionDictionary setObject:[NSMutableData data] forKey:STAConnectionDataKey];
        return;
    }
    
    connectionDictionary = CFDictionaryGetValue([self currentImageDownloadConnections], argConnection);
    if (connectionDictionary != NULL)
    {
        [connectionDictionary setObject:[NSMutableData data] forKey:STAConnectionDataKey];
        return;
    }
    
    connectionDictionary = CFDictionaryGetValue([self currentSearchDownloadConnection], argConnection);
    if (connectionDictionary != NULL)
    {
        [connectionDictionary setObject:[NSMutableData data] forKey:STAConnectionDataKey];
        return;
    }
    
    // Bad Connection
    NSLog(@"Ghost Connection in did receive response");
}

- (void)connection:(NSURLConnection*)argConnection didReceiveData:(NSData*)argData
{
    [self updateNetworkActivityIndicator];
    
    NSMutableDictionary *connectionDictionary = CFDictionaryGetValue([self currentListDownloadConnections], argConnection);
    if (connectionDictionary != NULL)
    {
        NSMutableData *connectionData = [connectionDictionary objectForKey:STAConnectionDataKey];
        [connectionData appendData:argData];
        return;
    }
    
    connectionDictionary = CFDictionaryGetValue([self currentImageDownloadConnections], argConnection);
    if (connectionDictionary != NULL)
    {
        NSMutableData *connectionData = [connectionDictionary objectForKey:STAConnectionDataKey];
        [connectionData appendData:argData];
        return;
    }
    
    connectionDictionary = CFDictionaryGetValue([self currentSearchDownloadConnection], argConnection);
    if (connectionDictionary != NULL)
    {
        NSMutableData *connectionData = [connectionDictionary objectForKey:STAConnectionDataKey];
        [connectionData appendData:argData];
        return;
    }
    
    // Bad connection
    NSLog(@"Ghost Connection in did receive data");
}

- (void)connectionDidFinishLoading:(NSURLConnection*)argConnection
{    
    NSMutableDictionary *connectionDictionary = CFDictionaryGetValue([self currentListDownloadConnections], argConnection);
    if (connectionDictionary != NULL)
    {
        NSMutableData *connectionData = [connectionDictionary objectForKey:STAConnectionDataKey];
        if (connectionData)
        {   
            #ifdef LOG_DownloadActivity
                NSString *dataString = [[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding];
                NSLog(@"List download completed with data: %@", dataString);
                [dataString release];
            #endif
            
            // how to check if this data is a valid json response or just an error code....
            
            NSString *jsonString = [[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding];
            NSDictionary *appListDictionary = [jsonString JSONValue];
            [jsonString release];
            
            if (appListDictionary)
                [self processNewAppsInDictionary:appListDictionary];
            else
                [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"InvalidJSONResponse" attributes:[NSDictionary dictionaryWithObject:[connectionDictionary objectForKey:STAConnectionURLStringKey] forKey:@"URL"]];
        }
             
        CFDictionaryRemoveValue([self currentListDownloadConnections], argConnection);
        
        if ([[self pendingListDownloadURLStrings] count] > 0)
        {
            #ifdef LOG_DownloadActivity
                NSLog(@"List download starting");
            #endif

            NSString *nextListURLString = [[self pendingListDownloadURLStrings] objectAtIndex:0];
            
            NSMutableDictionary *connectionDictionaryToStart = [NSMutableDictionary dictionaryWithObjectsAndKeys:nextListURLString, STAConnectionURLStringKey, [NSMutableData data], STAConnectionDataKey, nil];
                                            
            NSURL *listURL = [NSURL URLWithString:nextListURLString];
            NSMutableURLRequest *listRequest = [NSMutableURLRequest requestWithURL:listURL];
            [listRequest setValue:@"stav102" forHTTPHeaderField:@"User-Agent"];
                        
            NSURLConnection *listDownloadConnection = [NSURLConnection connectionWithRequest:listRequest delegate:self];
            
            CFDictionaryAddValue([self currentListDownloadConnections], listDownloadConnection, connectionDictionaryToStart);
            
            [[self pendingListDownloadURLStrings] removeObjectAtIndex:0];
        }
        
        [self updateNetworkActivityIndicator];
        return;
    }
    
    connectionDictionary = CFDictionaryGetValue([self currentXMLDownloadConnections], argConnection);
    if (connectionDictionary != NULL)
    {
        #ifdef LOG_DownloadActivity 
            NSLog(@"XML download completed"); 
        #endif
        [self processXMLDownloadData:connectionDictionary];
        CFDictionaryRemoveValue([self currentXMLDownloadConnections], argConnection);
        [self startPendingXMLDownloads];
        [self updateNetworkActivityIndicator];
        return;
    }
    
    connectionDictionary = CFDictionaryGetValue([self currentListJSONDownloadConnections], argConnection);
    if (connectionDictionary != NULL)
    {
        #ifdef LOG_DownloadActivity 
            NSLog(@"List JSON download completed"); 
        #endif
        [self processListJSONDownloadData:connectionDictionary];
        CFDictionaryRemoveValue([self currentListJSONDownloadConnections], argConnection);
        [self startPendingListJSONDownloads];
        [self updateNetworkActivityIndicator];
        return;
    }
    
    connectionDictionary = CFDictionaryGetValue([self currentImageDownloadConnections], argConnection);
    if (connectionDictionary != NULL)
    {
        #ifdef LOG_DownloadActivity 
            NSLog(@"Image download completed"); 
        #endif
        [self processImageDownloadData:connectionDictionary];
        CFDictionaryRemoveValue([self currentImageDownloadConnections], argConnection);
        [self startPendingImageDownloads];
        [self updateNetworkActivityIndicator];
        return;
    }
        
    connectionDictionary = CFDictionaryGetValue([self currentSearchDownloadConnection], argConnection);
    if (connectionDictionary != NULL)
    {
        [self processSearchJSONDownloadData:connectionDictionary];
        CFDictionaryRemoveValue([self currentSearchDownloadConnection], argConnection);
        [self updateNetworkActivityIndicator];
        return;
    }
    
    NSLog(@"Ghost Connection in did finish loading");
}

- (void)connection:(NSURLConnection*)argConnection didFailWithError:(NSError*)argError
{
    NSLog(@"Connection failed");
    
    if (CFDictionaryContainsKey([self currentXMLDownloadConnections], argConnection))
    {
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"XMLDownloadFailure" attributes:[NSDictionary dictionaryWithObject:[argError localizedDescription] forKey:@"Error"]];
        CFDictionaryRemoveValue([self currentXMLDownloadConnections], argConnection);
        [self startPendingXMLDownloads];
    }
    else if (CFDictionaryContainsKey([self currentListJSONDownloadConnections], argConnection))
    {
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"ListJSONDownloadFailure" attributes:[NSDictionary dictionaryWithObject:[argError localizedDescription] forKey:@"Error"]];
        CFDictionaryRemoveValue([self currentListJSONDownloadConnections], argConnection);
        [self startPendingListJSONDownloads];
    }
    else if (CFDictionaryContainsKey([self currentListDownloadConnections], argConnection))
    {
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"ListDownloadFailure" attributes:[NSDictionary dictionaryWithObject:[argError localizedDescription] forKey:@"Error"]];
        CFDictionaryRemoveValue([self currentListDownloadConnections], argConnection);
    }
    else if (CFDictionaryContainsKey([self currentSearchDownloadConnection], argConnection))
    {
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"SearchDownloadFailure" attributes:[NSDictionary dictionaryWithObject:[argError localizedDescription] forKey:@"Error"]];
        
        NSDictionary *searchConnectionDictionary = CFDictionaryGetValue([self currentSearchDownloadConnection], argConnection);
        [[NSNotificationCenter defaultCenter] postNotificationName:STASearchErrorNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[searchConnectionDictionary valueForKey:STAConnectionSearchCategoryKey] forKey:@"STASearchCategory"]];
        CFDictionaryRemoveValue([self currentSearchDownloadConnection], argConnection);
    }
    else
    {
        CFDictionaryRemoveValue([self currentImageDownloadConnections], argConnection);
        [self startPendingImageDownloads];
    }
    
    [self updateNetworkActivityIndicator];
}

#pragma mark - Download Processing Methods

- (void)processXMLDownloadData:(NSDictionary*)argXMLDownloadData
{
    NSMutableData *connectionData = [argXMLDownloadData objectForKey:STAConnectionDataKey];
    if (connectionData)
    {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:connectionData];
        [parser setDelegate:self];
        [self setAppIDsArray:[NSMutableArray array]];
        if([parser parse])
        {
            // Potentially randomize array...
            
            NSMutableString *lookupURLString = [NSMutableString string];
            NSInteger appIDsInLookupString = 0;
            NSString *countryCode = [[NSUserDefaults standardUserDefaults] objectForKey:STADefaultsAppStoreCountryKey];
            
            for (NSNumber *appID in [self appIDsArray])
            {
                if (appIDsInLookupString == 20)
                {
                    [[self pendingListJSONDownloadURLStrings] addObject:[lookupURLString substringToIndex:([lookupURLString length] - 1)]];
                    lookupURLString = [NSMutableString stringWithFormat:@"http://itunes.apple.com/lookup?country=%@id=", countryCode];
                    appIDsInLookupString = 0;
                }
                [lookupURLString appendFormat:@"%d,", [appID integerValue]];
                appIDsInLookupString++;
            }
            
            if (appIDsInLookupString > 0)
                [[self pendingListJSONDownloadURLStrings] addObject:[lookupURLString substringToIndex:([lookupURLString length] - 1)]];
            
            [self startPendingListJSONDownloads];
        }
        else
            NSLog(@"XML Parsing Error: %@", [[parser parserError] localizedDescription]);
        
        [parser release];
    }
}

- (void)processListJSONDownloadData:(NSDictionary*)argListJSONDownloadData
{
    NSData *listJSONData = [argListJSONDownloadData objectForKey:STAConnectionDataKey];

    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSDictionary *listJSONResults = [parser objectWithData:listJSONData];
    
    [parser release];
    
    if (!listJSONResults)
    {
        NSLog(@"Error getting JSON Results from download data");
        return;
    }
    
    if ([[listJSONResults objectForKey:@"resultCount"] integerValue] > 0)
    {
        NSArray *results = [listJSONResults objectForKey:@"results"];
        
        NSMutableDictionary *refinedResults = [NSMutableDictionary dictionary];
        
        NSString *countryCode;
        
        for (NSDictionary *result in results)
        {
            NSString *screenshotArrayKey = @"screenshotUrls";
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                screenshotArrayKey = @"iPadScreenshotUrls";
            
            NSArray *screenshots = [result objectForKey:screenshotArrayKey];
            if ([screenshots count] > 0)
            {
                NSString *screenshotURLString = [screenshots objectAtIndex:0];
            
                NSNumber *priceTier = [NSNumber numberWithInteger:0];
                if ([[result objectForKey:@"price"] floatValue] > 0.00)
                    priceTier = [NSNumber numberWithInteger:1];
                
                NSNumber *appID = [result objectForKey:@"trackId"];
            
                // Categories...
                
                NSDictionary *refinedResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [result objectForKey:@"trackViewUrl"], @"AppURL",
                                               screenshotURLString, @"AppScreenshotURLString",
                                               priceTier, @"PriceTier",
                                               // what about the country....
                                               nil];
                
                [refinedResults setObject:refinedResult forKey:appID];
            }
        }
        
        if ([[refinedResults allKeys] count] == 0)
            return;
        
        NSPredicate *existingAppsFromLookupPredicate = [NSPredicate predicateWithFormat:@"country like %@ AND appID IN %@", countryCode, [refinedResults allKeys]];
        
        NSFetchRequest *existingAppsFromLookupFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"App"];
        [existingAppsFromLookupFetchRequest setPredicate:existingAppsFromLookupPredicate];
        
        NSError *fetchError;
        
        NSArray *existingAppsFromLookup = [[self managedObjectContext] executeFetchRequest:existingAppsFromLookupFetchRequest error:&fetchError];
        
        if (!existingAppsFromLookup)
        {
            NSLog(@"Existing Apps fetch error: %@", [fetchError localizedDescription]);
            return;
        }
        
        NSMutableArray *keysToRemove = [NSMutableArray array];
        
        for (STAApp *existingApp in existingAppsFromLookup)
        {
            NSNumber *appID = [existingApp appID];
            
            NSDictionary *appInfo = [refinedResults objectForKey:appID];
            
            [keysToRemove addObject:appID];
            
            [existingApp setAppURLString:[appInfo objectForKey:@"AppURL"]];
            [existingApp setPriceTier:[appInfo objectForKey:@"PriceTier"]];
            [existingApp setScreenshotURLString:[appInfo objectForKey:@"AppScreenshotURLString"]];
            
            NSMutableSet *categories = [NSMutableSet set];
            
            for (NSNumber *categoryCode in [appInfo objectForKey:@"Categories"])
            {
                STACategory *category = [self categoryForCategoryCode:categoryCode];
                if (category)
                    [categories addObject:category];
            }
            
            [existingApp setCategories:categories];
        }
        
        [refinedResults removeObjectsForKeys:keysToRemove];
        
        for (NSNumber *appID in [refinedResults allKeys])
        {
            NSDictionary *appInfo = [refinedResults objectForKey:appID];
            
            STAApp *newApp = [NSEntityDescription insertNewObjectForEntityForName:@"App" inManagedObjectContext:[self managedObjectContext]];
            
            [newApp setAppID:appID];
            [newApp setAppURLString:[appInfo objectForKey:@"AppURL"]];
            [newApp setPriceTier:[appInfo objectForKey:@"PriceTier"]];
            [newApp setScreenshotURLString:[appInfo objectForKey:@"AppScreenshotURLString"]];
                        
            NSMutableSet *categories = [NSMutableSet set];
            
            for (NSNumber *categoryCode in [appInfo objectForKey:@"Categories"])
            {
                STACategory *theCategory = [self categoryForCategoryCode:categoryCode];
                if (theCategory)
                    [categories addObject:theCategory];
            }
            [newApp setCategories:categories];
        }
        
        [[self managedObjectContext] save:nil];
    }
}

- (void)processImageDownloadData:(NSDictionary*)argImageDownloadData
{
    NSMutableData *connectionData = [argImageDownloadData objectForKey:STAConnectionDataKey];
    if (connectionData)
    {
        NSString *urlString = [argImageDownloadData objectForKey:STAConnectionURLStringKey];
        
        NSString *imageFilePath = [self filePathOfImageDataForURLString:urlString];
        
        if([[NSFileManager defaultManager] createFileAtPath:imageFilePath contents:connectionData attributes:nil])
            [[self galleryViewController] screenshotDownloadCompleted:urlString];
    }
}

- (void)processSearchJSONDownloadData:(NSDictionary*)argSearchJSONDownloadData
{
    NSNumber *searchCategory = [argSearchJSONDownloadData objectForKey:STAConnectionSearchCategoryKey];
    NSMutableData *connectionData = [argSearchJSONDownloadData objectForKey:STAConnectionDataKey];
    if (connectionData)
    {
        #ifdef LOG_DownloadActivity
            NSString *dataString = [[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding];
            NSLog(@"Search download completed with data: %@", dataString);
            [dataString release];
        #endif
        
        NSString *jsonString = [[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding];
        NSDictionary *appListDictionary = [jsonString JSONValue];
        [jsonString release];
        
        if (appListDictionary)
        {
            if ([[appListDictionary valueForKey:@"resultCount"] integerValue] > 0)
                [self processNewAppsInDictionary:appListDictionary];
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:STASearchNoResultsNotification object:nil userInfo:[NSDictionary dictionaryWithObject:searchCategory forKey:@"STASearchCategory"]];
            }
        }
        else
        {
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"InvalidJSONResponse" attributes:[NSDictionary dictionaryWithObject:[argSearchJSONDownloadData objectForKey:STAConnectionURLStringKey] forKey:@"URL"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:STASearchErrorNotification object:nil userInfo:[NSDictionary dictionaryWithObject:searchCategory forKey:@"STASearchCategory"]];
        }
    }
}

#pragma mark - NSXMLParser Delegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"id"])
    {
        if ([[attributeDict allKeys] containsObject:@"im:id"])
        {
            NSInteger appID = [[attributeDict objectForKey:@"im:id"] integerValue];
            [[self appIDsArray] addObject:[NSNumber numberWithInteger:appID]];
        }
    }
}

#pragma mark - Start Next Download Methods

- (void)startPendingXMLDownloads
{
    while ([[self pendingXMLDownloadURLStrings] count] > 0 && CFDictionaryGetCount([self currentXMLDownloadConnections]) <= 2)
    {
        #ifdef LOG_DownloadActivity
            NSLog(@"XML download starting");
        #endif
        
        NSString *connectionURLString = [[self pendingXMLDownloadURLStrings] objectAtIndex:0];
        NSMutableDictionary *connectionDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               connectionURLString, STAConnectionURLStringKey, 
                                               [NSMutableData data], STAConnectionDataKey, 
                                               nil];
        NSURL *xmlURL = [NSURL URLWithString:connectionURLString];
        NSURLRequest *xmlRequest = [NSURLRequest requestWithURL:xmlURL];
        NSURLConnection *xmlDownloadConnection = [NSURLConnection connectionWithRequest:xmlRequest delegate:self];
        CFDictionaryAddValue([self currentXMLDownloadConnections], xmlDownloadConnection, connectionDict);
        [[self pendingXMLDownloadURLStrings] removeObjectAtIndex:0];
    }
}

- (void)startPendingListJSONDownloads
{
    while ([[self pendingListJSONDownloadURLStrings] count] > 0 && CFDictionaryGetCount([self currentListJSONDownloadConnections]) <= 2)
    {
        #ifdef LOG_DownloadActivity
            NSLog(@"List JSON download starting");
        #endif
        
        NSString *connectionURLString = [[self pendingXMLDownloadURLStrings] objectAtIndex:0];
        NSMutableDictionary *connectionDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               connectionURLString, STAConnectionURLStringKey, 
                                               [NSMutableData data], STAConnectionDataKey, 
                                               nil];
        NSURL *listJSONURL = [NSURL URLWithString:connectionURLString];
        NSURLRequest *listJSONRequest = [NSURLRequest requestWithURL:listJSONURL];
        NSURLConnection *listJSONDownloadConnection = [NSURLConnection connectionWithRequest:listJSONRequest delegate:self];
        CFDictionaryAddValue([self currentListJSONDownloadConnections], listJSONDownloadConnection, connectionDict);
        [[self pendingListJSONDownloadURLStrings] removeObjectAtIndex:0];
    }
}

- (void)startPendingImageDownloads
{
    while ([[self pendingImageDownloadURLStrings] count] > 0 && CFDictionaryGetCount([self currentImageDownloadConnections]) <= 3)
    {
        #ifdef LOG_DownloadActivity
            NSLog(@"Image download starting");
        #endif
            
        NSString *connectionURLString = [[self pendingImageDownloadURLStrings] objectAtIndex:0];
        NSMutableDictionary *connectionDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                connectionURLString, STAConnectionURLStringKey, 
                                                [NSMutableData data], STAConnectionDataKey, 
                                                nil];
        NSURL *imageURL = [NSURL URLWithString:connectionURLString];
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:imageURL];
        NSURLConnection *imageDownloadConnection = [NSURLConnection connectionWithRequest:imageRequest delegate:self];
        CFDictionaryAddValue([self currentImageDownloadConnections], imageDownloadConnection, connectionDict);
        [[self pendingImageDownloadURLStrings] removeObjectAtIndex:0];
    }
}

#pragma mark - Network Activity Indicator Methods

- (void)updateNetworkActivityIndicator
{
    if (CFDictionaryGetCount([self currentListDownloadConnections]) > 0 || CFDictionaryGetCount([self currentImageDownloadConnections]) > 0 || CFDictionaryGetCount([self currentSearchDownloadConnection]) > 0)
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    else
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - State Data Update Methods

- (void)updateAppStoreCountry:(NSString*)argCountryCode
{    
    [[NSUserDefaults standardUserDefaults] setValue:argCountryCode forKey:STADefaultsAppStoreCountryKey];
    [[NSUserDefaults standardUserDefaults] setValue:argCountryCode forKey:STADefaultsLastAppStoreCountryKey];
    
    enum STACategory currentCategory = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastCategoryKey] integerValue];
    [[self galleryViewController] displayCategory:currentCategory forAppStoreCountryCode:argCountryCode];
                        
    NSInteger lastPosition = [self lastPositionForCategory:currentCategory];
    enum STAPriceTier lastPriceTier = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastListPriceTierKey] integerValue];
    if (currentCategory == STACategoryBrowse)
        lastPriceTier = STAPriceTierAll;
    [[self galleryViewController] displayPosition:lastPosition forPriceTier:lastPriceTier];
}

- (void)updateLastPosition:(NSInteger)argLastPosition
{    
    NSMutableDictionary *lastPositionsDictionary = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastPositionsDictionaryKey] mutableCopy];
    NSString *appStoreCountryCode = [[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsAppStoreCountryKey];
    NSInteger currentCategory = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastCategoryKey] integerValue];
    NSString *positionKey = [NSString stringWithFormat:@"%@%d", appStoreCountryCode, currentCategory];
    [lastPositionsDictionary setValue:[NSNumber numberWithInteger:argLastPosition] forKey:positionKey];
    [[NSUserDefaults standardUserDefaults] setValue:lastPositionsDictionary forKey:STADefaultsLastPositionsDictionaryKey];
    [lastPositionsDictionary release];
    
    #ifdef LOG_PositionSaves
        NSLog(@"Updating Last Position: %d For Key: %@", argLastPosition, positionKey);
    #endif
}

- (void)updateCategory:(enum STACategory)argCategory
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:argCategory] forKey:STADefaultsLastCategoryKey];
    if (argCategory >= 10000)
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:argCategory] forKey:STADefaultsLastSearchCategoryKey];
    
    NSString *currentCountry = [[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsAppStoreCountryKey];
    
    enum STAPriceTier lastPriceTier = STAPriceTierAll;
    
    if (argCategory == STACategorySearchResult || argCategory >= 10000)
    {
        [[self galleryViewController] displayMode:STADisplayModeSearch];
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastSearchPriceTierKey] integerValue] == STAPriceTierFree)
            lastPriceTier = STAPriceTierFree;
    }
    else if (argCategory == STACategoryBrowse)
    {
        [[self galleryViewController] displayMode:STADisplayModeBrowse];
    }
    else
    {
        [[self galleryViewController] displayMode:STADisplayModeList];
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastListPriceTierKey] integerValue] == STAPriceTierFree)
            lastPriceTier = STAPriceTierFree;
    }
    
    [[self galleryViewController] displayCategory:argCategory forAppStoreCountryCode:currentCountry];
    NSInteger lastPosition = [self lastPositionForCategory:argCategory];
    [[self galleryViewController] displayPosition:lastPosition forPriceTier:lastPriceTier];
}

- (void)updatePriceTier:(enum STAPriceTier)argPriceTier
{
    // hang on to old value
    
    // updatePriceTier
    
    // galleryView
        // free -> all
            // call specific update method
        // all -> free
            // call specific update method
}

#pragma mark - State Restoration

- (NSInteger)lastPositionForCategory:(NSInteger)argCategory
{   
    //NSLog(@"Asking for last position for category: %d", argCategory);
    
    NSString *currentCountry = [[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsAppStoreCountryKey];
    
    NSDictionary *lastPositionsDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastPositionsDictionaryKey];
    
    NSString *lastPositionKey = [NSString stringWithFormat:@"%@%d", currentCountry, argCategory];
    
    if ([[lastPositionsDictionary allKeys] containsObject:lastPositionKey] == NO)
        return 0;
    
    NSInteger lastPosition = [[lastPositionsDictionary valueForKey:lastPositionKey] integerValue];
    return lastPosition;
}

#pragma mark - Import New Apps

- (void)processNewAppsInDictionary:(NSDictionary*)argDictionary
{
    NSString *country = [argDictionary valueForKey:@"country"];
    NSInteger category = [[argDictionary valueForKey:@"cat"] integerValue];
    
    NSInteger nextPositionIndex = 0;
    
    if (category < 10000 && [[argDictionary allKeys] containsObject:@"searchterm"] == NO)
    {
        NSFetchRequest *displayIndexFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DisplayIndex"];
        NSPredicate *categoryAndCountryPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"category == %d AND country == '%@'", category, country]];
        [displayIndexFetchRequest setPredicate:categoryAndCountryPredicate];
        NSSortDescriptor *positionIndexSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"positionIndex" ascending:NO];
        [displayIndexFetchRequest setSortDescriptors:[NSArray arrayWithObject:positionIndexSortDescriptor]];
        NSArray *displayIndicies = [[self managedObjectContext] executeFetchRequest:displayIndexFetchRequest error:nil];
        if ([displayIndicies count] > 0)
            nextPositionIndex = [[[displayIndicies objectAtIndex:0] valueForKey:STADisplayIndexAttributePositionIndex] integerValue] + 1;
        [displayIndexFetchRequest release];
    }
        
    NSArray *apps = [argDictionary objectForKey:@"results"];
        
    for (NSDictionary *appDict in apps)
    {
        NSInteger priceTier = [[appDict valueForKey:@"PriceTier"] integerValue];
        NSInteger appID = [[appDict valueForKey:@"AppID"] integerValue];
        NSString *appURL = [appDict valueForKey:@"AppURL"];
        NSString *screenshotURL = [appDict valueForKey:@"ScreenshotURL"];
            
        NSManagedObject *newDisplayIndex = [NSEntityDescription insertNewObjectForEntityForName:@"DisplayIndex" inManagedObjectContext:[self managedObjectContext]];
        [newDisplayIndex setValue:[NSNumber numberWithInteger:category] forKey:STADisplayIndexAttributeCategory];
        [newDisplayIndex setValue:[NSNumber numberWithInteger:priceTier] forKey:STADisplayIndexAttributePriceTier];
        [newDisplayIndex setValue:[NSNumber numberWithInteger:nextPositionIndex] forKey:STADisplayIndexAttributePositionIndex];
        [newDisplayIndex setValue:country forKey:STADisplayIndexAttributeCountry];
        [newDisplayIndex setValue:[NSNumber numberWithInteger:appID] forKey:STADisplayIndexAttributeAppID];
        [newDisplayIndex setValue:appURL forKey:STADisplayIndexAttributeAppURL];
        [newDisplayIndex setValue:screenshotURL forKey:STADisplayIndexAttributeScreenshotURL];
        
        nextPositionIndex++;            
    }   
    [self saveContext];
}

#pragma mark - UINavigationController Delegate Methods

- (void)navigationController:(UINavigationController*)argNavigationController willShowViewController:(UIViewController*)argViewController animated:(BOOL)argAnimated
{
    if ([argViewController isEqual:galleryViewController_gv])
    {
        [[[self galleryViewController] view] setClipsToBounds:YES];
                
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastModeKey] integerValue] == STADisplayModeList)
        {            
            enum STACategory currentCategory = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastCategoryKey] integerValue];
            
            if (currentCategory >= STACategoryGamesAction || currentCategory == STACategoryGames)
            {
                
                NSUInteger indexOfCategory = [[self gameCategoriesInfo] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
                    
                    if([[(NSDictionary*)obj valueForKey:@"CategoryCode"] integerValue] == currentCategory)
                        return YES;
                    return NO;
                }];
                
                if (indexOfCategory == NSNotFound)
                    NSLog(@"Category Not Found");
                else
                {
                    NSString *categoryName = [[[self gameCategoriesInfo] objectAtIndex:indexOfCategory] valueForKey:@"CategoryName"];
                    [[self galleryViewController] setTitle:categoryName];
                }
            }
            else
            {
                NSUInteger indexOfCategory = [[self categoriesInfo] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
                    
                    if([[(NSDictionary*)obj valueForKey:@"CategoryCode"] integerValue] == currentCategory)
                        return YES;
                    return NO;
                }];
                
                if (indexOfCategory == NSNotFound)
                    NSLog(@"Category Not Found");
                else
                {
                    NSString *categoryName = [[[self categoriesInfo] objectAtIndex:indexOfCategory] valueForKey:@"CategoryName"];
                    //[[[self galleryViewController] navigationItem] setTitle:categoryName];
                    [[self galleryViewController] setTitle:categoryName];
                }
            }
        }
        else if ([[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastModeKey] integerValue] == STADisplayModeSearch)
        {
            [[self galleryViewController] setTitle:@""];
        }
        else
            [[self galleryViewController] setTitle:NSLocalizedString(@"All Apps", @"All Apps")];
        
        return;
    }
    
    if (([argViewController isEqual:categoriesMenuViewController_gv] || [argViewController isEqual:gamesSubcategoriesMenuViewController_gv]) && [[argNavigationController visibleViewController] isEqual:galleryViewController_gv])
        [self updateLastPosition:[[self galleryViewController] positionOfCurrentRow]];
}

- (void)navigationController:(UINavigationController*)argNavigationController didShowViewController:(UIViewController*)argViewController animated:(BOOL)argAnimated
{
    if ([argViewController isEqual:galleryViewController_gv])
    {
        [[[self galleryViewController] view] setClipsToBounds:NO];
        return;
    }
    
    if ([argViewController isEqual:mainMenuViewController_gv])
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STADisplayModeMainMenu] forKey:STADefaultsLastModeKey];
        return;
    }
    
    if ([argViewController isEqual:categoriesMenuViewController_gv])
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STADisplayModeCategoriesMenu] forKey:STADefaultsLastModeKey];
        return;
    }
    
    if ([argViewController isEqual:gamesSubcategoriesMenuViewController_gv])
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STADisplayModeGameCategoriesMenu] forKey:STADefaultsLastModeKey];
        return;
    }
    
    if ([argViewController isEqual:optionsViewController_gv])
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STADisplayModeOptionsMenu] forKey:STADefaultsLastModeKey];
        return;
    }
}

#pragma mark - STAMainMenu Delegate Methods

- (void)mainMenuRowSelected:(NSInteger)argRow
{
    // Tell navigation controller to transition to appropriate view controller
    //NSLog(@"Acting on menu selection");

    switch (argRow) 
    {
        case 0: // Browse All Apps
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STADisplayModeBrowse] forKey:STADefaultsLastModeKey];
            [[self galleryViewController] view];
            [self updateCategory:STACategoryBrowse];
            [[self navigationController] pushViewController:[self galleryViewController] animated:YES];
            break;
        }
        case 1: // Categories
        {
            [[self navigationController] pushViewController:[self categoriesMenuViewController] animated:YES];
            break;
        }
        case 2: // Search
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STADisplayModeSearch] forKey:STADefaultsLastModeKey];         
            [[self galleryViewController] view];
            
            NSInteger lastSearchCategory = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastSearchCategoryKey] integerValue];
            if (lastSearchCategory == 0)
                [self updateCategory:STACategorySearchResult];
            else
                [self updateCategory:lastSearchCategory];
            
            [[self navigationController] pushViewController:[self galleryViewController] animated:YES];
            break;
        }
        case 3: // Options
        {
            [[self navigationController] pushViewController:[self optionsViewController] animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - STACategoriesMenu Delegate Methods

- (void)categoriesMenuCategorySelected:(NSInteger)argCategory
{
    if (argCategory == STACategoryGames)
        [[self navigationController] pushViewController:[self gamesSubcategoriesMenuViewController] animated:YES];
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STADisplayModeList] forKey:STADefaultsLastModeKey];
        [[self galleryViewController] view];
        [self updateCategory:argCategory];        
        [[self navigationController] pushViewController:[self galleryViewController] animated:YES];
    }
}

#pragma mark - STAGamesSubcategories Delegate Methods

- (void)gamesSubcategoriesMenuCategorySelected:(NSInteger)argCategory
{    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STADisplayModeList] forKey:STADefaultsLastModeKey];
    [[self galleryViewController] view];
    [self updateCategory:argCategory];
    [[self navigationController] pushViewController:[self galleryViewController] animated:YES];
}

#pragma mark - Manage Images on Disk

- (void)cleanScreenshotDiskCache
{
    NSError *error = nil;
    NSArray *screenshots = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL URLWithString:[self pathForImageDataDirectory]] includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLContentAccessDateKey, NSURLIsRegularFileKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    
    if ([screenshots count] > kGVNumberOfScreenshotsToKeepOnDisk)
    {
        NSSortDescriptor *contentAccessDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSURLContentAccessDateKey ascending:YES];
        NSArray *sortedScreenshotsArray = [screenshots sortedArrayUsingDescriptors:[NSArray arrayWithObject:contentAccessDateSortDescriptor]];
        
        NSInteger numberOfScreenshotsToRemove = [screenshots count] - kGVNumberOfScreenshotsToKeepOnDisk;
        
        for (int screenshotIndex = 0; screenshotIndex < numberOfScreenshotsToRemove; screenshotIndex++)
        {
            NSURL *urlToRemove = [sortedScreenshotsArray objectAtIndex:screenshotIndex];
            if ([[urlToRemove valueForKey:NSURLIsRegularFileKey] boolValue] == YES)
                [[NSFileManager defaultManager] removeItemAtURL:[sortedScreenshotsArray objectAtIndex:screenshotIndex] error:nil];
        }
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        [__managedObjectContext setUndoManager:nil];
    }
    return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SeeTheApp" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
 
    NSURL *storeURL;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        storeURL = [[self applicationLibrarySTADirectory] URLByAppendingPathComponent:@"SeeTheAppPhone.sqlite"];
    else
        storeURL = [[self applicationLibrarySTADirectory] URLByAppendingPathComponent:@"SeeTheAppPad.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Error-PersistentStoreAddFail"];
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - File Paths

- (NSURL*)applicationLibrarySTADirectory
{
    if (applicationLibrarySTADirectory_gv)
        return applicationLibrarySTADirectory_gv;
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [searchPaths objectAtIndex:0];
    NSString *librarySTAPath = [libraryPath stringByAppendingPathComponent:@"SeeTheApp"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:librarySTAPath withIntermediateDirectories:NO attributes:nil error:nil];

    applicationLibrarySTADirectory_gv = [[NSURL alloc] initFileURLWithPath:librarySTAPath];
    return applicationLibrarySTADirectory_gv;
}

- (NSString*)pathForImageDataDirectory
{
    if (pathForImageDataDirectory_gv)
        return pathForImageDataDirectory_gv;
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesPath = [searchPaths objectAtIndex:0];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:[cachesPath stringByAppendingPathComponent:@"STAScreenshotImageData"] withIntermediateDirectories:NO attributes:nil error:nil];
    
    pathForImageDataDirectory_gv = [[cachesPath stringByAppendingPathComponent:@"STAScreenshotImageData"] retain];
    
    return pathForImageDataDirectory_gv;
}

- (NSString*)fileNameOfImageWithURLString:(NSString*)argURLString
{
    NSString *slashlessURLString = [argURLString stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    NSString *escapedURLString = [slashlessURLString stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    return escapedURLString;
}

- (NSString*)filePathOfImageDataForURLString:(NSString*)argURLString
{
    if (!argURLString)
    {
        NSLog(@"Passing nil to filePathOfImageData");
        return nil;
    }
    
    NSString *escapedURLString = [self fileNameOfImageWithURLString:argURLString];
        
    return [[self pathForImageDataDirectory] stringByAppendingPathComponent:escapedURLString];
}

#pragma mark - Connection Collections

- (CFMutableDictionaryRef)currentListDownloadConnections
{
    if (currentListDownloadConnections_gv)
        return currentListDownloadConnections_gv;
    currentListDownloadConnections_gv = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return currentListDownloadConnections_gv;
}

- (NSMutableArray*)pendingListDownloadURLStrings
{
    if (pendingListDownloadURLStrings_gv)
        return pendingListDownloadURLStrings_gv;
    pendingListDownloadURLStrings_gv = [[NSMutableArray alloc] init];
    return pendingListDownloadURLStrings_gv;
}

- (CFMutableDictionaryRef)currentSearchDownloadConnection
{
    if (currentSearchDownloadConnection_gv)
        return currentSearchDownloadConnection_gv;
    currentSearchDownloadConnection_gv = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return currentSearchDownloadConnection_gv;
}

- (CFMutableDictionaryRef)currentImageDownloadConnections
{
    if (currentImageDownloadConnections_gv)
        return currentImageDownloadConnections_gv;
    currentImageDownloadConnections_gv = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return currentImageDownloadConnections_gv;
}

- (NSMutableArray*)pendingImageDownloadURLStrings
{
    if (pendingImageDownloadURLStrings_gv)
        return pendingImageDownloadURLStrings_gv;
    pendingImageDownloadURLStrings_gv = [[NSMutableArray alloc] init];
    return pendingImageDownloadURLStrings_gv;
}

- (CFMutableDictionaryRef)currentXMLDownloadConnections
{
    if (currentXMLDownloadConnections_gv)
        return currentXMLDownloadConnections_gv;
    currentXMLDownloadConnections_gv = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return currentXMLDownloadConnections_gv;
}

- (NSMutableArray*)pendingXMLDownloadURLStrings
{
    if (pendingXMLDownloadURLStrings_gv)
        return pendingXMLDownloadURLStrings_gv;
    pendingXMLDownloadURLStrings_gv = [[NSMutableArray alloc] init];
    return pendingXMLDownloadURLStrings_gv;
}

- (CFMutableDictionaryRef)currentListJSONDownloadConnections
{
    if (currentListJSONDownloadConnections_gv)
        return currentListJSONDownloadConnections_gv;
    currentListJSONDownloadConnections_gv = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return currentListJSONDownloadConnections_gv;
}

- (NSMutableArray*)pendingListJSONDownloadURLStrings
{
    if (pendingListJSONDownloadURLStrings_gv)
        return pendingListJSONDownloadURLStrings_gv;
    pendingListJSONDownloadURLStrings_gv = [[NSMutableArray alloc] init];
    return pendingListJSONDownloadURLStrings_gv;
}

#pragma mark - Search Start Methods

- (void)startSearchResultsDownloadWithURLString:(NSString*)argSearchResultsDownloadURLString searchCategory:(NSInteger)argSearchCategory
{
    if (CFDictionaryGetCount([self currentSearchDownloadConnection]))
    {
        Size currentSearchDownloadsCount = CFDictionaryGetCount([self currentSearchDownloadConnection]);
        CFTypeRef *searchDownloadConnectionsArray = (CFTypeRef*)malloc(currentSearchDownloadsCount * sizeof(CFTypeRef));
        
        CFDictionaryGetKeysAndValues([self currentSearchDownloadConnection], (const void**)searchDownloadConnectionsArray, NULL);
        
        const void **searchDownloadConnections = (const void **)searchDownloadConnectionsArray;
        
        NSMutableArray *currentSearchConnections = [NSMutableArray array];
        
        for (int searchIndex = 0; searchIndex < currentSearchDownloadsCount; searchIndex++)
        {
            NSURLConnection *searchConnection = searchDownloadConnections[searchIndex];
            [currentSearchConnections addObject:searchConnection];
        }
        
        free(searchDownloadConnectionsArray);
        
        for (NSURLConnection *searchConnection in currentSearchConnections)
        {
            [searchConnection cancel];
            CFDictionaryRemoveValue([self currentSearchDownloadConnection], searchConnection);
        }        
    }
        
    NSURL *searchResultsURL = [NSURL URLWithString:argSearchResultsDownloadURLString];
    NSMutableURLRequest *searchResultsURLRequest = [[NSMutableURLRequest alloc] init];
    [searchResultsURLRequest setURL:searchResultsURL];
    [searchResultsURLRequest setValue:@"STAClient" forHTTPHeaderField:@"User-Agent"];
    
    NSMutableDictionary *searchConnectionDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                       argSearchResultsDownloadURLString, STAConnectionURLStringKey, 
                                                       [NSMutableData data], STAConnectionDataKey,
                                                       [NSNumber numberWithInteger:argSearchCategory], STAConnectionSearchCategoryKey,
                                                       nil];
    
    NSURLConnection *searchResultsURLConnection = [NSURLConnection connectionWithRequest:searchResultsURLRequest delegate:self];
    
    CFDictionaryAddValue([self currentSearchDownloadConnection], searchResultsURLConnection, searchConnectionDictionary);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];     
    
    [searchResultsURLRequest release];
}

#pragma mark - AppStore Country Codes

- (NSArray*)appStoreCountryCodes
{
    if (appStoreCountryCodes_gv)
        return appStoreCountryCodes_gv;
    appStoreCountryCodes_gv = [[NSArray alloc] initWithObjects:
                               @"DZ", @"AO", @"AI", @"AG", @"AR", @"AM", @"AU", @"AT", @"AZ", @"BS", @"BH", @"BB", @"BY", @"BE", @"BZ", @"BM", @"BO", @"BW",
                               @"BR", @"BN", @"BG", @"CA", @"KY", @"CL", @"CN", @"CO", @"CR", @"HR", @"CY", @"CZ", @"DK", @"DM", @"DO", @"EC", @"EG", @"SV",
                               @"EE", @"FI", @"FR", @"DE", @"GH", @"GR", @"GD", @"GT", @"GY", @"HN", @"HK", @"HU", @"IS", @"IN", @"ID", @"IE", @"IL", @"IT",
                               @"JM", @"JP", @"JO", @"KZ", @"KE", @"KR", @"KW", @"LV", @"LB", @"LT", @"LU", @"MO", @"MK", @"MG", @"MY", @"ML", @"MT", @"MU",
                               @"MX", @"MD", @"MS", @"NL", @"NZ", @"NI", @"NE", @"NG", @"NO", @"OM", @"PK", @"PA", @"PY", @"PE", @"PH", @"PL", @"PT", @"QA",
                               @"RO", @"RU", @"KN", @"LC", @"VC", @"SA", @"SN", @"SG", @"SK", @"SI", @"ZA", @"ES", @"LK", @"SR", @"SE", @"CH", @"TW", @"TZ",
                               @"TH", @"TT", @"TN", @"TR", @"TC", @"UG", @"AE", @"GB", @"US", @"UY", @"UZ", @"VE", @"VN", @"VG", @"YE",
                               nil];
    return appStoreCountryCodes_gv;
}

#pragma mark - Affiliate Codes Dictionary

- (NSDictionary*)affiliateCodesDictionary
{
    if (affiliateCodesDictionary_gv)
        return affiliateCodesDictionary_gv;
    affiliateCodesDictionary_gv = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   @"&partnerId=30&siteID=XcCW00SXEtY", @"US",
                                   @"&partnerId=30&siteID=XcCW00SXEtY", @"CA",
                                   @"&partnerId=30&siteID=XcCW00SXEtY", @"MX",
                                   @"&partnerId=1002&affToken=64309", @"AU",
                                   @"&partnerId=1002&affToken=64309", @"NZ",
                                   @"&partnerId=2003&tduid=AT2037976", @"AT",
                                   @"&partnerId=2003&tduid=BE2037978", @"BE",
                                   @"&partnerId=2003&tduid=CH2037979", @"CH",
                                   @"&partnerId=2003&tduid=DE2037980", @"DE",
                                   @"&partnerId=2003&tduid=DK2037982", @"DK",
                                   @"&partnerId=2003&tduid=ES2037985", @"ES",
                                   @"&partnerId=2003&tduid=FI2037987", @"FI",
                                   @"&partnerId=2003&tduid=FR2037988", @"FR",
                                   @"&partnerId=2003&tduid=IE2037989", @"IE",
                                   @"&partnerId=2003&tduid=IT2037991", @"IT",
                                   @"&partnerId=2003&tduid=LT2037999", @"LT",
                                   @"&partnerId=2003&tduid=NL2037993", @"NL",
                                   @"&partnerId=2003&tduid=NO2037995", @"NO",
                                   @"&partnerId=2003&tduid=PL2038001", @"PL",
                                   @"&partnerId=2003&tduid=PT2038002", @"PT",
                                   @"&partnerId=2003&tduid=SE2037997", @"SE",
                                   @"&partnerId=2003&tduid=UK2031437", @"GB",
                                   @"&partnerId=2003&tduid=BG2038003", @"BG",
                                   @"&partnerId=2003&tduid=CY2038003", @"CY",
                                   @"&partnerId=2003&tduid=CZ2038003", @"CZ",
                                   @"&partnerId=2003&tduid=EE2038003", @"EE",
                                   @"&partnerId=2003&tduid=GR2038003", @"GR",
                                   @"&partnerId=2003&tduid=HU2038003", @"HU",
                                   @"&partnerId=2003&tduid=LU2038003", @"LU",
                                   @"&partnerId=2003&tduid=LV2038003", @"LV",
                                   @"&partnerId=2003&tduid=MT2038003", @"MT",
                                   @"&partnerId=2003&tduid=RO2038003", @"RO",
                                   @"&partnerId=2003&tduid=SI2038003", @"SI",
                                   @"&partnerId=2003&tduid=SK2038003", @"SK",
                                   @"&partnerId=2003&tduid=BR2048953", @"BR",
                                   nil];
    return affiliateCodesDictionary_gv;
}

#pragma mark - XML Feed Types

- (NSArray*)XMLFeedTypes
{
    /*
    if (XMLFeedTypes_gv)
        return XMLFeedTypes_gv;
    XMLFeedTypes_gv = [[NSArray alloc] initWithObjects:
                       @"topfreeapplications",
                       @"toppaidapplications",
                       @"topgrossingapplications",
                       nil]
     */
    return nil;
}

#pragma mark - Category Info

- (STACategory*)categoryForCategoryCode:(NSNumber*)argCategoryCode
{
    if (!categories_gv)
    {
        NSFetchRequest *allCategoriesFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
        NSError *fetchError;
        NSArray *categories = [[self managedObjectContext] executeFetchRequest:allCategoriesFetchRequest error:&fetchError];
        
        if (!categories)
        {
            NSLog(@"Categories Fetch Error: %@", [fetchError localizedDescription]);
            return nil;
        }
        
        NSMutableDictionary *tempCategories = [[NSMutableDictionary alloc] init];
        
        for (STACategory *category in categories)
        {
            [tempCategories setObject:category forKey:[category categoryCode]];
        }
        
        categories_gv = tempCategories;
    }
  
    if ([[categories_gv allKeys] containsObject:argCategoryCode])
        return [categories_gv objectForKey:argCategoryCode];
    
    NSLog(@"Missing category code: %@", [argCategoryCode description]);
    return nil;
}

- (NSArray*)categoriesInfo
{
    if (categoriesInfo_gv)
        return categoriesInfo_gv;
    categoriesInfo_gv = [[NSArray alloc] initWithObjects:
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Books", @"Books"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryBook], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Business", @"Business"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryBusiness], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Education", @"Education"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryEducation], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Entertainment", @"Entertainment"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryEntertainment], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Finance", @"Finance"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryFinance], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Games", @"Games"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryGames], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Health & Fitness", @"Health & Fitness"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryHealthcareAndFitness], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Lifestyle", @"Lifestyle"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryLifestyle], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Medical", @"Medical"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryMedical], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Music", @"Music"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryMusic], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Navigation", @"Navigation"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryNavigation], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"News", @"News"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryNews], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Newsstand", @"Newsstand"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryNewsstand], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Photo & Video", @"Photo & Video"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryPhotography], @"CategoryCode",
                          nil],
                         
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Productivity", @"Productivity"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryProductivity], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Reference", @"Reference"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryReference], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Social Networking", @"Social Networking"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategorySocialNetworking], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Sports", @"Sports"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategorySports], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Travel", @"Travel"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryTravel], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Utilities", @"Utilities"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryUtilities], @"CategoryCode",
                          nil],
                         
                         [NSDictionary dictionaryWithObjectsAndKeys:
                          NSLocalizedString(@"Weather", @"Weather"), @"CategoryName",
                          [NSNumber numberWithInteger:STACategoryWeather], @"CategoryCode",
                          nil],
                         
                         nil];
    return categoriesInfo_gv;
}

- (NSArray*)gameCategoriesInfo
{
    if (gameCategoriesInfo_gv)
        return gameCategoriesInfo_gv;
    gameCategoriesInfo_gv = [[NSArray alloc] initWithObjects:
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"All Games", @"All Games"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGames], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Action", @"Action"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesAction], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Adventure", @"Adventure"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesAdventure], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Arcade", @"Arcade"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesArcade], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Board", @"Board"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesBoard], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Card", @"Card"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesCard], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Casino", @"Casino"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesCasino], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Dice", @"Dice"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesDice], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Educational", @"Educational"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesEducational], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Family", @"Family"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesFamily], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Kids", @"Kids"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesKids], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Music", @"Music"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesMusic], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Puzzle", @"Puzzle"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesPuzzle], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Racing", @"Racing"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesRacing], @"CategoryCode",
                              nil],
                             
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Role Playing", @"Role Playing"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesRolePlaying], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Simulation", @"Simulation"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesSimulation], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Sports", @"Sports"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesSports], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Strategy", @"Strategy"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesStrategy], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Trivia", @"Trivia"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesTrivia], @"CategoryCode",
                              nil],
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Word", @"Word"), @"CategoryName",
                              [NSNumber numberWithInteger:STACategoryGamesWord], @"CategoryCode",
                              nil],
                             
                             nil];
    return gameCategoriesInfo_gv;
}

#pragma mark - View Controllers

- (UINavigationController*)navigationController
{
    if (navigationController_gv)
        return navigationController_gv;
    navigationController_gv = [[UINavigationController alloc] initWithRootViewController:[self mainMenuViewController]];
    [navigationController_gv setDelegate:self];
    if ([[navigationController_gv navigationBar] respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [[navigationController_gv navigationBar] setBackgroundImage:[UIImage imageNamed:@"STANavigationBarHD.png"] forBarMetrics:UIBarMetricsDefault];
        else
            [[navigationController_gv navigationBar] setBackgroundImage:[UIImage imageNamed:@"STANavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [[navigationController_gv navigationBar] setTintColor:[UIColor colorWithRed:0.89f green:0.66f blue:0.34f alpha:1.0f]];
    [[[navigationController_gv view] layer] setCornerRadius:6.0f];
    [[[navigationController_gv view] layer] setMasksToBounds:YES];
    
    return navigationController_gv;
}

- (SeeTheAppGalleryViewController*)galleryViewController
{
    if (galleryViewController_gv)
        return galleryViewController_gv;
    galleryViewController_gv = [[SeeTheAppGalleryViewController alloc] initWithDelegate:self];
    return galleryViewController_gv;
}

- (SeeTheAppMainMenuViewController*)mainMenuViewController
{
    if (mainMenuViewController_gv)
        return mainMenuViewController_gv;
    mainMenuViewController_gv = [[SeeTheAppMainMenuViewController alloc] initWithDelegate:self];
    return mainMenuViewController_gv;
}

- (SeeTheAppCategoriesMenuViewController*)categoriesMenuViewController
{
    if (categoriesMenuViewController_gv)
        return categoriesMenuViewController_gv;
    categoriesMenuViewController_gv = [[SeeTheAppCategoriesMenuViewController alloc] initWithDelegate:self];
    return categoriesMenuViewController_gv;
}

- (SeeTheAppGamesSubcategoriesMenuViewController*)gamesSubcategoriesMenuViewController
{
    if (gamesSubcategoriesMenuViewController_gv)
        return gamesSubcategoriesMenuViewController_gv;
    gamesSubcategoriesMenuViewController_gv = [[SeeTheAppGamesSubcategoriesMenuViewController alloc] initWithDelegate:self];
    return gamesSubcategoriesMenuViewController_gv;
}

- (SeeTheAppOptionsViewController*)optionsViewController
{
    if (optionsViewController_gv)
        return optionsViewController_gv;
    optionsViewController_gv = [[SeeTheAppOptionsViewController alloc] initWithDelegate:self];
    return optionsViewController_gv;
}

#pragma mark - Property Synthesis

@synthesize appIDsArray;
@synthesize downloadStarterTimer;
@synthesize hasNetworkConnection;
@synthesize reachability;
@end
