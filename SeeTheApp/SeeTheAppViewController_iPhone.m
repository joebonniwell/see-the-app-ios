//
//  SeeTheAppViewController_iPhone.m
//  SeeTheApp
//
//  Created by goVertex on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SeeTheAppViewController_iPhone.h"


@implementation SeeTheAppViewController_iPhone

#pragma mark - ViewController Lifecycle

- (id)initWithContext:(NSManagedObjectContext*)argContext
{
    if ((self = [super init]))
    {
        maxCacheSize = 5;
        /*
        // Fetch Request
        NSFetchRequest *allOrderedAppsFetchRequest = [[NSFetchRequest alloc] init];
        
        // Entity Description
        NSEntityDescription *appEntityDescription = [NSEntityDescription entityForName:@"App" inManagedObjectContext:argContext];
        [allOrderedAppsFetchRequest setEntity:appEntityDescription];
        
        // Predicate
        NSPredicate *appsWithPositiveDisplayIndexesPredicate = nil;
        [allOrderedAppsFetchRequest setPredicate:appsWithPositiveDisplayIndexesPredicate];
        
        // Sort Descriptors
        NSSortDescriptor *displayIndexSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayIndex" ascending:YES];
        NSArray *sortDescriptorsArray = [NSArray arrayWithObject:displayIndexSortDescriptor];
        [allOrderedAppsFetchRequest setSortDescriptors:sortDescriptorsArray];
        
        [displayIndexSortDescriptor release];
        
        // Fetched Results Controller
        NSFetchedResultsController *tempScreenshotsResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:allOrderedAppsFetchRequest managedObjectContext:argContext sectionNameKeyPath:nil cacheName:nil];
        [tempScreenshotsResultsController setDelegate:self];
        [self setScreenshotsResultsController:tempScreenshotsResultsController];
        [tempScreenshotsResultsController release];
        
        [allOrderedAppsFetchRequest release];
        */
        // =================================================================================
        // Temporary...
        
        NSString *screenshot1Path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"png"];
        NSString *screenshot2Path = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"png"];
        NSString *screenshot3Path = [[NSBundle mainBundle] pathForResource:@"3" ofType:@"png"];
        NSString *screenshot4Path = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"png"];
        NSString *screenshot5Path = [[NSBundle mainBundle] pathForResource:@"5" ofType:@"png"];
        NSString *screenshot6Path = [[NSBundle mainBundle] pathForResource:@"6" ofType:@"png"];
        NSString *screenshot7Path = [[NSBundle mainBundle] pathForResource:@"7" ofType:@"png"];
        /*
        NSDate *startingTime = [NSDate date];
        NSData *imageData = [NSData dataWithContentsOfFile:screenshot1Path];
        NSDate *dataCreatedDate = [NSDate date];
        UIImage *image = [UIImage imageWithData:imageData];
        NSDate *imageCreatedDate = [NSDate date];
        
        NSTimeInterval dataToImageTime = [imageCreatedDate timeIntervalSinceDate:dataCreatedDate];
        NSTimeInterval fileToDataTime = [dataCreatedDate timeIntervalSinceDate:startingTime];
        
        NSLog(@"Time from File to NSData: %f", fileToDataTime);
        NSLog(@"Time from NSData to UIImage: %f", dataToImageTime);
        */
        imagePaths = [[NSArray alloc] initWithObjects:
                      screenshot1Path, screenshot2Path, screenshot3Path, 
                      screenshot4Path, screenshot5Path, screenshot6Path, 
                      screenshot7Path, screenshot1Path, screenshot2Path, 
                      screenshot3Path, screenshot4Path, screenshot5Path, 
                      screenshot6Path, screenshot7Path, nil];
        
        // =================================================================================
        
        NSMutableDictionary *tempCache = [NSMutableDictionary dictionary];
        [self setScreenshotCache:tempCache];
        
        NSOperationQueue *tempOperationQueue = [[NSOperationQueue alloc] init];
        [self setImageLoadingOperationsQueue:tempOperationQueue];
        [tempOperationQueue release];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    NSLog(@"Received Memory Warning");
    // Take a look at what images we can dump from the cache....
    
    // Reduce the cache limit by 1 if above minimum...
    
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View Lifecycle

- (void)loadView
{
    // Create View
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
    [self setView:tempView];
    [tempView release];
}

