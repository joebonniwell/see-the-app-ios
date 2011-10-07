//
//  SeeTheAppViewController.m
//  SeeTheApp
//
//  Created by goVertex on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SeeTheAppViewController.h"


@implementation SeeTheAppViewController

#pragma mark - ViewController Lifecycle

- (id)initWithDelegate:(id)argDelegate
{
    if ((self = [super init]))
    {
        [self setDelegate:argDelegate];
        
        NSMutableDictionary *tempCache = [NSMutableDictionary dictionary];
        [self setScreenshotCache:tempCache];
    }
    return self;
}

- (void)dealloc
{
    [self setGalleryView:nil];
    [self setScreenshotCache:nil];
    
    [resultsController_gv release];
    
    [cellBackgroundImage_gv release];
    [pinImage_gv release];
    [appStoreButtonImage_gv release];
    [appStoreButtonHighlightedImage_gv release];
    [appStoreButtonDisabledImage_gv release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self reduceCache];
}

#pragma mark - View Lifecycle

- (void)loadView
{
    // Create View
    UIView *tempView;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        tempView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 768.0, 1024.0f)];
    else
        tempView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)]; 
    
    [tempView setBackgroundColor:[UIColor blackColor]];
    [self setView:tempView];
    [tempView release];
}

- (void)viewDidAppear
{
    NSLog(@"View Did Appear");
}

- (void)viewDidLoad
{    
    // Create the GalleryView
    GVGalleryView *tempGalleryView;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        tempGalleryView = [[GVGalleryView alloc] initWithFrame:CGRectMake(39.0f, 0.0f, 690.0f, 1024.0f)];
    else
        tempGalleryView = [[GVGalleryView alloc] initWithFrame:CGRectMake(22.0f, 0.0f, 276.0f, 480.0f)];
    
    [tempGalleryView setBackgroundColor:[UIColor blackColor]];
    [tempGalleryView setDelegate:self];
    [tempGalleryView setDataSource:self];
    [tempGalleryView setClipsToBounds:NO];
    [tempGalleryView setPagingEnabled:YES];
    [tempGalleryView setShowsHorizontalScrollIndicator:NO];
    [tempGalleryView setShowsVerticalScrollIndicator:NO];
    [self setGalleryView:tempGalleryView];
    [[self view] addSubview:tempGalleryView];
    [tempGalleryView release];

    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];    
    
    [self setGalleryView:nil];
    
    [cellBackgroundImage_gv release];
    cellBackgroundImage_gv = nil;
    
    [pinImage_gv release];
    pinImage_gv = nil;
    
    [appStoreButtonImage_gv release];
    appStoreButtonImage_gv = nil;
    
    [appStoreButtonHighlightedImage_gv release];
    appStoreButtonHighlightedImage_gv = nil;
    
    [appStoreButtonDisabledImage_gv release];
    appStoreButtonDisabledImage_gv = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{    
    if ([[self galleryView] currentRow] == 0)
    {
        NSInteger changedRow = [newIndexPath row] + 1;
        
        if (changedRow > 0 && changedRow <= 2)
            [[self galleryView] reloadData];
    }
    else
    {
        NSInteger changedRow = [newIndexPath row] + 1;
        NSInteger minVisibleRow = [[self galleryView] currentRow] - 1;
        NSInteger maxVisibleRow = [[self galleryView] currentRow] + 1;
        
        if (changedRow >= minVisibleRow && changedRow <= maxVisibleRow)
            [[self galleryView] reloadData];
    }
}

#pragma mark - GVGalleryViewDelegate Methods

- (void)didUpdateDisplayRow:(NSInteger)argRow
{    
    [[self delegate] rowChanged];
}

#pragma mark - GVGalleryViewDataSource Methods

- (NSInteger)numberOfRowsInGalleryView:(GVGalleryView *)argGalleryView
{    
    return [[[[self resultsController] sections] lastObject] numberOfObjects] + 2;
}

