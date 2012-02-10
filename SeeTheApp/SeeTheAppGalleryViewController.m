//
//  SeeTheAppViewController.m
//  SeeTheApp
//
//  Created by goVertex on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SeeTheAppGalleryViewController.h"


@implementation SeeTheAppGalleryViewController

#pragma mark - ViewController Lifecycle

- (id)initWithDelegate:(id)argDelegate
{
    if ((self = [super init]))
    {
        [self setDelegate:argDelegate];
                
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rowChanged) name:@"GalleryViewRowDidChangeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFailed:) name:STASearchErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchHadNoResults:) name:STASearchNoResultsNotification object:nil];
        
    }
    return self;
}

- (void)dealloc
{    
    [self setGalleryView:nil];
        
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setResultsController:nil];
    
    [cellBackgroundImage_gv release];
    [pinImage_gv release];
    [appStoreButtonImage_gv release];
    
    [imageCache_gv release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"RECEIVED MEMORY WARNING");
    
    // Should reduce in-use memory.... can i control that cache?
    [[self imageCache] removeAllObjects];
}

#pragma mark - View Lifecycle

- (void)loadView
{
    // Create View
    UIView *tempView;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        tempView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 768.0, 960.0f)];
    else
        tempView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)]; 
    [tempView setUserInteractionEnabled:YES];
    [tempView setBackgroundColor:[UIColor blackColor]];
    [self setView:tempView];
    [tempView release];
}

- (void)viewDidAppear:(BOOL)animated
{    
    [self updateDownloads];
}

- (void)viewDidLoad
{    
    // Create the GalleryView
    GVGalleryView *tempGalleryView;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        tempGalleryView = [[GVGalleryView alloc] initWithFrame:CGRectMake(58.0f, 0.0f, 652.0f, 960.0f)];
    else
        tempGalleryView = [[GVGalleryView alloc] initWithFrame:CGRectMake(30.0f, 0.0f, 260.0f, 416.0f)];
    
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

    // Create the navigationbar shadow
    UIImageView *navigationBarShadowImageView;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        navigationBarShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 768.0f, 8.0f)];
        [navigationBarShadowImageView setImage:[UIImage imageNamed:@"STANavigationBarShadowHD.png"]];
    }
    else
    {
        navigationBarShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 6.0f)];
        [navigationBarShadowImageView setImage:[UIImage imageNamed:@"STANavigationBarShadow.png"]];
    }
    [navigationBarShadowImageView setBackgroundColor:[UIColor clearColor]];
    [navigationBarShadowImageView setOpaque:NO];
    [[self view] addSubview:navigationBarShadowImageView];
    [navigationBarShadowImageView release];
    
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
    
    [imageCache_gv release];
    imageCache_gv = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Search Animations

- (void)activeSearchAnimation
{
    CGPoint searchBottomToolbarCenter = CGPointMake(160.0f, 22.0f);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        searchBottomToolbarCenter = CGPointMake(384.0f, 22.0f);
    
    [[self view] insertSubview:[self searchMaskView] belowSubview:[self searchBottomToolbar]];
    [[self searchMaskView] setAlpha:0.0f];
    [[self searchMaskView] setHidden:NO];
    
    [UIView animateWithDuration:0.2f animations:^{
        [[self searchBottomToolbar] setCenter:searchBottomToolbarCenter];
        [[self searchMaskView] setAlpha:1.0f];
    }];
}

- (void)inactiveSearchAnimation
{
    CGPoint searchBottomToolbarCenter = CGPointMake(160.0f, -22.0f);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        searchBottomToolbarCenter = CGPointMake(384.0f, -22.0f);
    
    [UIView animateWithDuration:0.2f animations:^{
        [[self searchBottomToolbar] setCenter:searchBottomToolbarCenter];
        [[self searchMaskView] setAlpha:0.0f];
    } completion:^(BOOL finished){
        [[self searchMaskView] setHidden:YES];
    }];
}

#pragma mark - Search Methods

- (void)searchPriceTierDidChange
{
    if ([[self searchPriceTierControl] selectedSegmentIndex] == 0)
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STAPriceTierAll] forKey:STADefaultsLastSearchPriceTierKey];
    else
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STAPriceTierFree] forKey:STADefaultsLastSearchPriceTierKey];
}

- (void)searchCancelButtonTapped
{
    [self inactiveSearchAnimation];
    [[self searchBar] resignFirstResponder];
    [[self searchBar] setText:[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastSearchTermKey]];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)argSearchBar
{
    [self activeSearchAnimation];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar*)argSearchBar
{
    [self inactiveSearchAnimation];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)argSearchBar
{    
    [self inactiveSearchAnimation];
    [[self searchBar] resignFirstResponder];
    
    #ifdef LOG_SearchStatus
        NSLog(@"Searching for term: '%@'", [argSearchBar text]);    
    #endif
    
    NSString *countryCode = [[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsAppStoreCountryKey];
    NSInteger searchPriceTier = 1;
    if ([[self searchPriceTierControl] selectedSegmentIndex] == 1)
        searchPriceTier = 0;
    NSInteger searchCategory = 10000;
    if ([[[self searchController] fetchedObjects] count] > 0)
        searchCategory = [[[[[self searchController] fetchedObjects] lastObject] valueForKey:STASearchRecordAttributeSearchCategory] integerValue] + 1;
    NSString *searchTerm = [argSearchBar text];
    
    NSManagedObject *newSearchRecord = [NSEntityDescription insertNewObjectForEntityForName:@"SearchRecord" inManagedObjectContext:[[self delegate] managedObjectContext]];
    [newSearchRecord setValue:countryCode forKey:STASearchRecordAttributeCountry];
    [newSearchRecord setValue:[NSNumber numberWithInteger:searchPriceTier] forKey:STASearchRecordAttributePriceTier];
    [newSearchRecord setValue:[NSNumber numberWithInteger:searchCategory] forKey:STASearchRecordAttributeSearchCategory];
    [newSearchRecord setValue:[NSDate date] forKey:STASearchRecordAttributeSearchDate];
    [newSearchRecord setValue:searchTerm forKey:STASearchRecordAttributeSearchTerm];
    [[[self delegate] managedObjectContext] save:nil];
    
    NSString *deviceString;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        deviceString = @"pad";
    else
        deviceString = @"phone";
    
    NSString *priceTier = @"all";
    if (searchPriceTier == 0)
        priceTier = @"free";
    
    NSString *escapedSearchTerm = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)searchTerm, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    //NSString *escapedSearchTerm = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    #ifdef LOG_SearchStatus
        NSLog(@"Percent Encoded Search Term: %@", escapedSearchTerm);
    #endif
    NSString *searchURLString = [NSString stringWithFormat:@"http://search.seetheapp.com/search?country=%@&device=%@&price=%@&cat=%d&searchterm=%@", countryCode, deviceString, priceTier, searchCategory, escapedSearchTerm];
    [[self delegate] startSearchResultsDownloadWithURLString:searchURLString searchCategory:searchCategory];
    
    CFRelease((CFStringRef)escapedSearchTerm);
    #ifdef LOG_SearchStatus
        NSLog(@"Performing search with URL: %@", searchURLString);
    #endif
    [[NSUserDefaults standardUserDefaults] setValue:searchTerm forKey:STADefaultsLastSearchTermKey];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STASearchStateInProgress] forKey:STADefaultsLastSearchStateKey];

    [[self delegate] updateCategory:searchCategory];
    
    [self updateSearchingNotificationViewWithState:STASearchStateInProgress animated:YES];
}