- (void)viewDidLoad
{
    //[[self screenshotsResultsController] performFetch:nil];
    
    // Create the cellBackgroundImage
    NSString *cellBackgroundImagePath = [[NSBundle mainBundle] pathForResource:@"STACellBackground" ofType:@"png"];
    UIImage *tempCellBackgroundImage = [[UIImage alloc] initWithContentsOfFile:cellBackgroundImagePath];
    [self setCellBackgroundImage:tempCellBackgroundImage];
    [tempCellBackgroundImage release];    
    
    // Create the Pin Image
    NSString *pinImagePath = [[NSBundle mainBundle] pathForResource:@"STAPin" ofType:@"png"];
    UIImage *tempPinImage = [[UIImage alloc] initWithContentsOfFile:pinImagePath];
    [self setPinImage:tempPinImage];
    [tempPinImage release];
    
    // Create the AppStoreButton Image
    NSString *appStoreButtonImagePath = [[NSBundle mainBundle] pathForResource:@"STAAppStoreButton" ofType:@"png"];
    UIImage *tempAppStoreButtonImage = [[UIImage alloc] initWithContentsOfFile:appStoreButtonImagePath];
    [self setAppStoreButtonImage:tempAppStoreButtonImage];
    [tempAppStoreButtonImage release];
    
    // Create the AppStoreButton Highlighted Image
    NSString *appStoreButtonHighlightedImagePath = [[NSBundle mainBundle] pathForResource:@"STAAppStoreButtonHighlighted" ofType:@"png"];
    UIImage *tempAppStoreButtonHighlightedImage = [[UIImage alloc] initWithContentsOfFile:appStoreButtonHighlightedImagePath];
    [self setAppStoreButtonHighlightedImage:tempAppStoreButtonHighlightedImage];
    [tempAppStoreButtonHighlightedImage release];
    
    // Create the AppStoreButton Diabled Image
    NSString *appStoreButtonDisabledImagePath = [[NSBundle mainBundle] pathForResource:@"STAAppStoreButtonDisabled" ofType:@"png"];
    UIImage *tempAppStoreButtonDisabledImage = [[UIImage alloc] initWithContentsOfFile:appStoreButtonDisabledImagePath];
    [self setAppStoreButtonDisabledImage:tempAppStoreButtonDisabledImage];
    [tempAppStoreButtonDisabledImage release];
    
    // Create the tableview
    UITableView *tempScreenshotsTableView = [[UITableView alloc] initWithFrame:CGRectMake(-80.0f, 80.0f, 480.0f, 320.0f) style:UITableViewStylePlain];
    [tempScreenshotsTableView setDelegate:self];
    [tempScreenshotsTableView setDataSource:self];
    [tempScreenshotsTableView setClipsToBounds:NO];
    [tempScreenshotsTableView setRowHeight:276.0f];
    [tempScreenshotsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tempScreenshotsTableView setShowsVerticalScrollIndicator:NO];
    [tempScreenshotsTableView setShowsHorizontalScrollIndicator:NO];
    [tempScreenshotsTableView setBackgroundColor:[UIColor blackColor]];
    [tempScreenshotsTableView setAllowsSelection:NO];
    [[self view] addSubview:tempScreenshotsTableView];
    [self setScreenshotsTableView:tempScreenshotsTableView];
    [tempScreenshotsTableView release];
    
    // Create Transform
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI * -0.5f);
    [[self screenshotsTableView] setTransform:rotationTransform];
    
    // Create Header Footer Image
    NSString *headerFooterImagePath = [[NSBundle mainBundle] pathForResource:@"STACellHeaderFooter" ofType:@"png"];
    UIImage *headerFooterImage = [[UIImage alloc] initWithContentsOfFile:headerFooterImagePath];    
    
    // Create Header View
    UIImageView *tempHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 22.0f, 480.0f)];
    [tempHeaderView setTransform:rotationTransform];
    [tempHeaderView setImage:headerFooterImage];
    [[self screenshotsTableView] setTableHeaderView:tempHeaderView];
    [tempHeaderView release];    
    
    // Create Footer View
    UIImageView *tempFooterView = [[UIImageView alloc] initWithFrame:CGRectMake(229.0f, 0.0f, 22.0f, 480.0f)];
    [tempFooterView setTransform:rotationTransform];
    [tempFooterView setImage:headerFooterImage];
    [[self screenshotsTableView] setTableFooterView:tempFooterView];
    [tempFooterView release]; 
    
    [headerFooterImage release];
     
    
    // Determine starting index
    NSInteger startingIndex = 0;
    
    
    // Load immediately
    
    // Start op for index
    
    NSString *filePath = [imagePaths objectAtIndex:startingIndex];
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:filePath];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    [[self screenshotCache] setObject:image forKey:[NSNumber numberWithInteger:startingIndex]];
    [image release];
    [imageData release];
    
    if (startingIndex + 1 < [imagePaths count])
    {
        NSString *imageFilePath = [imagePaths objectAtIndex:(startingIndex + 1)];
        NSData *screenshotData = [[NSData alloc] initWithContentsOfFile:imageFilePath];
        UIImage *screenshot = [[UIImage alloc] initWithData:screenshotData];
        [[self screenshotCache] setObject:screenshot forKey:[NSNumber numberWithInteger:(startingIndex + 1)]];
        [screenshot release];
        [screenshotData release];
    }
    
    if (startingIndex > 1)
    {
        NSString *imageFilePath = [imagePaths objectAtIndex:(startingIndex - 1)];
        NSData *screenshotData = [[NSData alloc] initWithContentsOfFile:imageFilePath];
        UIImage *screenshot = [[UIImage alloc] initWithData:screenshotData];
        [[self screenshotCache] setObject:screenshot forKey:[NSNumber numberWithInteger:(startingIndex - 1)]];
        [screenshot release];
        [screenshotData release];
    }
    
    // End load immediately
    
    if (startingIndex + 2 < [imagePaths count])
    {
        SeeTheAppScreenshotLoadOperation *newOp = [SeeTheAppScreenshotLoadOperation operationWithPath:[imagePaths objectAtIndex:(startingIndex + 2)] row:(startingIndex + 2) delegate:self];
        [[self imageLoadingOperationsQueue] addOperation:newOp];
    }
    
    if (startingIndex - 2 > 0)
    {
        SeeTheAppScreenshotLoadOperation *newOp = [SeeTheAppScreenshotLoadOperation operationWithPath:[imagePaths objectAtIndex:(startingIndex - 2)] row:(startingIndex - 2) delegate:self];
        [[self imageLoadingOperationsQueue] addOperation:newOp];
    } 
    
    if (startingIndex + 3 < [imagePaths count])
    {
        SeeTheAppScreenshotLoadOperation *newOp = [SeeTheAppScreenshotLoadOperation operationWithPath:[imagePaths objectAtIndex:(startingIndex + 3)] row:(startingIndex + 3) delegate:self];
        [[self imageLoadingOperationsQueue] addOperation:newOp];
    }
    
    if (startingIndex - 3 > 0)
    {
        SeeTheAppScreenshotLoadOperation *newOp = [SeeTheAppScreenshotLoadOperation operationWithPath:[imagePaths objectAtIndex:(startingIndex - 2)] row:(startingIndex - 2) delegate:self];
        [[self imageLoadingOperationsQueue] addOperation:newOp];
    } 
    
    // Start filling cache
    /*
    for (int loadOperationCounter = 0; loadOperationCounter < maxCacheSize; loadOperationCounter++)
    {
        // Create a load operation with path and row index...
        
        NSString *pathString = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", loadOperationCounter + 1]  ofType:@"png"];
        
    }
    */
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self setScreenshotsTableView:nil];
    [self setScreenshotsResultsController:nil];
    [self setAdditionalScreenshotsIndicatorView:nil];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController*)argController
{
    
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *visibleRowsIndexPaths = [tableView indexPathsForVisibleRows];
    if ([visibleRowsIndexPaths count] > 0)
    {
        if ([indexPath row] > [[visibleRowsIndexPaths lastObject] row])
        {
            if ([indexPath row] + 3 < [imagePaths count])   // TODO: Change this to use the fetchedresultscontroller when we implement that...
            {
                NSString *imagePath = [imagePaths objectAtIndex:([indexPath row] + 3)];
                SeeTheAppScreenshotLoadOperation *newLoadOp = [SeeTheAppScreenshotLoadOperation operationWithPath:imagePath row:([indexPath row] + 3) delegate:self];
                [[self imageLoadingOperationsQueue] addOperation:newLoadOp];
            }
            
            [[self screenshotCache] removeObjectForKey:[NSNumber numberWithInteger:([indexPath row] - 3)]];
        }
        else if ([indexPath row] < [[visibleRowsIndexPaths objectAtIndex:0] row])
        {            
            if ([indexPath row] >= 3)   // TODO: Change this to use the fetchedresultscontroller when we implement that...
            {
                NSString *imagePath = [imagePaths objectAtIndex:([indexPath row] - 3)];
                SeeTheAppScreenshotLoadOperation *newLoadOp = [SeeTheAppScreenshotLoadOperation operationWithPath:imagePath row:([indexPath row] - 3) delegate:self];
                [[self imageLoadingOperationsQueue] addOperation:newLoadOp];
            }
            
            [[self screenshotCache] removeObjectForKey:[NSNumber numberWithInteger:([indexPath row] + 3)]];
        }
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)argTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return [[[self screenshotsResultsController] fetchedObjects] count] + 1;    // Adding one here to represent the row which shows a loading screen, but is not in the core data results
    //return 15;
    return [imagePaths count];
}

