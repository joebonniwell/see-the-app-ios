//
//  SeeTheAppAppDelegate.m
//  SeeTheApp
//
//  Created by goVertex on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SeeTheAppAppDelegate.h"

@implementation SeeTheAppAppDelegate

@synthesize window=_window;

@synthesize managedObjectContext=__managedObjectContext;

@synthesize managedObjectModel=__managedObjectModel;

@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

+ (void)initialize
{
    NSDictionary *defaultDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInteger:0],     STADefaultsLastDisplayedIndexKey,
                                        [NSNumber numberWithInteger:0],     STADefaultsHighestDisplayedIndexKey,
                                        [NSNumber numberWithInteger:8],     STADefaultsAverageSessionViewsKey,
                                        [NSNumber numberWithInteger:0],     STADefaultsSessionViewsKey,
                                        [NSNumber numberWithInteger:0],     STADefaultsSessionReviewsKey,
                                        [NSNumber numberWithInteger:120],   STADefaultsCacheSizeKey,
                                        [NSNumber numberWithBool:YES],      STADefaultsCanAskToRateKey,
                                        [NSNumber numberWithInteger:0],     STADefaultsNumberOfOpensKey,
                                        [NSDate distantPast],               STADefaultsOpenValidationDateKey,
                                        [NSNumber numberWithBool:NO],       STADefaultsDatabaseHasCopiedKey,
                                        nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultDefaults];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // View Controller
    SeeTheAppViewController *tempViewController = [[SeeTheAppViewController alloc] initWithDelegate:self];
    [self setViewController:tempViewController];
    [tempViewController release];
    
    [[self window] addSubview:[[self viewController] view]];
    
    [self.window makeKeyAndVisible];
            
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
    
    // Screenshots Directory
    if ([[self fileManager] fileExistsAtPath:[self pathForScreenshotsDirectory]] == NO)
    {
        NSString *screenshotsDirectoryPath = [self pathForScreenshotsDirectory];
        [[self fileManager] createDirectoryAtPath:screenshotsDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
        
    // Database
    if ([self databaseExists] == YES)
        [self startSessionAndDownloads];
        
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    #ifdef LOG_ApplicationLifecycle
        NSLog(@"WILL ENTER FOREGROUND **************************************");
    #endif
    
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[self reachability] startNotifier];
    
    NetworkStatus status = [[self reachability] currentReachabilityStatus];
    if (status == ReachableViaWiFi || status == ReachableViaWWAN)
        [self setHasNetworkConnection:YES];
    else
        [self setHasNetworkConnection:NO];
    
    if ([self databaseExists] == YES)
        [self resumeSessionAndDownloads];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    #ifdef LOG_ApplicationLifecycle
        NSLog(@"DID ENTER BACKGROUND *************************************");
    #endif
    
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    [[self operationQueue] cancelAllOperations];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[self reachability] stopNotifier];
    
    [self stopTimer];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    #ifdef LOG_ApplicationLifecycle
        NSLog(@"WILL TERMINATE **************************************");
    #endif
    
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[self reachability] stopNotifier];
    
    [[self operationQueue] cancelAllOperations];
    
    [self stopTimer];
}