#pragma mark - Search Notification Methods

- (void)searchFailed:(NSNotification*)argNotification
{    
    NSInteger searchCategory = [[[argNotification userInfo] objectForKey:@"STASearchCategory"] integerValue];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastSearchCategoryKey] integerValue] == searchCategory)
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STASearchStateFailed] forKey:STADefaultsLastSearchStateKey];
        [self updateSearchingNotificationViewWithState:STASearchStateFailed animated:YES];
    }
}

- (void)searchHadNoResults:(NSNotification*)argNotification
{
    NSInteger searchCategory = [[[argNotification userInfo] objectForKey:@"STASearchCategory"] integerValue];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastSearchCategoryKey] integerValue] == searchCategory)
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STASearchStateNoResults] forKey:STADefaultsLastSearchStateKey];
        [self updateSearchingNotificationViewWithState:STASearchStateNoResults animated:YES];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{        
    if ([controller isEqual:[self searchController]])
    {
        // Updating the results of the search... not what
        
        //NSLog(@"Updating records for search controller");
    }
    else // Results Controller
    {
        if ([self currentMode] == STADisplayModeList && [[self listPriceTierControl] selectedSegmentIndex] == 1)
        {
            NSPredicate *pricePredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"priceTier == 0"]];
            NSArray *priceFilteredApps = [[[self resultsController] fetchedObjects] filteredArrayUsingPredicate:pricePredicate];
            [self setAppsDisplayArray:priceFilteredApps];
        }
        else
        {
            [self setAppsDisplayArray:[[self resultsController] fetchedObjects]];
            if ([self currentMode] == STADisplayModeSearch)// and the search is the appropriate searchCategory....?
            {
                // make sure that 
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STASearchStateHasResults] forKey:STADefaultsLastSearchStateKey];
                [self updateSearchingNotificationViewWithState:STASearchStateHasResults animated:YES];
            }
                
        }
    
        NSManagedObject *changedObject = (NSManagedObject*)anObject;
        NSInteger indexOfChangedObject = [[self appsDisplayArray] indexOfObject:changedObject];
    
        if (indexOfChangedObject != NSNotFound)
        {        
            NSInteger currentRow = [[self galleryView] currentRow];
            NSInteger minimumVisibleRow = currentRow - 1;
            NSInteger maximumVisibleRow = currentRow + 1;
        
            if (indexOfChangedObject >= minimumVisibleRow && indexOfChangedObject <= maximumVisibleRow)
                [[self galleryView] reloadData];
        }

        [self updateDownloads];
    }
}

#pragma mark - Download Notification

- (void)screenshotDownloadCompleted:(NSString*)argScreenshotURLString
{
    NSArray *visibleRows = [[self galleryView] visibleCells];
    for (GVGalleryViewCell *cell in visibleRows)
    {
        NSInteger cellRow = [cell row];
        if (cellRow < [self numberOfRowsInGalleryView:[self galleryView]] - 1)
        {
            UIImageView *screenshotImageView = (UIImageView*)[cell viewWithTag:STAScreenshotImageViewTag];
            if (![screenshotImageView image])
            {
                //NSManagedObject *displayIndex = [[self resultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:cellRow inSection:0]];
                NSManagedObject *displayIndex = [[self appsDisplayArray] objectAtIndex:cellRow];
                if ([argScreenshotURLString isEqualToString:[displayIndex valueForKey:STADisplayIndexAttributeScreenshotURL]])
                {
                    [[self galleryView] reloadData];
                    break;
                }
            }
        }
    }
}

#pragma mark - Evaluate current state

- (void)rowChanged
{    
    [self updateDownloads];
}

- (void)updateDownloads
{
    [[self delegate] updateLastPosition:[self positionOfCurrentRow]];
    if ([self currentMode] != STADisplayModeSearch)
        [self updateListDownloads];
    [self updateImageDownloads];
}

- (void)updateListDownloads
{
    NSInteger currentRow = [[self galleryView] currentRow];
    
    // Gather data for new list download
    Size currentListDownloadsCount = CFDictionaryGetCount([[self delegate] currentListDownloadConnections]);
    CFTypeRef *listDownloadDictsArray = (CFTypeRef*)malloc(currentListDownloadsCount * sizeof(CFTypeRef));
    CFDictionaryGetKeysAndValues([[self delegate] currentListDownloadConnections], NULL, (const void**)listDownloadDictsArray);
    const void **listDownloadDicts = (const void **)listDownloadDictsArray;
        
    NSMutableArray *urlStringsOfCurrentlyDownloadingLists = [NSMutableArray array];
        
    for (int listIndex = 0; listIndex < currentListDownloadsCount; listIndex++)
    {
        NSDictionary *listDownloadDict = listDownloadDicts[listIndex];
        [urlStringsOfCurrentlyDownloadingLists addObject:[listDownloadDict objectForKey:STAConnectionURLStringKey]];
    }
        
    free(listDownloadDictsArray);
        
    NSString *storeCountryCode = [[NSUserDefaults standardUserDefaults] objectForKey:STADefaultsAppStoreCountryKey];
        
    enum STACategory category = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastCategoryKey] integerValue];
        
    NSString *deviceString;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        deviceString = @"pad";
    else
        deviceString = @"phone";
        
    NSString *priceTier;
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastListPriceTierKey] integerValue] == STAPriceTierAll)
        priceTier = @"all";
    else
        priceTier = @"free";
        
    NSString *listDownloadURLString = [NSString stringWithFormat:@"http://list.seetheapp.com/list?cat=%d&country=%@&price=%@&device=%@", category, storeCountryCode, priceTier, deviceString];
    
    NSInteger numberOfIndicies = [[self appsDisplayArray] count];
    
    NSInteger maxIndexForListDownload = numberOfIndicies - 20;
    
    if (currentRow > maxIndexForListDownload || numberOfIndicies == 0)
    {
        if ([urlStringsOfCurrentlyDownloadingLists containsObject:listDownloadURLString] == NO)
        {
            if ([[[self delegate] pendingListDownloadConnections] containsObject:listDownloadURLString] == YES)
            {
                NSUInteger index = [[[self delegate] pendingListDownloadConnections] indexOfObject:listDownloadURLString];
                if (index > 0)
                    [[[self delegate] pendingListDownloadConnections] exchangeObjectAtIndex:index withObjectAtIndex:0];
            }
            else
                [[[self delegate] pendingListDownloadConnections] insertObject:listDownloadURLString atIndex:0];
        }
        if ([[self appsDisplayArray] count] == 0)
            return;
    }
}