- (UIView*)headerViewForGalleryView:(GVGalleryView *)argGalleryView
{
    UIImageView *headerView;
    UIImage *headerFooterImage;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        headerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 690.0f, 1024.0f)] autorelease];
        headerFooterImage = [UIImage imageNamed:@"STAHeaderFooterHD"];
    }
    else
    {
        headerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 276.0f, 480.0f)] autorelease];
        headerFooterImage = [UIImage imageNamed:@"STACellHeaderFooter"];
    }
    
    [headerView setImage:headerFooterImage];
    [headerView setTag:kGVGalleryViewHeaderView];
    return headerView;
}

- (UIView*)footerViewForGalleryView:(GVGalleryView *)argGalleryView
{
    UIImageView *footerView;
    UIImage *headerFooterImage;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        footerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 690.0f, 1024.0f)] autorelease];
        headerFooterImage = [UIImage imageNamed:@"STAHeaderFooterHD"];
    }
    else
    {
        footerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 276.0f, 480.0f)] autorelease];
        headerFooterImage = [UIImage imageNamed:@"STACellHeaderFooter"];
    }
    
    [footerView setImage:headerFooterImage];
    [footerView setTag:kGVGalleryViewFooterView];
    return footerView;
}

- (GVGalleryViewCell*)galleryView:(GVGalleryView *)argGalleryView cellForRow:(NSInteger)argRow
{
    GVGalleryViewCell *cell = [argGalleryView dequeueCell];
    
    if (!cell)
    {
        // Cell
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            cell = [[[GVGalleryViewCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 690.0f, 1024.0f)] autorelease];
        else
            cell = [[[GVGalleryViewCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 276.0f, 480.0f)] autorelease];
        
        [cell setTag:kGVGalleryViewCell];
        
        // Background View
        
        UIImageView *backgroundImageView;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 690.0f, 1024.0f)];
        else
            backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 276.0f, 480.0f)];
        
        [backgroundImageView setImage:[self cellBackgroundImage]];
        [cell addSubview:backgroundImageView];
        [backgroundImageView release];
        
        // AppStore Button
        
        UIButton *appStoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [appStoreButton setTag:STAAppStoreButtonTag];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [appStoreButton setFrame:CGRectMake(227.0f, 900.0f, 236.0f, 86.0f)];
        else
            [appStoreButton setFrame:CGRectMake(68.0f, 404.0f, 140.0f, 51.0f)];
        
        [appStoreButton setImage:[self appStoreButtonDisabledImage] forState:UIControlStateDisabled];
        [appStoreButton setImage:[self appStoreButtonImage] forState:UIControlStateNormal];
        [appStoreButton setImage:[self appStoreButtonHighlightedImage] forState:UIControlStateHighlighted];
        [appStoreButton addTarget:self action:@selector(appStoreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:appStoreButton];
        
        // Screenshot Image View
        
        UIImageView *screenshotImageView;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            screenshotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(36.0f, 60.0f, 618.0f, 824.0f)];
        else
            screenshotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18.0f, 38.0f, 240.0f, 360.0f)];
        
        [screenshotImageView setTag:STAScreenshotImageViewTag];
        [screenshotImageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell addSubview:screenshotImageView];
        [screenshotImageView release];        
        
        // Activity Indicator View
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [activityIndicatorView setCenter:CGPointMake(345.0f, 472.0f)];
        else
            [activityIndicatorView setCenter:CGPointMake(138.0f, 220.0f)];
        
        [activityIndicatorView setTag:STAActivityIndicatorViewTag];
        [cell addSubview:activityIndicatorView];
        [activityIndicatorView release];
        
        // No Connection Label
        
        UILabel *noConnectionLabel;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            noConnectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(225.0f, 442.0f, 240.0f, 60.0f)];
        else
            noConnectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0f, 190.0f, 240.0f, 60.0f)];
        
        [noConnectionLabel setTag:STANoConnectionLabelTag];
        [noConnectionLabel setBackgroundColor:[UIColor blackColor]];
        [noConnectionLabel setTextColor:[UIColor whiteColor]];
        [noConnectionLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [noConnectionLabel setTextAlignment:UITextAlignmentCenter];
        [noConnectionLabel setText:@"Unable to connect"];
        [cell addSubview:noConnectionLabel];
        [noConnectionLabel release];        
        
        // Pin Image View
        
        UIImageView *pinImageView;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            pinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17.0, 32.0f, 656.0f, 36.0f)];
        else
            pinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(119.5, 20.0f, 37.0f, 36.0f)];
        
        [pinImageView setImage:[self pinImage]];
        [cell addSubview:pinImageView];
        [pinImageView release];
    }
    
    [cell setRow:argRow];
    
    UIImageView *screenshotImageView = (UIImageView*)[cell viewWithTag:STAScreenshotImageViewTag];
    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView*)[cell viewWithTag:STAActivityIndicatorViewTag];
    UILabel *noConnectionLabel = (UILabel*)[cell viewWithTag:STANoConnectionLabelTag];
    UIButton *appStoreButton = (UIButton*)[cell viewWithTag:STAAppStoreButtonTag];
    
    NSInteger lastRowIndex = [self numberOfRowsInGalleryView:argGalleryView] - 1;
    
    if (argRow == lastRowIndex)
    {
        [screenshotImageView setImage:nil];
    }
    else
    {
        NSNumber *rowKey = [NSNumber numberWithInteger:argRow];
        UIImage *screenshot = [[self screenshotCache] objectForKey:rowKey];
        if (!screenshot)
        {
            [self cacheImageForRow:rowKey];
            screenshot = [[self screenshotCache] objectForKey:rowKey];
        }
        
        [screenshotImageView setImage:screenshot];
    }
    
    if (![screenshotImageView image])
    {
        [appStoreButton setEnabled:NO];
        
        if ([[self delegate] hasNetworkConnection])
        {
            [activityIndicatorView startAnimating];
            [noConnectionLabel setHidden:YES];
        }
        else
        {
            [activityIndicatorView stopAnimating];
            [noConnectionLabel setHidden:NO];
        }
    }
    else
    {
        [activityIndicatorView stopAnimating];
        [noConnectionLabel setHidden:YES];
        [appStoreButton setEnabled:YES];
    }
    
    return cell;
}