- (void)dealloc
{
    [fileManager_gv release];
    [pathForScreenshotsDirectory_gv release];
    [operationQueue_gv release];
    [self setViewController:nil];
    
    [self setReachability:nil];
    
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

- (void)saveContext
{
    //NSLog(@"Saving Context");
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Session Management

- (void)startSessionAndDownloads
{
#ifdef LOG_SessionNotifications
    NSLog(@"Session Starting");
#endif
    
    // Session Views    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:STADefaultsSessionViewsKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:STADefaultsSessionReviewsKey];
    
    // Session Start Time
    
    // Session End Time
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Start a session -> report the previous session
    
    NSInteger lastDisplayedRow = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastDisplayedIndexKey] integerValue];
    
    if (lastDisplayedRow > 0)
        [[[self viewController] galleryView] setContentOffset:CGPointMake(lastDisplayedRow * [[[self viewController] galleryView] frame].size.width, 0.0f)];
        
    if ([self shouldPresentRateAlert])
        [self presentRateAndFeedbackAlert];
    
    NSInteger highestDisplayIndex = [[[[[[self viewController] resultsController] fetchedObjects] lastObject] valueForKey:@"displayIndex"] integerValue];
    [self cleanCacheWithHighestDisplayIndex:highestDisplayIndex];
    
    [self updateUnorderedAppsArray];
        
    #ifdef LOG_OperationAdds
        NSLog(@"Adding Operation from Start Sessions, existing ops: %d", [[self operationQueue] operationCount]);
    #endif
    
    if ([[self operationQueue] operationCount] == 0)
    {
        SeeTheAppEvaluateOperation *newEvalOp = [[SeeTheAppEvaluateOperation alloc] initWithCurrentRow:[[[self viewController] galleryView] currentRow] delegate:self];
        [[self operationQueue] addOperation:newEvalOp];
        [newEvalOp release];
    }
    
    [self startTimer];
    
    #ifdef LOG_SessionNotifications
        NSLog(@"Session Started");
    #endif
}

- (void)resumeSessionAndDownloads
{
#ifdef LOG_SessionNotifications
    NSLog(@"Session resuming - operation count: %d", [[self operationQueue] operationCount]);
#endif
    
    NSInteger lastDisplayedRow = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastDisplayedIndexKey] integerValue];
    
    if (lastDisplayedRow > 0)
        [[[self viewController] galleryView] setContentOffset:CGPointMake(lastDisplayedRow * [[[self viewController] galleryView] frame].size.width, 0.0f)];
    
    if ([self shouldPresentRateAlert])
        [self presentRateAndFeedbackAlert];
    
    if ([[self unorderedAppsArray] count] == 0)
        [self updateUnorderedAppsArray];
    
    if ([[self operationQueue] operationCount] == 0)
    {
        #ifdef LOG_OperationAdds
            NSLog(@"Adding Operation from resume Sessions, existing ops: %d", [[self operationQueue] operationCount]);
        #endif
        
        SeeTheAppEvaluateOperation *newEvalOp = [[SeeTheAppEvaluateOperation alloc] initWithCurrentRow:[[[self viewController] galleryView] currentRow] delegate:self];
        [[self operationQueue] addOperation:newEvalOp];
        [newEvalOp release]; 
    }
    
    [self startTimer];
}

#pragma mark - Rate Dialog

- (BOOL)shouldPresentRateAlert
{
    BOOL canAskToRate = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsCanAskToRateKey] boolValue];
    if (canAskToRate == YES)
    {
        NSDate *validationDate = [[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsOpenValidationDateKey];
        NSDate *currentDate = [NSDate date];
        if ([currentDate timeIntervalSinceDate:validationDate] > 0)
        {
            NSInteger numberOfOpens = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsNumberOfOpensKey] integerValue];
            numberOfOpens++;
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:numberOfOpens] forKey:STADefaultsNumberOfOpensKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (numberOfOpens >= 5)
                return YES;
        }
    }
    return NO;
}