- (void)updateImageDownloads
{
    
    //NSLog(@"Updating Image Downloads... Current Mode : %d", [self currentMode]);
    
    NSInteger currentRow = [[self galleryView] currentRow];

    NSMutableArray *newPendingImageDownloads = [NSMutableArray array];
    
    NSInteger nextBackwardIndex = -1;
    NSInteger nextForwardIndex = 1;
    
    Size currentImageDownloadsCount = CFDictionaryGetCount([[self delegate] currentImageDownloadConnections]);
    CFTypeRef *imageDownloadDictsArray = (CFTypeRef*)malloc(currentImageDownloadsCount * sizeof(CFTypeRef));
    CFDictionaryGetKeysAndValues([[self delegate] currentImageDownloadConnections], NULL, (const void**)imageDownloadDictsArray);
    const void **imageDownloadDicts = (const void **)imageDownloadDictsArray;
    
    NSMutableArray *urlStringsOfCurrentlyDownloadingImages = [NSMutableArray array];
    
    for (int i = 0; i < currentImageDownloadsCount; i++)
    {
        NSDictionary *downloadDict = imageDownloadDicts[i];
        [urlStringsOfCurrentlyDownloadingImages addObject:[downloadDict objectForKey:STAConnectionURLStringKey]];
    }
    
    free(imageDownloadDictsArray);
    
    for (int rowCounter = 0; rowCounter < 20; rowCounter++)
    {        
        if (rowCounter == 0)
        {
            if (currentRow < [[self appsDisplayArray] count])  // Do not attempt to create a download for the placeholder row
            {
                //NSManagedObject *displayIndex = [[self resultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:0]];
                NSManagedObject *displayIndex = [[self appsDisplayArray] objectAtIndex:currentRow];
                NSString *appScreenshotURLString = [displayIndex valueForKey:STADisplayIndexAttributeScreenshotURL];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:[[self delegate] filePathOfImageDataForURLString:appScreenshotURLString]] == NO)
                    if ([urlStringsOfCurrentlyDownloadingImages containsObject:appScreenshotURLString] == NO)
                        [newPendingImageDownloads addObject:appScreenshotURLString];
            }
        }
        else if (rowCounter % 3 == 0)
        {
            if ((currentRow + nextBackwardIndex) >= 0 && currentRow + (nextBackwardIndex) < [[self appsDisplayArray] count])
            {
                //NSManagedObject *displayIndex = [[self resultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:(currentRow + nextBackwardIndex) inSection:0]];
                NSManagedObject *displayIndex = [[self appsDisplayArray] objectAtIndex:(currentRow + nextBackwardIndex)];
                NSString *appScreenshotURLString = [displayIndex valueForKey:STADisplayIndexAttributeScreenshotURL];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:[[self delegate] filePathOfImageDataForURLString:appScreenshotURLString]] == NO)
                    if ([urlStringsOfCurrentlyDownloadingImages containsObject:appScreenshotURLString] == NO)
                        [newPendingImageDownloads addObject:appScreenshotURLString];
                
                nextBackwardIndex--;
            }
        }
        else
        {
            if ((currentRow + nextForwardIndex) < [[self appsDisplayArray] count])
            {
                //NSManagedObject *displayIndex = [[self resultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:(currentRow + nextForwardIndex) inSection:0]];
                NSManagedObject *displayIndex = [[self appsDisplayArray] objectAtIndex:(currentRow + nextForwardIndex)];
                NSString *appScreenshotURLString = [displayIndex valueForKey:STADisplayIndexAttributeScreenshotURL];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:[[self delegate] filePathOfImageDataForURLString:appScreenshotURLString]] == NO)
                    if ([urlStringsOfCurrentlyDownloadingImages containsObject:appScreenshotURLString] == NO)
                        [newPendingImageDownloads addObject:appScreenshotURLString];
                
                nextForwardIndex++;
            }
        }
    }
    
    [[[self delegate] pendingImageDownloadConnections] removeAllObjects];
    [[[self delegate] pendingImageDownloadConnections] addObjectsFromArray:newPendingImageDownloads];
    
    #ifdef LOG_UpdateDownloadsResults
        NSLog(@"Updated downloads - Pending Image Downloads: %d Pending List Downloads: %d", [[[self delegate] pendingImageDownloadConnections] count], [[[self delegate] pendingListDownloadConnections] count]);
    #endif
    
    [[self delegate] checkPendingConnections];
}

#pragma mark - GVGalleryViewDataSource Methods

- (NSInteger)numberOfRowsInGalleryView:(GVGalleryView *)argGalleryView
{    
    if ([self currentMode] == STADisplayModeSearch)
        return [[self appsDisplayArray] count];
    return [[self appsDisplayArray] count] + 1;
}