- (UITableViewCell*)tableView:(UITableView*)argTableView cellForRowAtIndexPath:(NSIndexPath*)argIndexPath
{    
    static NSString *screenshotsTableViewCellIdentifier = @"ScreenshotsTableViewCellIdentifier";
    
    UITableViewCell *cell = [argTableView dequeueReusableCellWithIdentifier:screenshotsTableViewCellIdentifier];
    if (!cell)
    {
        // Create new cell
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:screenshotsTableViewCellIdentifier] autorelease];
        
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI * 0.5f);
        
        // Create an imageview with background image
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 276.0f, 480.0f)];
        [backgroundImageView setTransform:rotationTransform];
        [backgroundImageView setImage:[self cellBackgroundImage]];
        [cell setBackgroundView:backgroundImageView];
        [backgroundImageView release];
        
        // Create an imageview with tag for screenshot
        UIImageView *screenshotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(142.0f, -42.0f, 240.0f, 360.0f)];
        [screenshotImageView setTransform:rotationTransform];
        [screenshotImageView setTag:1];
        [[cell contentView] addSubview:screenshotImageView];
        [screenshotImageView release];
        
        // Create an ActivityIndicatorView with tag
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicatorView setCenter:CGPointMake(270.0f, 140.0f)];
        [activityIndicatorView setTag:2];
        [[cell contentView] addSubview:activityIndicatorView];
        [activityIndicatorView release];
        
        // Create an imageView with pin image
        UIImageView *pinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(425.0f, 119.5f, 37.0f, 36.0f)];
        [pinImageView setTransform:rotationTransform];
        [pinImageView setImage:[self pinImage]];
        [[cell contentView] addSubview:pinImageView];
        [pinImageView release];
        
        // Create App Store Button with Image
        UIButton *appStoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [appStoreButton setFrame:CGRectMake(-20.0f, 116.0f, 140.0f, 51.0f)];
        [appStoreButton setTransform:rotationTransform];
        // Set Target and action
        [appStoreButton setImage:[self appStoreButtonImage] forState:UIControlStateNormal];
        [appStoreButton setImage:[self appStoreButtonHighlightedImage] forState:UIControlStateHighlighted];
        [appStoreButton setImage:[self appStoreButtonDisabledImage] forState:UIControlStateDisabled];
        [[cell contentView] addSubview:appStoreButton];
    }
    
    UIImageView *imageView = (UIImageView*)[[cell contentView] viewWithTag:1];
    [imageView setImage:nil];
    
    [imageView setImage:[[self screenshotCache] objectForKey:[NSNumber numberWithInteger:[argIndexPath row]]]];
    
    // Create a block operation that loads the image and applies it to the view
    /*
    NSInteger randomScreenshot = arc4random() % [imagePaths count];
    NSString *screenshotPath = [imagePaths objectAtIndex:randomScreenshot];
    
    NSBlockOperation *imageLoadOp = [NSBlockOperation blockOperationWithBlock:^{
        
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:screenshotPath];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        
        [imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
        
        [imageData release];
        [image release];
    }];
        
    [[self imageLoadingOperationsQueue] addOperation:imageLoadOp];
    
    UIImage *screenshotImage = [[self screenshotCache] objectForKey:[NSNumber numberWithInteger:[argIndexPath row]]];
    if (!screenshotImage)
    {
        // Load the screenshot image synchronously
        NSInteger randomScreenshot = arc4random() % [imagePaths count];
        NSString *screenshotPath = [imagePaths objectAtIndex:randomScreenshot];
        NSData *screenshotData = [[NSData alloc] initWithContentsOfFile:screenshotPath];
        UIImage *screenshotImage = [[UIImage alloc] initWithData:screenshotData];
        [imageView setImage:screenshotImage];
        
        if ([screenshotImage size].width > [screenshotImage size].height)
        {
            UIImage *reorientedImage = [[UIImage alloc] initWithCGImage:[screenshotImage CGImage] scale:1.0f orientation:UIImageOrientationRight];
            [imageView setImage:reorientedImage];
            [reorientedImage release];
        }
        else
            [imageView setImage:screenshotImage];
        
        [screenshotData release];
        [screenshotImage release];
    }
    */
    return cell;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // Potentially pause activities to allow for better scrolling performance
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"Scroll View Did Scroll - Offset: %f, %f", [scrollView contentOffset].x, [scrollView contentOffset].y);
    
    // If we have moved beyond a row, and there are rows available to precache...
    
    //NSArray *visibleRowIndexPaths = [[self screenshotsTableView] indexPathsForVisibleRows];
    
    
    //[[visibleRowIndexPaths lastObject] row]
    
    //NSDictionary *imageLoadData = [NSDictionary dictionaryWithObjectsAndKeys:@"images/x.png", @"ImagePathKey", @"0", @"ImageIndexKey", nil];
    //[[NSRunLoop mainRunLoop] performSelector:@selector(loadImageToCache:) target:self argument:imageLoadData order:0 modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // Potentially resume activities
}

