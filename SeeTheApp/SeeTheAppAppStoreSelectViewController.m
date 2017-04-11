//
//  SeeTheAppAppStoreSelectViewController.m
//  SeeTheApp
//
//  Created by goVertex on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SeeTheAppAppStoreSelectViewController.h"

@implementation SeeTheAppAppStoreSelectViewController

- (id)initWithDelegate:(id)argDelegate
{
    if ((self = [super init]))
    {
        [self setDelegate:argDelegate];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView
{
    CGRect viewFrame;
    CGRect toolbarFrame;
    CGRect tableViewFrame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        viewFrame = CGRectMake(0.0f, 0.0f, 768.0f, 960.0f);
        toolbarFrame = CGRectMake(0.0f, 0.0f, 768.0f, 44.0f);
        tableViewFrame = CGRectMake(0.0f, 44.0f, 768.0f, 960.0f);
    }
    else
    {
        viewFrame = CGRectMake(0.0f, 0.0f, 320.0f, 460.0f);
        toolbarFrame = CGRectMake(0.0f, 0.0f, 320.0f, 44.0f);
        tableViewFrame = CGRectMake(0.0f, 44.0f, 320.0f, 416.0f);
    }
        
    UIView *tempView = [[UIView alloc] initWithFrame:viewFrame];
    [self setView:tempView];
    [tempView release];
    
    UIToolbar *tempToolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
    [[self view] addSubview:tempToolbar];
    [tempToolbar release];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped)];
    
    UIBarButtonItem *appStoreTitleLabel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"App Store", @"App Store") style:UIBarButtonItemStylePlain target:nil action:nil];
    [self setAppStoreBarButtonLabel:appStoreTitleLabel];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTapped)];
    
    NSArray *toolbarItems = [NSArray arrayWithObjects:cancelButton, flexibleSpace, appStoreTitleLabel, flexibleSpace, doneButton, nil];
    [tempToolbar setItems:toolbarItems];
    
    [flexibleSpace release];
    [cancelButton release];
    [appStoreTitleLabel release];
    [doneButton release];
    
    UITableView *tempTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    [tempTableView setDelegate:self];
    [tempTableView setDataSource:self];
    [tempTableView setSectionIndexMinimumDisplayRowCount:1];
    [[self view] addSubview:tempTableView];
    [self setAppStoreCountriesTableView:tempTableView];
    [tempTableView release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateActiveAppStore];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setAppStoreBarButtonLabel:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Localization Methods

- (void)resetText
{
    [[self appStoreBarButtonLabel] setTitle:NSLocalizedString(@"App Store", @"App Store")];
}

#pragma mark - Button Actions

- (void)cancelButtonTapped
{
    [[self delegate] dismissSelectViewControllerWithNoChange];
}

- (void)saveButtonTapped
{    
    NSString *currentAppStoreCountry = [[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsAppStoreCountryKey];
    
    NSString *selectedAppStoreCountry = [[[self delegate] appStoreCountryCodes] objectAtIndex:[self selectedCountryIndex]];
    
    if ([currentAppStoreCountry isEqualToString:selectedAppStoreCountry])
        [[self delegate] dismissSelectViewControllerWithNoChange];
    else
        [[self delegate] dismissSelectViewControllerWithNewAppStore:selectedAppStoreCountry];
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView*)argTableView didSelectRowAtIndexPath:(NSIndexPath*)argIndexPath
{    
    UITableViewCell *previousCell = [argTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self selectedCountryIndex] inSection:0]];
    [previousCell setAccessoryType:UITableViewCellAccessoryNone];
    
    UITableViewCell *newCell = [argTableView cellForRowAtIndexPath:argIndexPath];
    [newCell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    [argTableView deselectRowAtIndexPath:argIndexPath animated:YES];
    
    [self setSelectedCountryIndex:[argIndexPath row]];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)argTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)argTableView numberOfRowsInSection:(NSInteger)argSection
{
    return [[[self delegate] appStoreCountryTitles] count];
}

- (UITableViewCell*)tableView:(UITableView*)argTableView cellForRowAtIndexPath:(NSIndexPath*)argIndexPath
{
    static NSString *appStoreSelectionTableViewCellIdentifier = @"AppStoreSelectionTableViewCellIdentifier";
    
    UITableViewCell *cell = [argTableView dequeueReusableCellWithIdentifier:appStoreSelectionTableViewCellIdentifier];
    
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:appStoreSelectionTableViewCellIdentifier] autorelease];
    }
    
    [[cell textLabel] setText:[[[self delegate] appStoreCountryTitles] objectAtIndex:[argIndexPath row]]];
    
    if ([argIndexPath row] == [self selectedCountryIndex])
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}

#pragma mark - Update

- (void)updateActiveAppStore
{
    NSString *currentAppStoreCountryCode = [[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsAppStoreCountryKey];
    NSUInteger indexOfCurrentAppStoreCountryCode = [[[self delegate] appStoreCountryCodes] indexOfObject:currentAppStoreCountryCode];
    NSIndexPath *indexPathForCountryCode = [NSIndexPath indexPathForRow:indexOfCurrentAppStoreCountryCode inSection:0];
    
    [self setSelectedCountryIndex:indexOfCurrentAppStoreCountryCode];
    [[self appStoreCountriesTableView] scrollToRowAtIndexPath:indexPathForCountryCode atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    [[self appStoreCountriesTableView] reloadData];
}

#pragma mark - Properties

@synthesize delegate;
@synthesize appStoreCountriesTableView;
@synthesize selectedCountryIndex;
@synthesize appStoreBarButtonLabel;
@end