- (UIView*)headerViewForGalleryView:(GVGalleryView *)argGalleryView
{
    UIImageView *headerView;
    UIImage *headerFooterImage;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        headerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 768.0f, 960.0f)] autorelease];
        headerFooterImage = [UIImage imageNamed:@"STACorkBackgroundHD"];
    }
    else
    {
        headerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)] autorelease];
        headerFooterImage = [UIImage imageNamed:@"STACorkBackground"];
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
        footerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 768.0f, 960.0f)] autorelease];
        headerFooterImage = [UIImage imageNamed:@"STACorkBackgroundHD"];
    }
    else
    {
        footerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)] autorelease];
        headerFooterImage = [UIImage imageNamed:@"STACorkBackground"];
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
            cell = [[[GVGalleryViewCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 652.0f, 960.0f)] autorelease];
        else
            cell = [[[GVGalleryViewCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 416.0f)] autorelease];
        
        [cell setTag:kGVGalleryViewCell];
                
        // Background View
        
        UIImageView *backgroundImageView;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 652.0f, 960.0f)];
        else
            backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 416.0f)];
        [backgroundImageView setImage:[self cellBackgroundImage]];
        [cell addSubview:backgroundImageView];
        [backgroundImageView release];
        
        // AppStore Button
        
        STAAppStoreButton *appStoreButton = [[STAAppStoreButton alloc] init];
        [appStoreButton addTarget:self action:@selector(appStoreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:appStoreButton];
        [appStoreButton release];
        
        // Screenshot Image View
        
        UIImageView *screenshotImageView;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            screenshotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(53.0f, 72.0f, 546.0f, 728.0f)];
        else
            screenshotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(26.0f, 28.0f, 208.0f, 315.0f)];
        [screenshotImageView setTag:STAScreenshotImageViewTag];
        [screenshotImageView setContentMode:UIViewContentModeScaleAspectFit];
        [screenshotImageView setUserInteractionEnabled:YES];        
        [cell addSubview:screenshotImageView];
        [screenshotImageView release];    
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenshotTapped:)];
        [screenshotImageView addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        
        // Activity Indicator View
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [activityIndicatorView setCenter:CGPointMake(326.0f, 420.0f)];
        else
            [activityIndicatorView setCenter:CGPointMake(130.0f, 176.0f)];
        [activityIndicatorView setTag:STAActivityIndicatorViewTag];
        [cell addSubview:activityIndicatorView];
        [activityIndicatorView release];
        
        // Error Icon Image View
        
        UIImageView *errorIconImageView;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            errorIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(307.0f, 400.0f, 38.0f, 38.0f)];
        else
            errorIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(111.0f, 157.0f, 38.0f, 38.0f)];
        [errorIconImageView setImage:[self errorIconImage]];
        [errorIconImageView setTag:STAErrorIconImageViewTag];
        [cell addSubview:errorIconImageView];
        [errorIconImageView release];
        
        // No Connection Label
        
        UILabel *statusLabel;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 442.0f, 532.0f, 40.0f)];
        else
            statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 195.0f, 200.0f, 24.0f)];
        [statusLabel setTag:STAStatusLabelTag];
        [statusLabel setBackgroundColor:[UIColor clearColor]];
        [statusLabel setOpaque:NO];
        [statusLabel setTextColor:[UIColor whiteColor]];
        [statusLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [statusLabel setAdjustsFontSizeToFitWidth:YES];
        [statusLabel setTextAlignment:UITextAlignmentCenter];
        [cell addSubview:statusLabel];
        [statusLabel release];        
        
        // Pin Image View
        
        UIImageView *pinImageView;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            pinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(290.0, 12.0f, 72.0f, 72.0f)];
        else
            pinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(111.5, 2.0f, 37.0f, 36.0f)];
        [pinImageView setImage:[self pinImage]];
        [cell addSubview:pinImageView];
        [pinImageView release];
    }
    
    [cell setRow:argRow];
    
    UIImageView *screenshotImageView = (UIImageView*)[cell viewWithTag:STAScreenshotImageViewTag];
    
    UIImageView *errorIconImageView = (UIImageView*)[cell viewWithTag:STAErrorIconImageViewTag];
    
    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView*)[cell viewWithTag:STAActivityIndicatorViewTag];
    
    UILabel *statusLabel = (UILabel*)[cell viewWithTag:STAStatusLabelTag];
    [statusLabel setText:@""];
    
    STAAppStoreButton *appStoreButton = (STAAppStoreButton*)[cell viewWithTag:STAAppStoreButtonTag];
    
    BOOL japaneseLanguage = NO;
    NSString *preferredLanguageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([[preferredLanguageCode substringToIndex:2] isEqualToString:@"ja"])
        japaneseLanguage = YES;
    
    if (japaneseLanguage)
        [appStoreButton setAppStoreLabelsUpsideDown];
    else
        [appStoreButton setAppStoreLabelsNormal];
    
    [appStoreButton setAppStoreLabelText:NSLocalizedString(@"App Store", @"App Store")];
    [appStoreButton setAvailableLabelText:NSLocalizedString(@"Available on the", @"Available on the")];
    
    NSInteger lastRowIndex = [self numberOfRowsInGalleryView:argGalleryView] - 1;
    
    if (argRow == lastRowIndex && [self currentMode] != STADisplayModeSearch)
    {
        // Placeholder Row
        [screenshotImageView setImage:nil];
    }
    else
    {
        NSManagedObject *displayIndex = [[self appsDisplayArray] objectAtIndex:argRow];
        if (displayIndex)
        {
            NSString *screenshotURLString = [displayIndex valueForKey:STADisplayIndexAttributeScreenshotURL];
            STAScreenshotImage *screenshotImage = [self cachedImageForURLString:screenshotURLString];
            if (!screenshotImage)
            {
                NSString *appScreenshotDataPath = [[self delegate] filePathOfImageDataForURLString:screenshotURLString];
                if ([[NSFileManager defaultManager] fileExistsAtPath:appScreenshotDataPath])
                {
                    NSData *imageData = [[NSData alloc] initWithContentsOfFile:appScreenshotDataPath];
                    screenshotImage = [[STAScreenshotImage alloc] initWithData:imageData];
                    if (screenshotImage)
                    {
                        if ([screenshotImage size].width > [screenshotImage size].height)
                        {
                            STAScreenshotImage *reorientedScreenshotImage = [[STAScreenshotImage alloc] initWithCGImage:[screenshotImage CGImage] scale:1.0f orientation:UIImageOrientationRight];
                            [screenshotImage release];
                            screenshotImage = reorientedScreenshotImage;
                        }
                        [self cacheImage:screenshotImage forURLString:screenshotURLString];
                    }
                    [screenshotImageView setImage:screenshotImage];
                    [imageData release];
                    [screenshotImage release];
                }
                else
                    [screenshotImageView setImage:nil];
            }
            else
                [screenshotImageView setImage:screenshotImage];
        }
    }
    
    if (![screenshotImageView image])
    {
        [appStoreButton setEnabled:NO];
        
        if ([[self delegate] hasNetworkConnection])
        {
            [activityIndicatorView startAnimating];
            [errorIconImageView setHidden:YES];
            [statusLabel setHidden:NO];
            [statusLabel setText:NSLocalizedString(@"Loading", @"Loading")];
        }
        else
        {
            [activityIndicatorView stopAnimating];
            [errorIconImageView setHidden:NO];
            [statusLabel setHidden:NO];
            [statusLabel setText:NSLocalizedString(@"Unable to connect", @"Unable to connect")];
        }
    }
    else
    {
        [activityIndicatorView stopAnimating];
        [errorIconImageView setHidden:YES];
        [statusLabel setHidden:YES];
        [appStoreButton setEnabled:YES];
    }
    
    return cell;
}

#pragma mark - PriceTier Changed Method

- (void)listPriceTierDidChange
{
    //NSLog(@"Price Tier Changed");
    
    NSInteger priceTierIndex = [[self listPriceTierControl] selectedSegmentIndex];
    
    if (priceTierIndex == 0)
    {
        [self updateResultsForPriceTier:STAPriceTierAll];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STAPriceTierAll] forKey:STADefaultsLastListPriceTierKey];
    }
    else
    {
        [self updateResultsForPriceTier:STAPriceTierFree];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:STAPriceTierFree] forKey:STADefaultsLastListPriceTierKey];
    }
    
    [[self galleryView] reloadData];
}

#pragma mark - Position

- (NSInteger)positionOfCurrentRow
{
    if ([[self appsDisplayArray] count] == 0)
        return 0;
    NSInteger currentRow = [[self galleryView] currentRow];
    NSManagedObject *currentObject;
    if (currentRow >= [[self appsDisplayArray] count])
        currentObject = [[self appsDisplayArray] lastObject];
    else
        currentObject = [[self appsDisplayArray] objectAtIndex:[[self galleryView] currentRow]];
    return [[currentObject valueForKey:STADisplayIndexAttributePositionIndex] integerValue];
}

#pragma mark - Display Methods

- (void)displayMode:(enum STADisplayMode)argDisplayMode
{
    if (argDisplayMode == STADisplayModeBrowse)
    {
        if (searchBottomToolbar_gv)
            [searchBottomToolbar_gv removeFromSuperview];
        [[self navigationItem] setRightBarButtonItem:nil];
        [[self searchingNotificationView] setHidden:YES];
        return;
    }

    if (argDisplayMode == STADisplayModeList)
    {
        if (searchBottomToolbar_gv)
            [searchBottomToolbar_gv removeFromSuperview];
        UIBarButtonItem *listPriceControl = [[UIBarButtonItem alloc] initWithCustomView:[self listPriceTierControl]];
        [[self navigationItem] setRightBarButtonItem:listPriceControl];
        [[self listPriceTierControl] setSelectedSegmentIndex:0];
        [listPriceControl release];
        [[self searchingNotificationView] setHidden:YES];
        return;
    }
    
    if (argDisplayMode == STADisplayModeSearch)
    {
        UIBarButtonItem *searchBar = [[UIBarButtonItem alloc] initWithCustomView:[self searchBar]];
        [[self navigationItem] setRightBarButtonItem:searchBar];
        [self setTitle:@""];
        // set the center point of the searchbottom toolbar so it starts hidden...
        [[self view] addSubview:[self searchBottomToolbar]];
        
        // Restore the state of the SearchPriceTier
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastSearchPriceTierKey] integerValue] == STAPriceTierAll)
            [[self searchPriceTierControl] setSelectedSegmentIndex:0];
        else
            [[self searchPriceTierControl] setSelectedSegmentIndex:1];
        
        // Restore the state of the SearchBar
        NSString *lastSearchTerm = [[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastSearchTermKey];
        if ([lastSearchTerm length] > 0)
            [[self searchBar] setText:lastSearchTerm];
         
         //[[self view] insertSubview:<#(UIView *)#> belowSubview:<#(UIView *)#>]
                
        [searchBar release];
        return;
    }
}