- (void)presentRateAndFeedbackAlert
{
    if ([MFMailComposeViewController canSendMail] == YES)
    {
        UIAlertView *rateAndFeedbackAlertView = [[UIAlertView alloc] initWithTitle:@"Enjoying See the App?" message:@"Please consider rating it in the AppStore, or contacting us if there is something we can improve." delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Rate See the App", @"Contact the Developer", @"Maybe Later", nil];
        [rateAndFeedbackAlertView setTag:4];
        [rateAndFeedbackAlertView show];
        [rateAndFeedbackAlertView release];
    }
    else
    {
        UIAlertView *rateAlertView = [[UIAlertView alloc] initWithTitle:@"Enjoying See the App?" message:@"Please consider rating it in the AppStore, or contacting us at contact@xyzapps.com if there is something we can improve." delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Rate See the App", @"Maybe Later", nil];
        [rateAlertView setTag:5];
        [rateAlertView show];
        [rateAlertView release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex])
    {
        #ifdef LOG_AlertViewResponse
            NSLog(@"AlertView: No Thanks");
        #endif
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:STADefaultsCanAskToRateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (buttonIndex == 1)
    {
        #ifdef LOG_AlertViewResponse
            NSLog(@"AlertView: Rate App");
        #endif
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:STADefaultsCanAskToRateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // Open Rate URL
        NSURL *rateURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=470079430&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8"]];
        [[UIApplication sharedApplication] openURL:rateURL];
    }
    else if (buttonIndex == 2)
    {
        if ([alertView tag] == 4)
        {
            #ifdef LOG_AlertViewResponse
                NSLog(@"AlertView: Email Developer");
            #endif
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:STADefaultsCanAskToRateKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // Launch Email View Controller
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            [mailViewController setMailComposeDelegate:self];
            [mailViewController setToRecipients:[NSArray arrayWithObject:[NSString stringWithFormat:@"contact@xyzapps.com"]]];
            [mailViewController setSubject:[NSString stringWithFormat:@"See the App"]];
            [[self viewController] presentModalViewController:mailViewController animated:YES];
            [mailViewController release];
        }
        else
        {
            #ifdef LOG_AlertViewResponse
                NSLog(@"AlertView: Maybe Later");
            #endif
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:0] forKey:STADefaultsNumberOfOpensKey];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate dateWithTimeIntervalSinceNow:259200] forKey:STADefaultsOpenValidationDateKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else if (buttonIndex == 3)
    {
        #ifdef LOG_AlertViewResponse
            NSLog(@"AlertView: Don't Show Again");
        #endif
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:0] forKey:STADefaultsNumberOfOpensKey];
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate dateWithTimeIntervalSinceNow:259200] forKey:STADefaultsOpenValidationDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Timed Evaluation

- (void)startTimer
{
    NSTimer *evalTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timedEvaluation) userInfo:nil repeats:YES];
    [self setEvaluationTimer:evalTimer];
}

- (void)stopTimer
{
    [[self evaluationTimer] invalidate];
    [self setEvaluationTimer:nil];
}

- (void)timedEvaluation
{
    if ([[self operationQueue] operationCount] == 0)
    {
        SeeTheAppEvaluateOperation *newEvalOp = [[SeeTheAppEvaluateOperation alloc] initWithCurrentRow:[[[self viewController] galleryView] currentRow] delegate:self];
        [[self operationQueue] addOperation:newEvalOp];
        [newEvalOp release];
    }
}

#pragma mark - Reachability

- (void)reachabilityChanged:(NSNotification*)reachabilityNotification
{
    BOOL databaseHasCopied = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsDatabaseHasCopiedKey] boolValue];
    NetworkStatus status = [[self reachability] currentReachabilityStatus];
    if (status == ReachableViaWiFi || status == ReachableViaWWAN)
    {
        #ifdef LOG_ReachabilityChangeNotifications
            NSLog(@"Reachability changed to reachable");
        #endif
        BOOL previousHasNetworkConnectionValue = [self hasNetworkConnection];
        [self setHasNetworkConnection:YES];
        if (previousHasNetworkConnectionValue == NO && databaseHasCopied == YES)
            [[[self viewController] galleryView] reloadData];
    }
    else
    {
        #ifdef LOG_ReachabilityChangeNotifications
            NSLog(@"Reachability changed to unreachable");
        #endif
        BOOL previousHasNetworkConnectionValue = [self hasNetworkConnection];
        [self setHasNetworkConnection:NO];
        if (previousHasNetworkConnectionValue == YES && databaseHasCopied == YES)
            [[[self viewController] galleryView] reloadData];
    }
}
#pragma mark - MailComposeViewController Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [[self viewController] dismissModalViewControllerAnimated:YES];
    [[[self viewController] view] setCenter:CGPointMake(0.5f * [[[self viewController] view] frame].size.width, 0.5f * [[[self viewController] view] frame].size.height)];
}

#pragma mark - ViewController Delegate Methods