#pragma mark - Image Management Methods

- (void)loadImageToCache:(NSDictionary*)imageLoadData
{
    // Unpack the file path, load the data, load the image
    NSString *imagePath = [imageLoadData objectForKey:@"ImagePathKey"];
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:imagePath];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    NSString *imageIndex = [imageLoadData objectForKey:@"ImageIndexKey"];
    [[self screenshotCache] setObject:image forKey:imageIndex];
    
    [imageData release];
    [image release];
    
    // Fire off a notification that the image has been added to the cache in case we need to update the tableview...
}

- (void)cacheImage:(NSDictionary*)argImageAndKey
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:_cmd withObject:argImageAndKey waitUntilDone:NO];
        return;
    }
    
    //NSInteger imageRow = [[argImageAndKey objectForKey:@"RowKey"] integerValue];
    NSNumber *key = [argImageAndKey objectForKey:@"RowKey"];
    UIImage *screenshotImage = [argImageAndKey objectForKey:@"ImageKey"];
                  
    [[self screenshotCache] setObject:screenshotImage forKey:key];
    
    //NSString *cacheKey = [[NSString alloc] initWithFormat:@"%d", imageRow];
    //[[self screenshotCache] setObject:screenshotImage forKey:cacheKey];
    //[cacheKey release];
    
    // Update cell if necessary
    //NSIndexPath *updatedRowIndexPath = [NSIndexPath indexPathForRow:imageRow inSection:1];
    /*
    if ([[[self screenshotsTableView] indexPathsForVisibleRows] containsObject:updatedRowIndexPath])
    {
        UITableViewCell *cellAtUpdatedRow = [[self screenshotsTableView] cellForRowAtIndexPath:updatedRowIndexPath];
        UIImageView *cellScreenshotImageView = (UIImageView*)[[cellAtUpdatedRow contentView] viewWithTag:1];
        if (![cellScreenshotImageView image])
            [cellScreenshotImageView setImage:screenshotImage];
    }
     */
}