#pragma mark - AppStoreButton

- (void)appStoreButtonTapped:(id)argSender
{
    UIButton *appStoreButton = (UIButton*)argSender;
    GVGalleryViewCell *cell = (GVGalleryViewCell*)[appStoreButton superview];
    NSInteger row = [cell row];
    
    NSURL *appURL;
    NSString *appIDString;
    
    if (row == 0) // Seaquations !!!
    {
        appURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/us/app/seaquations/id447974258?mt=8&uo=4%@", SeeTheAppAffiliateString]];
        
        appIDString = @"Seaquations";
    }
    else
    {        
        NSManagedObject *selectedApp = [[[self resultsController] fetchedObjects] objectAtIndex:(row - 1)];
        NSString *appURLString = [selectedApp valueForKey:STAAppPropertyAppURL];
        
        #ifdef LOG_SelectedAppDetails
            NSLog(@"DisplayIndex: %d", [[selectedApp valueForKey:STAAppPropertyDisplayIndex] integerValue]);
            NSLog(@"AppID: %d", [[selectedApp valueForKey:STAAppPropertyAppID] integerValue]);
            NSLog(@"AppImagePath: %@", [selectedApp valueForKey:STAAppPropertyImagePath]);
        #endif
        
        // Do a check to determine if the appURL contains a ? before the first / when searching backwards... if not, use a different affiliate string...
        
        appURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", appURLString, SeeTheAppAffiliateString]];
        
        appIDString = [NSString stringWithFormat:@"%d", [[selectedApp valueForKey:STAAppPropertyAppID] integerValue]];
    }
    
    NSLog(@"App URL: %@", appURL);
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:appIDString];
    [[UIApplication sharedApplication] openURL:appURL];
}

#pragma mark - Image Management Methods