- (void)rowChanged
{
    if ([[self operationQueue] operationCount] == 0)
    {
        SeeTheAppEvaluateOperation *newEvalOp = [[SeeTheAppEvaluateOperation alloc] initWithCurrentRow:[[[self viewController] galleryView] currentRow] delegate:self];
        [[self operationQueue] addOperation:newEvalOp];
        [newEvalOp release];
    }
    
    NSInteger newCurrentRow = [self currentRow];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:newCurrentRow] forKey:STADefaultsLastDisplayedIndexKey];
    
    if (newCurrentRow > [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsHighestDisplayedIndexKey] integerValue])
    {
        // Count as a new view for this session
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:newCurrentRow] forKey:STADefaultsHighestDisplayedIndexKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Should do actual view tracking here
}

#pragma mark - Download Delegate Methods

- (NSInteger)currentRow
{
    return [[[self viewController] galleryView] currentRow];
}

- (void)imageDownloadedForApp:(NSDictionary*)appInfo
{
#ifdef LOG_DownloadNotifications
    //NSLog(@"Finished Downloading AppID: %d", [[appInfo valueForKey:STAAppInfoAppID] integerValue]);
    NSLog(@"Downloaded App for DisplayIndex: %d", [[appInfo valueForKey:STAAppInfoDisplayIndex] integerValue]);
#endif
    
    NSManagedObject *app = [[self managedObjectContext] objectWithID:[appInfo objectForKey:STAAppInfoObjectID]];
    [app setValue:[appInfo objectForKey:STAAppInfoAppURL] forKey:STAAppPropertyAppURL];
    [app setValue:[appInfo objectForKey:STAAppInfoImagePath] forKey:STAAppPropertyImagePath];
    [app setValue:[appInfo objectForKey:STAAppInfoDisplayIndex] forKey:STAAppPropertyDisplayIndex];
    
    [[self managedObjectContext] save:NULL];
    
    // If this app is one of the visible cells in the gallery view, reload
    NSInteger rowOfDownloadedApp = [[appInfo objectForKey:STAAppInfoDisplayIndex] integerValue] + 1;
    if (rowOfDownloadedApp >= [self currentRow] - 1 && rowOfDownloadedApp <= [self currentRow] + 1)
        [[[self viewController] galleryView] reloadData];
    
    if ([[self operationQueue] operationCount] == 1)
    {
        SeeTheAppEvaluateOperation *newEvalOp = [[SeeTheAppEvaluateOperation alloc] initWithCurrentRow:[[[self viewController] galleryView] currentRow] delegate:self];
        [[self operationQueue] addOperation:newEvalOp];
        [newEvalOp release];
    }
}

- (void)downloadFailed
{
#ifdef LOG_DownloadNotifications
    NSLog(@"Download Failed");
#endif
    
    if ([[self operationQueue] operationCount] == 1)
    {
        SeeTheAppEvaluateOperation *newEvalOp = [[SeeTheAppEvaluateOperation alloc] initWithCurrentRow:[[[self viewController] galleryView] currentRow] delegate:self];
        [[self operationQueue] addOperation:newEvalOp];
        [newEvalOp release];
    }
}

