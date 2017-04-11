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

@protocol SeeTheAppViewControllerDelegate <NSObject>

// Notification Methods
- (void)rowChanged;

// Network Methods
- (BOOL)hasNetworkConnection;

@end

@interface SeeTheAppViewController : UIViewController <GVGalleryViewDelegate, GVGalleryViewDataSource, NSFetchedResultsControllerDelegate, UIScrollViewDelegate>
{
    // Delegate
    id delegate;
    
    // Screenshot Cache
    NSMutableDictionary *screenshotCache;
    
    // GalleryView
    GVGalleryView *galleryView;
    
    @private
    NSFetchedResultsController *resultsController_gv;
    
    // Cell Images
    UIImage *cellBackgroundImage_gv;
    UIImage *pinImage_gv;
    UIImage *appStoreButtonImage_gv;
    UIImage *appStoreButtonHighlightedImage_gv;
    UIImage *appStoreButtonDisabledImage_gv;
}

// Delegate
@property (nonatomic, assign) id delegate;

// STA GalleryViewCell Shared Images
@property (nonatomic, retain, readonly) UIImage *cellBackgroundImage;
@property (nonatomic, retain, readonly) UIImage *pinImage;
@property (nonatomic, retain, readonly) UIImage *appStoreButtonImage;
@property (nonatomic, retain, readonly) UIImage *appStoreButtonHighlightedImage;
@property (nonatomic, retain, readonly) UIImage *appStoreButtonDisabledImage;

// Screenshot Cache
@property (nonatomic, retain) NSMutableDictionary *screenshotCache;

// Gallery View
@property (retain) GVGalleryView *galleryView;

// Results Controller
@property (nonatomic, retain, readonly) NSFetchedResultsController *resultsController;

// Methods
- (id)initWithDelegate:(id)argDelegate;
- (void)cacheImageForRow:(NSNumber*)argRow;
- (void)reduceCache;
- (void)emptyCache;

@end
