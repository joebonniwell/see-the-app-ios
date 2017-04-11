//
//  SeeTheAppViewController.h
//  SeeTheApp
//
//  Created by goVertex on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVGalleryView.h"
#import "LocalyticsSession.h"
#import "STAScreenshotImage.h"
#import "STASearchBar.h"
#import "STAAppStoreButton.h"
#import <QuartzCore/QuartzCore.h>

@protocol SeeTheAppViewControllerDelegate <NSObject>

// Notification Methods
- (void)rowChanged;

// Network Methods
- (BOOL)hasNetworkConnection;

// File Path for Image Data
- (NSString*)filePathOfImageDataForURLString:(NSString*)argURLString;

- (void)checkPendingConnections;

- (void)updateLastPosition:(NSInteger)argLastPosition;

// Current Downloads
- (CFMutableDictionaryRef)currentListDownloadConnections;
- (NSMutableArray*)pendingListDownloadURLStrings;
- (CFMutableDictionaryRef)currentImageDownloadConnections;
- (NSMutableArray*)pendingImageDownloadURLStrings;

// Search Methods
- (void)startSearchResultsDownloadWithURLString:(NSString*)argSearchResultsDownloadURLString searchCategory:(NSInteger)argSearchCategory;

// Update Catgory
- (void)updateCategory:(enum STACategory)argCategory;

@end

@interface SeeTheAppGalleryViewController : UIViewController <GVGalleryViewDelegate, GVGalleryViewDataSource, NSFetchedResultsControllerDelegate, UIScrollViewDelegate, UISearchBarDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>
{
    // Delegate
    id delegate;
    
    // GalleryView
    GVGalleryView *galleryView;
    
    // Apps Display Array
    NSArray *appsDisplayArray;
    
    // Results Controller
    NSFetchedResultsController *resultsController;
    
    // Search Controller
    NSFetchedResultsController *searchController;
    
    // Current Mode
    enum STADisplayMode currentMode;
    
    // Searching Notification View
    UIView *searchingNotificationView;
    
    @private
        
    // Cell Images
    UIImage *cellBackgroundImage_gv;
    UIImage *pinImage_gv;
    UIImage *appStoreButtonImage_gv;
    UIImage *appStoreButtonHighlightedImage_gv;
    UIImage *appStoreButtonDisabledImage_gv;
    UIImage *errorIconImage_gv;
    
    // Image Cache
    NSMutableDictionary *imageCache_gv;
    
    // Navigation Bar Items
    UISegmentedControl *listPriceTierControl_gv;
    STASearchBar *searchBar_gv;
    UIToolbar *searchBottomToolbar_gv;
    UISegmentedControl *searchPriceTierControl_gv;
    
    // Search Mask View
    UIView *searchMaskView_gv;
}

// Delegate
@property (nonatomic, assign) id delegate;

// Navigation Bar Items
@property (nonatomic, retain, readonly) UISegmentedControl *listPriceTierControl;
@property (nonatomic, retain, readonly) STASearchBar *searchBar;
@property (nonatomic, retain, readonly) UIToolbar *searchBottomToolbar;
@property (nonatomic, retain, readonly) UISegmentedControl *searchPriceTierControl;

// Apps Display Array
@property (nonatomic, retain) NSArray *appsDisplayArray;

// STA GalleryViewCell Shared Images
@property (nonatomic, retain, readonly) UIImage *cellBackgroundImage;
@property (nonatomic, retain, readonly) UIImage *pinImage;
@property (nonatomic, retain, readonly) UIImage *appStoreButtonImage;
@property (nonatomic, retain, readonly) UIImage *appStoreButtonHighlightedImage;
@property (nonatomic, retain, readonly) UIImage *appStoreButtonDisabledImage;
@property (nonatomic, retain, readonly) UIImage *errorIconImage;

// Current Mode
@property enum STADisplayMode currentMode;

// Gallery View
@property (retain) GVGalleryView *galleryView;

// Results Controller
@property (nonatomic, retain) NSFetchedResultsController *resultsController;

// Search Controller
@property (nonatomic, retain) NSFetchedResultsController *searchController;

// Image Cache
@property (nonatomic, retain, readonly) NSMutableDictionary *imageCache;

// Searching Notification View
@property (nonatomic, retain) UIView *searchingNotificationView;

// Search Mask View
@property (nonatomic, retain, readonly) UIView *searchMaskView;

// Methods
- (id)initWithDelegate:(id)argDelegate;

// Download Management
- (void)updateDownloads;
- (void)updateListDownloads;
- (void)updateImageDownloads;
- (void)screenshotDownloadCompleted:(NSString*)argScreenshotURLString;

// Cache Methods
- (void)cacheImage:(STAScreenshotImage*)argImage forURLString:(NSString*)argURLString;
- (STAScreenshotImage*)cachedImageForURLString:(NSString*)argURLString;

- (void)updateResultsForPriceTier:(enum STAPriceTier)argPriceTier;

// Display Methods
- (void)displayMode:(enum STADisplayMode)argDisplayMode;
- (void)displayCategory:(enum STACategory)argCategory forAppStoreCountryCode:(NSString*)argCountryCode;
- (void)displayPosition:(NSInteger)argPosition forPriceTier:(enum STAPriceTier)argPriceTier;

// Position
- (NSInteger)positionOfCurrentRow;

// Localization
- (void)resetText;

// Searching Notification View Methods
- (void)updateSearchingNotificationViewWithState:(enum STASearchState)argState animated:(BOOL)argAnimated;

// Search Animation Methods
- (void)activeSearchAnimation;
- (void)inactiveSearchAnimation;

@end