- (void)evaluateOperationFinishedWithRowAndIndex:(NSDictionary*)argEvaluationResult
{
#ifdef LOG_EvaluationNotifications
    NSLog(@"Evaluation Finished");
#endif
    
    NSInteger evaluatedRow = [[argEvaluationResult objectForKey:@"Row"] integerValue];
    BOOL canTrimCache = [[argEvaluationResult objectForKey:@"CanTrimCache"] boolValue];
    
    if (evaluatedRow != [[[self viewController] galleryView] currentRow])
    {
        if ([[self operationQueue] operationCount] == 1)
        {
           SeeTheAppEvaluateOperation *newEvalOp = [[SeeTheAppEvaluateOperation alloc] initWithCurrentRow:[[[self viewController] galleryView] currentRow] delegate:self];
            [[self operationQueue] addOperation:newEvalOp];
            [newEvalOp release]; 
        }
    }
    else
    {
        NSInteger indexToDownload = [[argEvaluationResult objectForKey:@"Index"] integerValue];
        
        NSInteger highestDisplayIndex = 0;
        if ([[[[self viewController] resultsController] fetchedObjects] count] > 0)   
            highestDisplayIndex = [[[[[[self viewController] resultsController] fetchedObjects] lastObject] valueForKey:@"displayIndex"] integerValue];
        
        if (indexToDownload > highestDisplayIndex || highestDisplayIndex == 0)
        {            
            // Get a random App
            NSInteger randomAppIndex = arc4random() % [[self unorderedAppsArray] count];
                        
            NSManagedObject *app = [[self unorderedAppsArray] objectAtIndex:randomAppIndex];
            
            if ([self hasNetworkConnection] && [[self operationQueue] operationCount] == 1)
            {
                SeeTheAppDownloadOperation *newDLOp = [[SeeTheAppDownloadOperation alloc] initWithAppID:[[app valueForKey:@"appID"] integerValue] appObjectID:[app objectID] delegate:self displayIndex:(highestDisplayIndex + 1) canTrimCache:canTrimCache];
                [[self operationQueue] addOperation:newDLOp];
                [newDLOp release];
                
                [[self unorderedAppsArray] removeObjectAtIndex:randomAppIndex];
            }
        }
        else if (indexToDownload >= 0)
        {            
            //NSLog(@"Evaluation caused redownload for displayIndex: %d", indexToDownload);
            
            NSManagedObject *app = [[[[self viewController] resultsController] fetchedObjects] objectAtIndex:indexToDownload];
            
            if ([self hasNetworkConnection] && [[self operationQueue] operationCount] == 1)
            {
                SeeTheAppDownloadOperation *newDLOp = [[SeeTheAppDownloadOperation alloc] initWithAppID:[[app valueForKey:@"appID"] integerValue] appObjectID:[app objectID] delegate:self displayIndex:indexToDownload canTrimCache:canTrimCache];
                [[self operationQueue] addOperation:newDLOp];
                [newDLOp release];
            }
        }
    }
}

#pragma mark - Data Methods

- (void)updateUnorderedAppsArray
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSEntityDescription *appEntity = [NSEntityDescription entityForName:@"App" inManagedObjectContext:[self managedObjectContext]];
    
    NSPredicate *negativeDisplayIndexPredicate;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        negativeDisplayIndexPredicate = [NSPredicate predicateWithFormat:@"(iPadOnlyApp == YES OR universalApp == YES) AND displayIndex == -1"];
    else
        negativeDisplayIndexPredicate = [NSPredicate predicateWithFormat:@"iPadOnlyApp == NO AND displayIndex == -1"];
     
    NSFetchRequest *allUnorderedAppsFetchRequest = [[NSFetchRequest alloc] init];
    [allUnorderedAppsFetchRequest setEntity:appEntity];
    [allUnorderedAppsFetchRequest setPredicate:negativeDisplayIndexPredicate];
    //[allUnorderedAppsFetchRequest setIncludesPropertyValues:NO];
    
    NSArray *unorderedApps = [[self managedObjectContext] executeFetchRequest:allUnorderedAppsFetchRequest error:nil];
    [allUnorderedAppsFetchRequest release];
        
    NSMutableArray *unorderedAppsCopy = [unorderedApps mutableCopy];
    [self setUnorderedAppsArray:unorderedAppsCopy];
    [unorderedAppsCopy release];
    
    [pool drain];
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
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

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
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
    
    NSURL *storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"SeeTheApp.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        
        // Potentially set the database migrated key to NO, so that next launch it re-creates the database
        
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - File Methods

- (void)cleanCacheWithHighestDisplayIndex:(NSInteger)argHighestDisplayIndex
{   
    NSArray *screenshotFileNames = [[self fileManager] contentsOfDirectoryAtPath:[self pathForScreenshotsDirectory] error:NULL];
    
    for (NSString *fileName in screenshotFileNames)
    {
        NSInteger fileDisplayIndex = [[fileName stringByDeletingPathExtension] integerValue];
        if (fileDisplayIndex > argHighestDisplayIndex)
            [[self fileManager] removeItemAtPath:[[self pathForScreenshotsDirectory] stringByAppendingPathComponent:fileName] error:NULL];
    }
}