- (void)loadImage:(NSDictionary*)argPackage
{
    UITableViewCell *cellToUpdate = [argPackage objectForKey:@"CellKey"];
    NSString *filePath = [argPackage objectForKey:@"PathKey"];

    NSData *imageData = [[NSData alloc] initWithContentsOfFile:filePath];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    UIImageView *screenshotImageView = (UIImageView*)[[cellToUpdate contentView] viewWithTag:1];
    
    if ([image size].width > [image size].height)
    {
        UIImage *reorientedImage = [[UIImage alloc] initWithCGImage:[image CGImage] scale:1.0f orientation:UIImageOrientationRight];
        [screenshotImageView setImage:reorientedImage];
        [reorientedImage release];
    }
    else
        [screenshotImageView setImage:image];
    //[screenshotImageView setImage:image];
    
    [imageData release];
    [image release];
}

#pragma mark - Property Synthesis

@synthesize screenshotsTableView;
@synthesize screenshotsResultsController;
@synthesize additionalScreenshotsIndicatorView;
@synthesize cellBackgroundImage;
@synthesize pinImage;
@synthesize appStoreButtonImage;
@synthesize appStoreButtonHighlightedImage;
@synthesize appStoreButtonDisabledImage;
@synthesize imageLoadingOperationsQueue;
@synthesize screenshotCache;

@end