- (void)cacheImageForRow:(NSNumber*)argRow
{
    NSString *imageFilePath;
    if ([argRow integerValue] == 0)
    {
        // Display Seaquations
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            imageFilePath = [[NSBundle mainBundle] pathForResource:@"SeaquationsScreenshotHD" ofType:@"png"];
        else
            imageFilePath = [[NSBundle mainBundle] pathForResource:@"SeaquationsScreenshot" ofType:@"png"];
        
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:imageFilePath];
        UIImage *imageToStage = [[UIImage alloc] initWithData:imageData];
        
        [[self screenshotCache] setObject:imageToStage forKey:argRow];
        
        [imageToStage release];
        [imageData release];
    }
    else if ([argRow integerValue] > 0 && [argRow integerValue] <= [[[[self resultsController] sections] lastObject] numberOfObjects])
    {    
        NSInteger screenshotIndex = [argRow integerValue] - 1;
        NSManagedObject *app = [[self resultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:screenshotIndex inSection:0]];
        imageFilePath = [app valueForKey:STAAppPropertyImagePath];
        
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:imageFilePath];
        if (!imageData)
        {
            [[self screenshotCache] removeObjectForKey:argRow];
            return;
        }
        
        UIImage *imageToStage = [[UIImage alloc] initWithData:imageData];
        
        if ([imageToStage size].width > [imageToStage size].height)
        {
            UIImage *reorientedImage = [[UIImage alloc] initWithCGImage:[imageToStage CGImage] scale:1.0f orientation:UIImageOrientationRight];
            if (reorientedImage)
                [[self screenshotCache] setObject:reorientedImage forKey:argRow];
            [reorientedImage release];
        }
        else
        {
            [[self screenshotCache] setObject:imageToStage forKey:argRow];
        }
        [imageToStage release];
        [imageData release];
    }
}

- (void)reduceCache
{
    NSMutableArray *keysToRemove = [NSMutableArray array];
    
    NSArray *cacheKeys = [[self screenshotCache] allKeys];
    for (NSNumber *key in cacheKeys)
    {
        if ([key integerValue] < [[self galleryView] currentRow] - 2 || [key integerValue] > [[self galleryView] currentRow] + 2)
        {
            [keysToRemove addObject:key];
        }
    }
    
    [[self screenshotCache] removeObjectsForKeys:keysToRemove];
}

- (void)emptyCache
{
    [[self screenshotCache] removeAllObjects];
}

#pragma mark - ResultsController Getter