- (void)displayCategory:(enum STACategory)argCategory forAppStoreCountryCode:(NSString*)argCountryCode
{
    //NSLog(@"Display Category: %d", argCategory);
    
    if (argCategory == STACategoryBrowse)
        [self setCurrentMode:STADisplayModeBrowse];
    else if (argCategory == STACategorySearchResult || argCategory >= 10000)
        [self setCurrentMode:STADisplayModeSearch];
    else
        [self setCurrentMode:STADisplayModeList];
    
    // Reset the controllers
    [self setResultsController:nil];
    [self setSearchController:nil];
    
    // Context
    NSManagedObjectContext *context = [[self delegate] managedObjectContext];
    if (!context)
        return;
    
    // Fetch Request
    NSFetchRequest *displayIndexesFetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity Description
    NSEntityDescription *displayIndexEntityDescription = [NSEntityDescription entityForName:@"DisplayIndex" inManagedObjectContext:context];
    [displayIndexesFetchRequest setEntity:displayIndexEntityDescription];
    
    // Predicate
    NSString *predicateString = [NSString stringWithFormat:@"positionIndex >= 0 AND category == %d AND country like '%@'", argCategory, argCountryCode];
    
    NSPredicate *displayIndexesForAllAppsCategory = [NSPredicate predicateWithFormat:predicateString];
    [displayIndexesFetchRequest setPredicate:displayIndexesForAllAppsCategory];
    
    // Sort Descriptors
    NSSortDescriptor *positionIndexSortDescriptor = [[NSSortDescriptor alloc] initWithKey:STADisplayIndexAttributePositionIndex ascending:YES];
    NSArray *sortDescriptorsArray = [NSArray arrayWithObject:positionIndexSortDescriptor];
    [displayIndexesFetchRequest setSortDescriptors:sortDescriptorsArray];
    [positionIndexSortDescriptor release];
    
    // Fetched Results Controller
    NSFetchedResultsController *tempFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:displayIndexesFetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    [self setResultsController:tempFetchedResultsController];
    [[self resultsController] setDelegate:self];
    [displayIndexesFetchRequest release];
    [tempFetchedResultsController release];
    
    NSError *fetchError = nil;
    
    if([[self resultsController] performFetch:&fetchError] == NO)
    {
        NSLog(@"Results Fetch Error: %@", [fetchError localizedDescription]);
        // Attempt a refetch.....?
        // log the error....
    }
    
    [self setAppsDisplayArray:[[self resultsController] fetchedObjects]];   
    
    [[self galleryView] reloadData];
    
    if ([self currentMode] == STADisplayModeSearch)
    {
        // Fetch Request
        NSFetchRequest *searchRecordsFetchRequest = [[NSFetchRequest alloc] init];
        
        // Entity Description
        NSEntityDescription *searchRecordEntityDescription = [NSEntityDescription entityForName:@"SearchRecord" inManagedObjectContext:context];
        [searchRecordsFetchRequest setEntity:searchRecordEntityDescription];
        
        // Predicate
        NSString *searchRecordsPredicateString = [NSString stringWithFormat:@"country like '%@'", argCountryCode];
        NSPredicate *searchRecordsPredicate = [NSPredicate predicateWithFormat:searchRecordsPredicateString];
        [searchRecordsFetchRequest setPredicate:searchRecordsPredicate];
        
        // Sort Descriptor
        NSSortDescriptor *searchDateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:STASearchRecordAttributeSearchCategory ascending:YES];
        NSArray *searchRecordsSortDescriptorsArray = [NSArray arrayWithObject:searchDateSortDescriptor];
        [searchRecordsFetchRequest setSortDescriptors:searchRecordsSortDescriptorsArray];
        [searchDateSortDescriptor release];
        
        // Search Records Controller
        NSFetchedResultsController *tempSearchRecordsController = [[NSFetchedResultsController alloc] initWithFetchRequest:searchRecordsFetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        [self setSearchController:tempSearchRecordsController];
        [[self searchController] setDelegate:self];
        [searchRecordsFetchRequest release];
        [tempSearchRecordsController release];
        
        NSError *searchFetchError = nil;
        
        if([[self searchController] performFetch:&searchFetchError] == NO)
        {
            NSLog(@"Search Fetch Error: %@", [searchFetchError localizedDescription]);
            // Attempt a refetch.....?
            // log the error....
        }
        
        
        enum STASearchState lastSearchState = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastSearchStateKey] integerValue];
        if (lastSearchState > STASearchStateNone)
            [self updateSearchingNotificationViewWithState:lastSearchState animated:YES];
        // TODO: Restore the last search position....
    }
}

- (void)displayPosition:(NSInteger)argPosition forPriceTier:(enum STAPriceTier)argPriceTier
{
    //NSLog(@"Display Position / PriceTier: Position: %d", argPosition);
    if ([self currentMode] == STADisplayModeList && argPriceTier == STAPriceTierFree)
    {
        [[self listPriceTierControl] setSelectedSegmentIndex:1];
        
        NSPredicate *pricePredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"priceTier == 0"]];
        NSArray *priceFilteredApps = [[[self resultsController] fetchedObjects] filteredArrayUsingPredicate:pricePredicate];
        [self setAppsDisplayArray:priceFilteredApps];
        
        NSManagedObject *appToShow = nil;
        if ([[self appsDisplayArray] count] > 0)
        {
            appToShow = [[[self resultsController] fetchedObjects] objectAtIndex:argPosition];
        
            if ([[appToShow valueForKey:STADisplayIndexAttributePriceTier] integerValue] == 1)
            {            
                appToShow = nil;
                NSInteger indexToTest = argPosition;
                while (!appToShow && indexToTest >= 0)
                {
                    NSManagedObject *objectToTest = [[[self resultsController] fetchedObjects] objectAtIndex:indexToTest];
                    if ([[objectToTest valueForKey:STADisplayIndexAttributePriceTier] integerValue] == 0)
                        appToShow = objectToTest;
                    indexToTest--;
                }
            
                if (!appToShow)
                {
                    NSInteger forwardIndexToTest = argPosition + 1;
                    while (!appToShow && forwardIndexToTest < [[[self resultsController] fetchedObjects] count])
                    {
                        NSManagedObject *forwardObjectToTest = [[[self resultsController] fetchedObjects] objectAtIndex:forwardIndexToTest];
                        if ([[forwardObjectToTest valueForKey:STADisplayIndexAttributePriceTier] integerValue] == 0)
                            appToShow = forwardObjectToTest;
                        forwardIndexToTest++;
                    }
                }
            }
        }
        
        NSInteger rowToDisplay = 0;
        if (appToShow)
            rowToDisplay = [[self appsDisplayArray] indexOfObject:appToShow];
        [[self galleryView] displayRow:rowToDisplay animated:NO];
    }
    else if ([self currentMode] == STADisplayModeList || [self currentMode] == STADisplayModeBrowse)
    {
        [[self listPriceTierControl] setSelectedSegmentIndex:0];
        [self setAppsDisplayArray:[[self resultsController] fetchedObjects]];
        [[self galleryView] displayRow:argPosition animated:NO];
    }
    else
    {
        // Search....
        if (argPriceTier == STAPriceTierAll)
            [[self searchPriceTierControl] setSelectedSegmentIndex:0];
        else
            [[self searchPriceTierControl] setSelectedSegmentIndex:1];
        
        [self setAppsDisplayArray:[[self resultsController] fetchedObjects]];
        [[self galleryView] displayRow:argPosition animated:NO];
    }
}

