//
//  SeeTheAppViewController_iPhone.h
//  SeeTheApp
//
//  Created by goVertex on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeeTheAppScreenshotLoadOperation.h"

@interface SeeTheAppViewController_iPhone : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UITableView *screenshotsTableView;
    NSFetchedResultsController *screenshotsResultsController;
    UIImageView *additionalScreenshotsIndicatorView;
    //UIView *touchesView;
    
    UIImage *cellBackgroundImage;
    UIImage *pinImage;
    UIImage *appStoreButtonImage;
    UIImage *appStoreButtonHighlightedImage;
    UIImage *appStoreButtonDisabledImage;
    
    NSMutableDictionary *screenshotCache;
    NSOperationQueue *imageLoadingOperationsQueue;
    
    // Temp
    NSArray *imagePaths;
    
    NSInteger maxCacheSize;
}

@property (nonatomic, retain) UITableView *screenshotsTableView;
@property (nonatomic, retain) NSFetchedResultsController *screenshotsResultsController;
@property (nonatomic, retain) UIImageView *additionalScreenshotsIndicatorView;
@property (nonatomic, retain) UIImage *cellBackgroundImage;
@property (nonatomic, retain) UIImage *pinImage;
@property (nonatomic, retain) UIImage *appStoreButtonImage;
@property (nonatomic, retain) UIImage *appStoreButtonHighlightedImage;
@property (nonatomic, retain) UIImage *appStoreButtonDisabledImage;


@property (nonatomic, retain) NSOperationQueue *imageLoadingOperationsQueue;

@property (nonatomic, retain) NSMutableDictionary *screenshotCache;

- (id)initWithContext:(NSManagedObjectContext*)argContext;

@end