- (NSFetchedResultsController*)resultsController
{
    if (resultsController_gv)
        return resultsController_gv;
    
    // Context
    NSManagedObjectContext *context = [[self delegate] managedObjectContext];
    if (!context)
        return nil;
    
    // Fetch Request
    NSFetchRequest *allOrderedAppsFetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity Description
    NSEntityDescription *appEntityDescription = [NSEntityDescription entityForName:@"App" inManagedObjectContext:context];
    [allOrderedAppsFetchRequest setEntity:appEntityDescription];
    
    // Predicate
    NSPredicate *appsWithPositiveDisplayIndexesForDevicePredicate;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        appsWithPositiveDisplayIndexesForDevicePredicate = [NSPredicate predicateWithFormat:@"displayIndex >= 0 AND (iPadOnlyApp == YES OR universalApp == YES)"];
    else
        appsWithPositiveDisplayIndexesForDevicePredicate = [NSPredicate predicateWithFormat:@"displayIndex >= 0 AND iPadOnlyApp == NO"];
    [allOrderedAppsFetchRequest setPredicate:appsWithPositiveDisplayIndexesForDevicePredicate];
    
    // Sort Descriptors
    NSSortDescriptor *displayIndexSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayIndex" ascending:YES];
    NSArray *sortDescriptorsArray = [NSArray arrayWithObject:displayIndexSortDescriptor];
    [allOrderedAppsFetchRequest setSortDescriptors:sortDescriptorsArray];
    
    [displayIndexSortDescriptor release];
    
    // Fetched Results Controller
    resultsController_gv = [[NSFetchedResultsController alloc] initWithFetchRequest:allOrderedAppsFetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    [resultsController_gv setDelegate:self];
    
    NSError *fetchError = nil;
    
    if([resultsController_gv performFetch:&fetchError] == NO)
        NSLog(@"Fetch Error: %@", [fetchError localizedDescription]);
    
    [allOrderedAppsFetchRequest release];
    
    return resultsController_gv;
}

#pragma mark - Cell Images

- (UIImage*)cellBackgroundImage
{
    if (cellBackgroundImage_gv)
        return cellBackgroundImage_gv;
    
    NSString *cellBackgroundImagePath;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        cellBackgroundImagePath = [[NSBundle mainBundle] pathForResource:@"STACellBackgroundHD" ofType:@"png"];
    else
        cellBackgroundImagePath = [[NSBundle mainBundle] pathForResource:@"STACellBackground" ofType:@"png"];
    
    cellBackgroundImage_gv = [[UIImage alloc] initWithContentsOfFile:cellBackgroundImagePath];

    return cellBackgroundImage_gv;
}

- (UIImage*)pinImage
{
    if (pinImage_gv)
        return pinImage_gv;
    
    NSString *pinImagePath;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        pinImagePath = [[NSBundle mainBundle] pathForResource:@"STAPinsHD" ofType:@"png"];
    else
        pinImagePath = [[NSBundle mainBundle] pathForResource:@"STAPin" ofType:@"png"];
    
    pinImage_gv = [[UIImage alloc] initWithContentsOfFile:pinImagePath];
    
    return pinImage_gv;
}

- (UIImage*)appStoreButtonImage
{
    if (appStoreButtonImage_gv)
        return appStoreButtonImage_gv;
    
    NSString *appStoreButtonImagePath;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        appStoreButtonImagePath = [[NSBundle mainBundle] pathForResource:@"STAAppStoreButtonHD" ofType:@"png"];
    else
        appStoreButtonImagePath = [[NSBundle mainBundle] pathForResource:@"STAAppStoreButton" ofType:@"png"];
    
    appStoreButtonImage_gv = [[UIImage alloc] initWithContentsOfFile:appStoreButtonImagePath];
    
    return appStoreButtonImage_gv;
}

- (UIImage*)appStoreButtonHighlightedImage
{
    if (appStoreButtonHighlightedImage_gv)
        return appStoreButtonHighlightedImage_gv;
    
    NSString *appStoreButtonHighlightedImagePath;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        appStoreButtonHighlightedImagePath = [[NSBundle mainBundle] pathForResource:@"STAAppStoreButtonHighlightedHD" ofType:@"png"];
    else
        appStoreButtonHighlightedImagePath = [[NSBundle mainBundle] pathForResource:@"STAAppStoreButtonHighlighted" ofType:@"png"];
    
    appStoreButtonHighlightedImage_gv = [[UIImage alloc] initWithContentsOfFile:appStoreButtonHighlightedImagePath];
    
    return appStoreButtonHighlightedImage_gv;
}

- (UIImage*)appStoreButtonDisabledImage
{
    if (appStoreButtonDisabledImage_gv)
        return appStoreButtonDisabledImage_gv;
    
    NSString *appStoreButtonDisabledImagePath;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        appStoreButtonDisabledImagePath = [[NSBundle mainBundle] pathForResource:@"STAAppStoreButtonDisabledHD" ofType:@"png"];
    else
        appStoreButtonDisabledImagePath = [[NSBundle mainBundle] pathForResource:@"STAAppStoreButtonDisabled" ofType:@"png"];
    
    appStoreButtonDisabledImage_gv = [[UIImage alloc] initWithContentsOfFile:appStoreButtonDisabledImagePath];
    
    return appStoreButtonDisabledImage_gv;
}

#pragma mark - Property Synthesis

@synthesize delegate;
@synthesize screenshotCache;
@synthesize galleryView;
@end