#pragma mark - AppStoreButton

- (void)appStoreButtonTapped:(id)argSender
{
    UIButton *appStoreButton = (UIButton*)argSender;
    GVGalleryViewCell *cell = (GVGalleryViewCell*)[appStoreButton superview];
    NSInteger row = [cell row];
    
    NSURL *appURL = nil;
    NSString *appIDString = nil;
    
    @try 
    {
        //NSManagedObject *displayIndex = [[self resultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        NSManagedObject *displayIndex = [[self appsDisplayArray] objectAtIndex:row];
        
        appURL = [NSURL URLWithString:[displayIndex valueForKey:STADisplayIndexAttributeAppURL]];
        appIDString = [NSString stringWithFormat:@"%d", [[displayIndex valueForKey:STADisplayIndexAttributeAppID] integerValue]];
        
        #ifdef LOG_SelectedAppDetails
                NSLog(@"AppID: %@", appIDString);
                NSLog(@"App URL: %@", appURL);
        #endif
        
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:appIDString];
        [[UIApplication sharedApplication] openURL:appURL];
    }
    @catch (NSException *exception) 
    {
        NSLog(@"Attempting to access an app not in fetched objects for row: %d", row);
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"AppSelectedNotInFetchedObjects" attributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:row] forKey:@"Row"]];
    }
}

#pragma mark - Screenshot Tapped

- (void)screenshotTapped:(id)argSender
{    
    UIGestureRecognizer *gestureRecognizer = (UIGestureRecognizer*)argSender;
    UIImageView *screenshotImageView = (UIImageView*)[gestureRecognizer view];
    GVGalleryViewCell *cell = (GVGalleryViewCell*)[screenshotImageView superview];
    NSInteger row = [cell row];
    
    @try 
    {
        NSManagedObject *displayIndex = [[self appsDisplayArray] objectAtIndex:row];
        if (displayIndex)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"View on the App Store?", @"View on the App Store?") message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cance;") otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
            [alertView setTag:row];
            [alertView show];
            [alertView release];
        }
    }
    @catch (NSException *exception) 
    {
        NSLog(@"Attempting to access an app not in fetched objects for row: %d", row);
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"AppSelectedNotInFetchedObjects" attributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:row] forKey:@"Row"]];
    }
}

#pragma mark - UIAlertView Methods

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSManagedObject *displayIndex = [[self appsDisplayArray] objectAtIndex:[alertView tag]];
            
        NSURL *appURL = [NSURL URLWithString:[displayIndex valueForKey:STADisplayIndexAttributeAppURL]];
        NSString *appIDString = [NSString stringWithFormat:@"%d", [[displayIndex valueForKey:STADisplayIndexAttributeAppID] integerValue]];
            
        #ifdef LOG_SelectedAppDetails
            NSLog(@"AppID: %@", appIDString);
            NSLog(@"App URL: %@", appURL);
        #endif
            
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:appIDString];
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"ScreenshotTapAlertViewDismissed" attributes:[NSDictionary dictionaryWithObject:@"Viewed" forKey:@"Action"]];
        [[UIApplication sharedApplication] openURL:appURL];
    }
    else
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"ScreenshotTapAlertViewDismissed" attributes:[NSDictionary dictionaryWithObject:@"Cancelled" forKey:@"Action"]];
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    [self inactiveSearchAnimation];
    [[self searchBar] resignFirstResponder];
    [[self searchBar] setText:[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastSearchTermKey]];
    return YES;
}

#pragma mark - Localization Methods

- (void)resetText
{
    [[self listPriceTierControl] setTitle:NSLocalizedString(@"All", @"All") forSegmentAtIndex:0];
    [[self listPriceTierControl] setTitle:NSLocalizedString(@"Free", @"Free") forSegmentAtIndex:1];
}

#pragma mark - Results

- (void)updateResultsForPriceTier:(enum STAPriceTier)argPriceTier
{
    enum STAPriceTier currentPriceTier = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsLastListPriceTierKey] integerValue];
 
    NSArray *allListApps = [[self resultsController] fetchedObjects];
    if ([allListApps count] > 0)
    {
        //NSLog(@"ADJUSTING -------------------------");
        if (currentPriceTier == STAPriceTierAll && argPriceTier == STAPriceTierFree)
        {
            NSManagedObject *freeApp = nil;
            NSInteger indexToTest = [[self galleryView] currentRow];
            while (!freeApp && indexToTest >= 0)
            {
                NSManagedObject *objectToTest = [[self appsDisplayArray] objectAtIndex:indexToTest];
                if ([[objectToTest valueForKey:STADisplayIndexAttributePriceTier] integerValue] == 0)
                    freeApp = objectToTest;
                indexToTest--;
            }
            if (!freeApp)
            {
                NSInteger forwardIndexToTest = [[self galleryView] currentRow] + 1;
                while (!freeApp && forwardIndexToTest < [allListApps count])
                {
                    NSManagedObject *forwardObjectToTest = [allListApps objectAtIndex:forwardIndexToTest];
                    if ([[forwardObjectToTest valueForKey:STADisplayIndexAttributePriceTier] integerValue] == 0)
                        freeApp = forwardObjectToTest;
                    forwardIndexToTest++;
                }
            }
                
            NSPredicate *pricePredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"priceTier == 0"]];
            NSArray *priceFilteredApps = [allListApps filteredArrayUsingPredicate:pricePredicate];
            [self setAppsDisplayArray:priceFilteredApps];
                
            if (freeApp)
            {
                NSInteger indexOfFreeApp = [priceFilteredApps indexOfObject:freeApp];
                [[self galleryView] displayRow:indexOfFreeApp animated:NO];
            }
            else
            {
                [[self galleryView] displayRow:0 animated:NO];
            }
        }
        else if (currentPriceTier == STAPriceTierFree && argPriceTier == STAPriceTierAll)
        {
            NSInteger position = [[[[self appsDisplayArray] objectAtIndex:[[self galleryView] currentRow]] valueForKey:STADisplayIndexAttributePositionIndex] integerValue];
            [self setAppsDisplayArray:allListApps];
            [[self galleryView] displayRow:position animated:NO];
        }
        else if (argPriceTier == STAPriceTierFree)
        {
            NSPredicate *pricePredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"priceTier == 0"]];
            NSArray *priceFilteredApps = [allListApps filteredArrayUsingPredicate:pricePredicate];
            [self setAppsDisplayArray:priceFilteredApps];
        }
        else
        {
            [self setAppsDisplayArray:allListApps];
        }
    }

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
        pinImagePath = [[NSBundle mainBundle] pathForResource:@"STAPinHD" ofType:@"png"];
    else
        pinImagePath = [[NSBundle mainBundle] pathForResource:@"STAPin" ofType:@"png"];
    
    pinImage_gv = [[UIImage alloc] initWithContentsOfFile:pinImagePath];
    
    return pinImage_gv;
}

