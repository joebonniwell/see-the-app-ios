//
//  SeeTheAppAppDelegate.h
//  SeeTheApp
//
//  Created by goVertex on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SeeTheAppViewController.h"
#import "LocalyticsSession.h"
#import "Reachability.h"
#import "SeeTheAppEvaluateOperation.h"
#import "SeeTheAppDownloadOperation.h"
#import <MessageUI/MessageUI.h>

@interface SeeTheAppAppDelegate : NSObject <UIApplicationDelegate, MFMailComposeViewControllerDelegate> 
{
    // Unordered Apps Array
    NSMutableArray *unorderedAppsArray;
    /*
        This array is a mutable copy of all fetch results with a displayIndex of -1 (meaning they have not been ordered).
        Apps are randomly selected from this array when the user pages forward. Apps that fail in the download operation for any reason
        are removed from this array, but not the database. This means that when this array reaches 0, it can be updated from the database
        with apps that will be given a "second chance".
     */
        
    // View Controller
    SeeTheAppViewController *viewController;
    /*
        The view controller handles the galleryview, providing it with number of rows, and cells similar to a UITableViewDatasource.
        It also carries messages from the galleryView about row changes to the delegate to start evaluation operations.
        The views behave the same for both the iPad and iPhone / iPod Touch, so dimensions and image path names are determined using the
        UIInterface_idiom() function.
     */
    
    // Reachability
    BOOL hasNetworkConnection;
    Reachability *reachability;
    
    // Evaluation Timer
    NSTimer *evaluationTimer;
    
    @private
    NSString *pathForScreenshotsDirectory_gv;
    NSFileManager *fileManager_gv;
    NSOperationQueue *operationQueue_gv;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;


@property (nonatomic, retain) NSMutableArray *unorderedAppsArray;

@property (retain) SeeTheAppViewController *viewController;

@property (nonatomic, retain) NSTimer *evaluationTimer;

@property (nonatomic) BOOL hasNetworkConnection;
@property (nonatomic, retain) Reachability *reachability;

@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain, readonly) NSString *pathForScreenshotsDirectory;
@property (nonatomic, retain, readonly) NSFileManager *fileManager;


- (void)updateUnorderedAppsArray;

- (void)saveContext;
//- (NSURL *)applicationDocumentsDirectory;
- (NSURL*)applicationLibraryDirectory;

- (void)startSessionAndDownloads;
- (void)resumeSessionAndDownloads;
- (NSInteger)currentRow;
- (BOOL)databaseExists;
- (void)cleanCacheWithHighestDisplayIndex:(NSInteger)argHighestDisplayIndex;

- (NSBlockOperation*)databaseMigrationBlockOperation;

- (void)startTimer;
- (void)stopTimer;
// Rating
- (BOOL)shouldPresentRateAlert;
- (void)presentRateAndFeedbackAlert;

@end
