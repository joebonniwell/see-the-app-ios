//
//  SeeTheAppAppDelegate.h
//  SeeTheApp
//
//  Created by goVertex on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SeeTheAppGalleryViewController.h"
#import "SeeTheAppMainMenuViewController.h"
#import "SeeTheAppCategoriesMenuViewController.h"
#import "SeeTheAppGamesSubcategoriesMenuViewController.h"
#import "SeeTheAppOptionsViewController.h"
#import "LocalyticsSession.h"
#import "Reachability.h"
#import "SBJson.h"
#import "STAApp.h"
#import "STACategory.h"
#import "STAXMLParseOperation.h"
#import "STALocalAppImporter.h"

@interface SeeTheAppAppDelegate : NSObject <UIApplicationDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, STAMainMenuDelegate, UINavigationControllerDelegate, SeeTheAppOptionsViewControllerDelegate, NSXMLParserDelegate> 
{
    // Reachability
    BOOL hasNetworkConnection;
    Reachability *reachability;
    
    // Evaluation Timer
    NSTimer *downloadStarterTimer;
    
    @private
    
    // View Controllers
    UINavigationController *navigationController_gv;
    SeeTheAppGalleryViewController *galleryViewController_gv;
    SeeTheAppMainMenuViewController *mainMenuViewController_gv;
    SeeTheAppCategoriesMenuViewController *categoriesMenuViewController_gv;
    SeeTheAppGamesSubcategoriesMenuViewController *gamesSubcategoriesMenuViewController_gv;
    SeeTheAppOptionsViewController *optionsViewController_gv;
    
    // XML Download Connections
    CFMutableDictionaryRef currentXMLDownloadConnections_gv;
    NSMutableArray *pendingXMLDownloadURLStrings_gv;
    
    // JSON List Download Connections
    CFMutableDictionaryRef currentListJSONDownloadConnections_gv;
    NSMutableArray *pendingListJSONDownloadURLStrings_gv;
    
    // Search Download Connections
    CFMutableDictionaryRef currentSearchDownloadConnection_gv;
    // Image Download Connections
    CFMutableDictionaryRef currentImageDownloadConnections_gv;
    NSMutableArray *pendingImageDownloadURLStrings_gv;
    
    // Paths
    NSString *pathForImageDataDirectory_gv;
    NSURL *applicationLibrarySTADirectory_gv;
    
    // Data
    NSArray *appStoreCountryCodes_gv;
    NSDictionary *affiliateCodesDictionary_gv;
    NSArray *categoriesInfo_gv;
    NSArray *gameCategoriesInfo_gv;
    NSDictionary *categories_gv;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) SeeTheAppGalleryViewController *galleryViewController;
@property (nonatomic, retain, readonly) UINavigationController *navigationController;
@property (nonatomic, retain, readonly) SeeTheAppMainMenuViewController *mainMenuViewController;
@property (nonatomic, retain, readonly) SeeTheAppCategoriesMenuViewController *categoriesMenuViewController;
@property (nonatomic, retain, readonly) SeeTheAppGamesSubcategoriesMenuViewController *gamesSubcategoriesMenuViewController;
@property (nonatomic, retain, readonly) SeeTheAppOptionsViewController *optionsViewController;

@property (nonatomic, retain) NSTimer *downloadStarterTimer;

@property (nonatomic) BOOL hasNetworkConnection;
@property (nonatomic, retain) Reachability *reachability;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// XML Parsing AppIDs Array
@property (atomic, retain) NSMutableSet *appIDsFromXML;

// Pending Connections
@property (nonatomic, retain, readonly) NSMutableArray *pendingImageDownloadURLStrings;
@property (nonatomic, retain, readonly) NSMutableArray *pendingXMLDownloadURLStrings;
@property (nonatomic, retain, readonly) NSMutableArray *pendingListJSONDownloadURLStrings;

// Current Connections
- (CFMutableDictionaryRef)currentSearchDownloadConnection;
- (CFMutableDictionaryRef)currentImageDownloadConnections;
- (CFMutableDictionaryRef)currentXMLDownloadConnections;
- (CFMutableDictionaryRef)currentListJSONDownloadConnections;

- (void)saveContext;

// Download Starter Timer Methods
- (void)startDownloadStarterTimer;
- (void)stopDownloadStarterTimer;

//- (void)populateInitialAppsForCurrentCountry;

- (NSString*)fileNameOfImageWithURLString:(NSString*)argURLString;
- (NSString*)filePathOfImageDataForURLString:(NSString*)argURLString;

- (void)checkPendingConnections;

- (void)restoreLastDisplayMode;

// Categories
//- (STACategory*)categoryForCategoryCode:(NSNumber*)argCategoryCode;

// App Download Methods
- (void)startXMLDownloads;

// Download Processing Methods
- (void)processXMLDownloadData:(NSDictionary*)argXMLDownloadData;
//- (void)processListJSONDownloadData:(NSDictionary*)argListJSONDownloadData;
- (void)processImageDownloadData:(NSDictionary*)argImageDownloadData;
//- (void)processSearchJSONDownloadData:(NSDictionary*)argSearchJSONDownloadData;
- (void)processNewAppsInJSONData:(NSData*)argJSONData asSearchResults:(BOOL)argAsSearchResults forCountry:(NSString*)argCountry;

// Start Next Download Methods
- (void)startPendingXMLDownloads;
- (void)startPendingListJSONDownloads;
- (void)startPendingImageDownloads;

// Other Methods
- (void)relocalizeText;

- (NSString*)pathForImageDataDirectory;

//- (void)processNewAppsInDictionary:(NSDictionary*)argDictionary;

- (NSURL*)applicationLibrarySTADirectory;

- (NSDate*)lastPositionForCategory:(NSInteger)argCategory;

- (void)updateNetworkActivityIndicator;

// Update State Data Methods
- (void)updateAppStoreCountry:(NSString*)argCountryCode;
- (void)updateLastPosition:(NSDate*)argLastPosition;
- (void)updateCategory:(STACategoryCode)argCategory;

// Information Arrays
- (NSArray*)appStoreCountryCodes;
//- (NSDictionary*)affiliateCodesDictionary;
- (NSArray*)categoriesInfo;
- (NSArray*)gameCategoriesInfo;
@end