- (UIImage*)appStoreButtonImage
{
    if (appStoreButtonImage_gv)
        return appStoreButtonImage_gv;
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        appStoreButtonImage_gv = [[UIImage imageNamed:@"STAAppStoreButtonHD"] retain];
    else
        appStoreButtonImage_gv = [[UIImage imageNamed:@"STAAppStoreButton"] retain];
        
    return appStoreButtonImage_gv;
}

- (UIImage*)appStoreButtonHighlightedImage
{
    if (appStoreButtonHighlightedImage_gv)
        return appStoreButtonHighlightedImage_gv;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        appStoreButtonHighlightedImage_gv = [[UIImage imageNamed:@"STAAppStoreButtonHighlightedHD"] retain];
    else
        appStoreButtonHighlightedImage_gv = [[UIImage imageNamed:@"STAAppStoreButtonHighlighted"] retain];
    
    return appStoreButtonHighlightedImage_gv;
}

- (UIImage*)appStoreButtonDisabledImage
{
    if (appStoreButtonDisabledImage_gv)
        return appStoreButtonDisabledImage_gv;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        appStoreButtonDisabledImage_gv = [[UIImage imageNamed:@"STAAppStoreButtonDisabledHD"] retain];
    else
        appStoreButtonDisabledImage_gv = [[UIImage imageNamed:@"STAAppStoreButtonDisabled"] retain];
    
    return appStoreButtonDisabledImage_gv;
}

- (UIImage*)errorIconImage
{
    if (errorIconImage_gv)
        return errorIconImage_gv;
    
    errorIconImage_gv = [[UIImage imageNamed:@"STAErrorIcon"] retain];
    return errorIconImage_gv;
}

#pragma mark - Image Cache

- (void)cacheImage:(STAScreenshotImage*)argImage forURLString:(NSString*)argURLString
{        
    [[self imageCache] setObject:argImage forKey:argURLString];
    
    #ifdef LOG_InMemoryCacheCounts
        NSLog(@"Cached Image, count: %d", [[self imageCache] count]);
    #endif
    
    if ([[self imageCache] count] > kGVNumberOfScreenshotsToKeepInMemory)
    {        
        NSArray *screenshotKeysByAccessDate = [[self imageCache] keysSortedByValueUsingComparator:^(id obj1, id obj2) 
                                                {
                                                    NSDate *date1 = [obj1 valueForKeyPath:@"lastAccessedDate"];
                                                    NSDate *date2 = [obj2 valueForKeyPath:@"lastAccessedDate"];
                                                    return (NSComparisonResult)[date1 compare:date2];
                                                }];
        
        NSInteger screenshotsToRemove = [[self imageCache] count] - kGVNumberOfScreenshotsToKeepInMemory;
        
        for (int screenshotRemovalCounter = 0; screenshotRemovalCounter < screenshotsToRemove; screenshotRemovalCounter++)
        {
            NSString *keyToRemove = [screenshotKeysByAccessDate objectAtIndex:screenshotRemovalCounter];
            [[self imageCache] removeObjectForKey:keyToRemove];
        }
        
        #ifdef LOG_InMemoryCacheCounts
            NSLog(@"Removed %d screenshots, count: %d", screenshotsToRemove, [[self imageCache] count]);
        #endif
    }
}

- (STAScreenshotImage*)cachedImageForURLString:(NSString*)argURLString
{
    STAScreenshotImage *image = [[self imageCache] objectForKey:argURLString];
    if (image)
        [image setLastAccessedDate:[NSDate date]];
    
    return image;
}

- (NSMutableDictionary*)imageCache
{
    if (imageCache_gv)
        return imageCache_gv;
    imageCache_gv = [[NSMutableDictionary alloc] init];
    return imageCache_gv;
}

#pragma mark - Navigation Bar Items

- (UISegmentedControl*)listPriceTierControl
{
    if (listPriceTierControl_gv)
        return listPriceTierControl_gv;
    NSArray *itemsArray = [NSArray arrayWithObjects:NSLocalizedString(@"All", @"All"), NSLocalizedString(@"Free", @"Free"), nil];
    listPriceTierControl_gv = [[UISegmentedControl alloc] initWithItems:itemsArray];
    [listPriceTierControl_gv setSegmentedControlStyle:UISegmentedControlStyleBar];
    [listPriceTierControl_gv setSelectedSegmentIndex:0];
    //[listPriceTierControl_gv setTintColor:[UIColor colorWithRed:0.90f green:0.62f blue:0.27 alpha:1.0f]];
    [listPriceTierControl_gv setTintColor:[UIColor colorWithRed:0.89f green:0.66f blue:0.34f alpha:1.0f]];
    [listPriceTierControl_gv addTarget:self action:@selector(listPriceTierDidChange) forControlEvents:UIControlEventValueChanged];
    return listPriceTierControl_gv;
}

- (STASearchBar*)searchBar
{
    if (searchBar_gv)
        return searchBar_gv;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        searchBar_gv = [[STASearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 240.0f, 44.0f)];
    else
        searchBar_gv = [[STASearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 240.0f, 44.0f)];
    [searchBar_gv setDelegate:self];
    [searchBar_gv setPlaceholder:NSLocalizedString(@"Search", @"Search")];
    return searchBar_gv;
}

- (UIToolbar*)searchBottomToolbar
{
    if (searchBottomToolbar_gv)
        return searchBottomToolbar_gv;
    CGRect toolbarFrame;
    float searchPriceControlWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        toolbarFrame = CGRectMake(0.0f, -44.0f, 768.0f, 44.0f);
        searchPriceControlWidth = 240.0f;
    }
    else
    {
        toolbarFrame = CGRectMake(0.0f, -44.0f, 320.0f, 44.0f);
        searchPriceControlWidth = 240.0f;
    }
    searchBottomToolbar_gv = [[UIToolbar alloc] initWithFrame:toolbarFrame];
    [searchBottomToolbar_gv setTintColor:[UIColor colorWithRed:0.89f green:0.66f blue:0.34f alpha:1.0f]];
    // Create Items
    UIBarButtonItem *searchPriceControl = [[UIBarButtonItem alloc] initWithCustomView:[self searchPriceTierControl]];
    [searchPriceControl setWidth:searchPriceControlWidth];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *searchCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(searchCancelButtonTapped)];
    NSArray *items = [NSArray arrayWithObjects:flexibleSpace, searchPriceControl, searchCancelButton, nil];
    // Set Items
    [searchBottomToolbar_gv setItems:items];
    // Clean Up
    [searchPriceControl release];
    [flexibleSpace release];
    [searchCancelButton release];
    // Return toolbar
    return searchBottomToolbar_gv;
}