- (BOOL)databaseExists
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [searchPaths objectAtIndex:0];
    NSString *databaseFilePath = [libraryDirectory stringByAppendingPathComponent:@"SeeTheApp.sqlite"];
    
    BOOL databaseExists = [[self fileManager] fileExistsAtPath:databaseFilePath];
    if (databaseExists == NO)
    {           
        //NSLog(@"Database does not exist");
        NSBlockOperation *databaseMigrationOp = [self databaseMigrationBlockOperation];
        [[self operationQueue] addOperation:databaseMigrationOp];
        return NO;
    }
    else if (databaseExists == YES && [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsDatabaseHasCopiedKey] boolValue] == NO)
    {
        //NSLog(@"Database exists and we are going to recopy");
        //NSLog(@"Redoing Database");
        // Redo the database copy
        [[self fileManager] removeItemAtPath:databaseFilePath error:nil];
        
        NSBlockOperation *databaseMigrationOp = [self databaseMigrationBlockOperation];
        [[self operationQueue] addOperation:databaseMigrationOp];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (NSBlockOperation*)databaseMigrationBlockOperation
{
    NSBlockOperation *databaseMigrationOp = [NSBlockOperation blockOperationWithBlock:
                                             ^{
                                                 //NSLog(@"Start db copy");
                                                 
                                                 NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                                                 
                                                 NSFileManager *opFileManager = [[NSFileManager alloc] init];
                                                 
                                                 NSURL *starterDatabaseURL = [[NSBundle mainBundle] URLForResource:@"SeeTheApp" withExtension:@"sqlite"];
                                                 
                                                 NSURL *libraryDirectory = [[opFileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
                                                 
                                                 NSURL *destinationPathForDatabaseURL = [libraryDirectory URLByAppendingPathComponent:@"SeeTheApp.sqlite"];
                                                 
                                                 NSError *fileCopyError = nil;
                                                 
                                                 BOOL copySuccessful = [opFileManager copyItemAtURL:starterDatabaseURL toURL:destinationPathForDatabaseURL error:&fileCopyError];
                                                 
                                                 if (copySuccessful == NO)
                                                 {
                                                    #ifdef LOG_DatabaseCopyingNotifications
                                                     NSLog(@"Error copying database: %@", [fileCopyError description]);
                                                    #endif
                                                 }
                                                 else
                                                 {
                                                    #ifdef LOG_DatabaseCopyingNotifications
                                                     NSLog(@"Successfully copied database");
                                                    #endif
                                                 }
                                                 
                                                 [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:STADefaultsDatabaseHasCopiedKey];
                                                 
                                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                                 
                                                 [self performSelectorOnMainThread:@selector(startSessionAndDownloads) withObject:nil waitUntilDone:NO];
                                                 
                                                 [opFileManager release];
                                                 
                                                 [pool drain];
                                                 
                                                 //NSLog(@"End db copy");
                                             }];
    return databaseMigrationOp;
}

#pragma mark - File Paths

/**
 Returns the URL to the application's Documents directory.
 */
/*
- (NSURL *)applicationDocumentsDirectory
{
    return [[[self fileManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
*/
- (NSURL*)applicationLibraryDirectory
{
    return [[[self fileManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString*)pathForScreenshotsDirectory
{
    if (pathForScreenshotsDirectory_gv)
        return pathForScreenshotsDirectory_gv;
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [searchPaths objectAtIndex:0];
    pathForScreenshotsDirectory_gv = [[libraryPath stringByAppendingPathComponent:@"STAScreenshots"] retain];
    return pathForScreenshotsDirectory_gv;
}

#pragma mark - File Manager

- (NSFileManager*)fileManager
{
    if (fileManager_gv)
        return fileManager_gv;
    
    fileManager_gv = [[NSFileManager alloc] init];
    return fileManager_gv;
}

#pragma mark - Operation Queue

- (NSOperationQueue*)operationQueue
{
    if (operationQueue_gv)
        return operationQueue_gv;
    
    operationQueue_gv = [[NSOperationQueue alloc] init];
    [operationQueue_gv setMaxConcurrentOperationCount:1];
    return operationQueue_gv;
}

#pragma mark - Property Synthesis

@synthesize unorderedAppsArray;
@synthesize viewController;
@synthesize evaluationTimer;
@synthesize hasNetworkConnection;
@synthesize reachability;

@end