- (UISegmentedControl*)searchPriceTierControl
{
    if (searchPriceTierControl_gv)
        return searchPriceTierControl_gv;
    NSArray *itemsArray = [NSArray arrayWithObjects:NSLocalizedString(@"All", @"All"), NSLocalizedString(@"Free", @"Free"), nil];
    searchPriceTierControl_gv = [[UISegmentedControl alloc] initWithItems:itemsArray];
    [searchPriceTierControl_gv setSegmentedControlStyle:UISegmentedControlStyleBar];
    [searchPriceTierControl_gv addTarget:self action:@selector(searchPriceTierDidChange) forControlEvents:UIControlEventValueChanged];
    return searchPriceTierControl_gv;
}
   
#pragma mark - Searching Notification View

- (void)updateSearchingNotificationViewWithState:(enum STASearchState)argState animated:(BOOL)argAnimated
{
    if (![self searchingNotificationView])
    {
        CGRect searchingNotificationViewFrame = CGRectMake(100.0f, 148.0f, 120.0f, 120.0f);
        CGPoint iconCenterPoint = CGPointMake(60.0f, 50.0f);
        CGRect searchStatusLabelFrame = CGRectMake(10.0f, 80.0f, 100.0f, 20.0f);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            searchingNotificationViewFrame = CGRectMake(324.0f, 420.0f, 120.0f, 120.0f);
        }
        
        UIView *tempSearchingNotificationView = [[UIView alloc] initWithFrame:searchingNotificationViewFrame];
        [tempSearchingNotificationView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
        [tempSearchingNotificationView setOpaque:NO];
        [[tempSearchingNotificationView layer] setCornerRadius:16.0f];
        [self setSearchingNotificationView:tempSearchingNotificationView];
        [tempSearchingNotificationView release];
        
        UIActivityIndicatorView *tempActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [tempActivityIndicator setTag:STANotificationViewActivityIcon];
        [tempActivityIndicator setCenter:iconCenterPoint];
        [tempSearchingNotificationView addSubview:tempActivityIndicator];
        [tempActivityIndicator release];
                      
        UIImageView *tempErrorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 38.0f, 38.0f)];
        [tempErrorImageView setTag:STANotificationViewErrorIcon];
        [tempErrorImageView setCenter:iconCenterPoint];
        [tempErrorImageView setImage:[self errorIconImage]];
        [tempErrorImageView setBackgroundColor:[UIColor clearColor]];
        [tempErrorImageView setOpaque:NO];
        [tempErrorImageView setHidden:YES];
        [tempSearchingNotificationView addSubview:tempErrorImageView];
        [tempErrorImageView release];
        
        UIImageView *tempNoResultsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 38.0f, 38.0f)];
        [tempNoResultsImageView setTag:STANotificationViewNoResultsIcon];
        [tempNoResultsImageView setCenter:iconCenterPoint];
        [tempNoResultsImageView setImage:[UIImage imageNamed:@"STANoResultsIcon.png"]];
        [tempNoResultsImageView setBackgroundColor:[UIColor clearColor]];
        [tempNoResultsImageView setOpaque:NO];
        [tempNoResultsImageView setHidden:YES];
        [tempSearchingNotificationView addSubview:tempNoResultsImageView];
        [tempNoResultsImageView release];
        
        UILabel *tempSearchStatusLabel = [[UILabel alloc] initWithFrame:searchStatusLabelFrame];
        [tempSearchStatusLabel setTag:STANotificationViewLabel];
        [tempSearchStatusLabel setBackgroundColor:[UIColor clearColor]];
        [tempSearchStatusLabel setOpaque:NO];
        [tempSearchStatusLabel setTextColor:[UIColor whiteColor]];
        [tempSearchStatusLabel setTextAlignment:UITextAlignmentCenter];
        [tempSearchStatusLabel setAdjustsFontSizeToFitWidth:YES];        
        [tempSearchingNotificationView addSubview:tempSearchStatusLabel];
        [tempSearchStatusLabel release];
        
        [[self view] addSubview:[self searchingNotificationView]];
    }
    
    UILabel *searchStatusLabel = (UILabel*)[[self searchingNotificationView] viewWithTag:STANotificationViewLabel];
    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView*)[[self searchingNotificationView] viewWithTag:STANotificationViewActivityIcon];
    UIImageView *errorImageView = (UIImageView*)[[self searchingNotificationView] viewWithTag:STANotificationViewErrorIcon];
    UIImageView *noResultsImageView = (UIImageView*)[[self searchingNotificationView] viewWithTag:STANotificationViewNoResultsIcon];
    
    switch (argState) 
    {
        case STASearchStateNone:
            [[self searchingNotificationView] setHidden:YES];
            [activityIndicatorView stopAnimating];
            [errorImageView setHidden:YES];
            [noResultsImageView setHidden:YES];
            break;
        case STASearchStateInProgress:
            [[self searchingNotificationView] setHidden:NO];
            [searchStatusLabel setText:NSLocalizedString(@"Searching", @"Searching")];
            [activityIndicatorView startAnimating];
            [errorImageView setHidden:YES];
            [noResultsImageView setHidden:YES];
            break;
        case STASearchStateHasResults:
            [[self searchingNotificationView] setHidden:YES];
            [searchStatusLabel setText:@""];
            [activityIndicatorView stopAnimating];
            [errorImageView setHidden:YES];
            [noResultsImageView setHidden:YES];
            break;
        case STASearchStateFailed:
            [[self searchingNotificationView] setHidden:NO];
            [searchStatusLabel setText:NSLocalizedString(@"Search Failed", @"Search Failed")];
            [activityIndicatorView stopAnimating];
            [errorImageView setHidden:NO];
            [noResultsImageView setHidden:YES];
            break;
        case STASearchStateNoResults:
            [[self searchingNotificationView] setHidden:NO];
            [searchStatusLabel setText:NSLocalizedString(@"No Results", @"No Results")];
            [activityIndicatorView stopAnimating];
            [errorImageView setHidden:YES];
            [noResultsImageView setHidden:NO];
            break;
        default:
            break;
    }
}

#pragma mark - Search Mask View

- (UIView*)searchMaskView
{
    if (searchMaskView_gv)
        return searchMaskView_gv;
    searchMaskView_gv = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [searchMaskView_gv setFrame:CGRectMake(0.0f, 0.0f, 768.0f, 960.0f)];
    [searchMaskView_gv setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
    [searchMaskView_gv setOpaque:NO];
    UIGestureRecognizer *allGesturesRecognizer = [[UIGestureRecognizer alloc] init];
    [allGesturesRecognizer setDelegate:self];
    [searchMaskView_gv addGestureRecognizer:allGesturesRecognizer];
    [allGesturesRecognizer release];
    return searchMaskView_gv;
}

#pragma mark - Title Override

- (void)setTitle:(NSString*)argTitle
{
    [super setTitle:argTitle];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:16.0];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        titleView.textColor = [UIColor whiteColor]; // Change to desired color
        
        self.navigationItem.titleView = titleView;
        [titleView release];
    }
    titleView.text = argTitle;
    [titleView sizeToFit];
}

#pragma mark - Property Synthesis

@synthesize delegate;
@synthesize galleryView;
@synthesize appsDisplayArray;
@synthesize resultsController;
@synthesize searchController;
@synthesize currentMode;
@synthesize searchingNotificationView;
@end
