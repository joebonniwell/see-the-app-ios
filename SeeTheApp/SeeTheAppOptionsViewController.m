//
//  SeeTheAppOptionsViewController.m
//  SeeTheApp
//
//  Created by goVertex on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SeeTheAppOptionsViewController.h"

@implementation SeeTheAppOptionsViewController

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
    [[self navigationItem] setTitle:NSLocalizedString(@"Options", @"Options")];
    
    CGRect viewFrame;
    
    CGRect emailOptionButtonFrame;
    CGRect emailLabelFrame;
    CGRect emailButtonFrame;
    float emailLabelFontSizel;
    float emailFontSize;
    
    CGRect appStoreOptionButtonFrame;
    CGRect appStoreLabelFrame;
    CGRect appStoreButtonFrame;
    UIEdgeInsets appStoreButtonEdgeInsets;
    CGRect appStoreInButtonLabelFrame;
    float appStoreLabelFontSize;
    float appStoreButtonFontSize;
    float appStoreButtonCountryFontSize;
    float appStoreButtonCountryMinFontSize;
    
    UIImage *backgroundImage;
    UIImage *optionsMenuButtonImage;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        viewFrame = CGRectMake(0.0f, 0.0f, 768.0f, 960.0f);
        
        emailOptionButtonFrame = CGRectMake(36.0f, 20.0f, 330.0f, 300.0f);
        emailLabelFrame = CGRectMake(60.0f, 54.0f, 284.0f, 160.0f);
        emailButtonFrame = CGRectMake(51.0f, 220.0f, 300.0f, 80.0f);
        emailLabelFontSizel = 20.0f;
        emailFontSize = 20.0f;
        
        appStoreOptionButtonFrame = CGRectMake(402.0f, 20.0f, 330.0f, 300.0f);
        appStoreLabelFrame = CGRectMake(428.0f, 54.0f, 292.0f, 160.0f);
        appStoreButtonFrame = CGRectMake(417.0f, 220.0f, 300.0f, 80.0f);
        appStoreButtonEdgeInsets = UIEdgeInsetsMake(0.0f, -180.0f, 0.0f, 0.0f);
        appStoreInButtonLabelFrame = CGRectMake(110.0f, 24.0f, 176.0f, 30.0f);
        appStoreLabelFontSize = 20.0f;
        appStoreButtonFontSize = 20.0f;
        appStoreButtonCountryFontSize = 20.0f;
        appStoreButtonCountryMinFontSize = 16.0f;
        
        backgroundImage = [UIImage imageNamed:@"STACorkBackgroundHD.png"];
        optionsMenuButtonImage = [UIImage imageNamed:@"STAOptionsMenuButtonHD.png"];
    }
    else
    {
        viewFrame = CGRectMake(0.0f, 0.0f, 320.0f, 416.0f);
        
        emailOptionButtonFrame = CGRectMake(15.0f, 10.0f, 290.0f, 190.0f);
        emailLabelFrame = CGRectMake(32.0f, 46.0f, 256.0f, 76.0f);
        emailButtonFrame = CGRectMake(30.0f, 130.0f, 260.0f, 50.0f);
        emailLabelFontSizel = 16.0f;
        emailFontSize = 16.0f;
        
        appStoreOptionButtonFrame = CGRectMake(15.0f, 210.0f, 290.0f, 190.0f);
        appStoreLabelFrame = CGRectMake(32.0f, 246.0f, 256.0f, 76.0f);
        appStoreButtonFrame = CGRectMake(30.0f, 330.0f, 260.0f, 50.0f);
        appStoreButtonEdgeInsets = UIEdgeInsetsMake(0.0f, -170.0f, 0.0f, 0.0f);
        appStoreInButtonLabelFrame = CGRectMake(90.0f, 10.0f, 160.0f, 30.0f);
        appStoreLabelFontSize = 16.0f;
        appStoreButtonFontSize = 16.0f;
        appStoreButtonCountryFontSize = 16.0f;
        appStoreButtonCountryMinFontSize = 14.0f;
        
        backgroundImage = [UIImage imageNamed:@"STACorkBackground.png"];
        optionsMenuButtonImage = [UIImage imageNamed:@"STAOptionsMenuButton.png"];
    }
    
    // View
    UIView *tempView = [[UIView alloc] initWithFrame:viewFrame];
    [self setView:tempView];
    [tempView release];
    
    // Background View
    UIImageView *tempBackgroundView = [[UIImageView alloc] initWithFrame:viewFrame];
    [tempBackgroundView setImage:backgroundImage];
    [[self view] addSubview:tempBackgroundView];
    [tempBackgroundView release];
    
    // Email Option Background View
    UIImageView *tempEmailUsBackgroundView = [[UIImageView alloc] initWithFrame:emailOptionButtonFrame];
    [tempEmailUsBackgroundView setImage:optionsMenuButtonImage];
    [[self view] addSubview:tempEmailUsBackgroundView];
    [tempEmailUsBackgroundView release];
    
    UILabel *tempEmailUsLabel = [[UILabel alloc] initWithFrame:emailLabelFrame];
    [tempEmailUsLabel setBackgroundColor:[UIColor clearColor]];
    [tempEmailUsLabel setOpaque:NO];
    [tempEmailUsLabel setNumberOfLines:0];
    [tempEmailUsLabel setFont:[UIFont systemFontOfSize:emailLabelFontSizel]];
    [tempEmailUsLabel setText:NSLocalizedString(@"Please email us with questions or comments.", @"Please email us with questions or comments.")];
    [self setEmailUsLabel:tempEmailUsLabel];
    [[self view] addSubview:tempEmailUsLabel];
    [tempEmailUsLabel release];
    
    if ([MFMailComposeViewController canSendMail])
    {
        UIButton *tempEmailUsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [tempEmailUsButton setFrame:emailButtonFrame];
        [tempEmailUsButton setTitle:NSLocalizedString(@"Email us", @"Email us") forState:UIControlStateNormal];
        [[tempEmailUsButton titleLabel] setFont:[UIFont boldSystemFontOfSize:emailFontSize]];
        [tempEmailUsButton addTarget:self action:@selector(emailUsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self setEmailUsButton:tempEmailUsButton];
        [[self view] addSubview:tempEmailUsButton];
    }
    else
    {
        UILabel *tempEmailAddressLabel = [[UILabel alloc] initWithFrame:emailButtonFrame];
        [tempEmailAddressLabel setBackgroundColor:[UIColor clearColor]];
        [tempEmailAddressLabel setOpaque:NO];
        [tempEmailAddressLabel setTextAlignment:UITextAlignmentCenter];
        [tempEmailAddressLabel setFont:[UIFont boldSystemFontOfSize:emailFontSize]];
        [tempEmailAddressLabel setTextColor:[UIColor colorWithRed:0.22f green:0.33f blue:0.53f alpha:1.0f]];
        [tempEmailAddressLabel setText:@"contact@seetheapp.com"];
        [[self view] addSubview:tempEmailAddressLabel];
        [tempEmailAddressLabel release];
    }
    
    UIImageView *tempAppStoreCountryBackgroundView = [[UIImageView alloc] initWithFrame:appStoreOptionButtonFrame];
    [tempAppStoreCountryBackgroundView setImage:optionsMenuButtonImage];
    [[self view] addSubview:tempAppStoreCountryBackgroundView];
    [tempAppStoreCountryBackgroundView release];
        
    UILabel *tempAppStoreCountryLabel = [[UILabel alloc] initWithFrame:appStoreLabelFrame];
    [tempAppStoreCountryLabel setBackgroundColor:[UIColor clearColor]];
    [tempAppStoreCountryLabel setFont:[UIFont systemFontOfSize:appStoreLabelFontSize]];
    [tempAppStoreCountryLabel setOpaque:NO];
    [tempAppStoreCountryLabel setNumberOfLines:0];
    [tempAppStoreCountryLabel setText:NSLocalizedString(@"Choose the App Store to browse and download apps from.", @"Choose the App Store to browse and download apps from.")];
    [self setAppStoreExplanationLabel:tempAppStoreCountryLabel];
    [[self view] addSubview:tempAppStoreCountryLabel];
    [tempAppStoreCountryLabel release];
    
    UIButton *tempAppStoreCountryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [tempAppStoreCountryButton setFrame:appStoreButtonFrame];
    [[tempAppStoreCountryButton titleLabel] setTextAlignment:UITextAlignmentLeft];
    [tempAppStoreCountryButton setTitle:NSLocalizedString(@"App Store", @"App Store") forState:UIControlStateNormal];
    [[tempAppStoreCountryButton titleLabel] setFont:[UIFont boldSystemFontOfSize:appStoreButtonFontSize]];
    [tempAppStoreCountryButton setTitleEdgeInsets:appStoreButtonEdgeInsets];
    [tempAppStoreCountryButton addTarget:self action:@selector(appStoreCountryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self setAppStoreButton:tempAppStoreCountryButton];
    [[self view] addSubview:tempAppStoreCountryButton];
    
    UILabel *tempAppStoreCountryInButtonLabel = [[UILabel alloc] initWithFrame:appStoreInButtonLabelFrame];
    [tempAppStoreCountryInButtonLabel setOpaque:NO];
    //[tempAppStoreCountryInButtonLabel setBackgroundColor:[UIColor redColor]];
    [tempAppStoreCountryInButtonLabel setBackgroundColor:[UIColor clearColor]];
    [tempAppStoreCountryInButtonLabel setTextAlignment:UITextAlignmentRight];
    [tempAppStoreCountryInButtonLabel setFont:[UIFont systemFontOfSize:appStoreButtonCountryFontSize]];
    [tempAppStoreCountryInButtonLabel setAdjustsFontSizeToFitWidth:YES];
    [tempAppStoreCountryInButtonLabel setMinimumFontSize:appStoreButtonCountryMinFontSize];
    //[tempAppStoreCountryInButtonLabel setText:@"United States"];
    [tempAppStoreCountryButton addSubview:tempAppStoreCountryInButtonLabel];
    [self setCurrentAppStoreLabel:tempAppStoreCountryInButtonLabel];
    [tempAppStoreCountryInButtonLabel release];
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshAppStoreCountryLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self setCurrentAppStoreLabel:nil];
    [self setAppStoreExplanationLabel:nil];
    [self setAppStoreButton:nil];
    
    [self setEmailUsLabel:nil];
    [self setEmailUsButton:nil];
}

- (void)dealloc
{
    [mailComposeViewController_gv release];
    mailComposeViewController_gv = nil;
    [appStoreSelectViewController_gv release];
    appStoreSelectViewController_gv = nil;
    
    [appStoreCountryTitles_gv release];
    appStoreCountryTitles_gv = nil;
    [appStoreCountryCodes_gv release];
    appStoreCountryCodes_gv = nil;
    
    [self setCurrentAppStoreLabel:nil];
    [self setAppStoreExplanationLabel:nil];
    [self setAppStoreButton:nil];
    
    [self setEmailUsLabel:nil];
    [self setEmailUsButton:nil];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)emailUsButtonTapped
{    
    [self presentModalViewController:[self mailComposeViewController] animated:YES];
}

- (void)appStoreCountryButtonTapped
{
    [self presentModalViewController:[self appStoreSelectViewController] animated:YES];
}

#pragma mark - Localization Methods

- (void)resetText
{
    [[self navigationItem] setTitle:NSLocalizedString(@"Options", @"Options")];
    
    [[self appStoreExplanationLabel] setText:NSLocalizedString(@"Choose the App Store to browse and download apps from.", @"Choose the App Store to browse and download apps from.")];
    [[self appStoreButton] setTitle:NSLocalizedString(@"App Store", @"App Store") forState:UIControlStateNormal];
    
    [[self emailUsLabel] setText:NSLocalizedString(@"Please email us with questions or comments.", @"Please email us with questions or comments.")];
    [[self emailUsButton] setTitle:NSLocalizedString(@"Email us", @"Email us") forState:UIControlStateNormal];
    
    // reset appStoreSelectVC if it exists
    if (appStoreSelectViewController_gv)
        [[self appStoreSelectViewController] resetText];
}

#pragma mark - Refresh

- (void)refreshAppStoreCountryLabel
{
    NSString *currentCountryCode = [[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsAppStoreCountryKey];
    NSInteger indexOfCountryCode = [[self appStoreCountryCodes] indexOfObject:currentCountryCode];
    NSString *currentCountryTitle = [[self appStoreCountryTitles] objectAtIndex:indexOfCountryCode];
    [[self currentAppStoreLabel] setText:currentCountryTitle];
    
    if (appStoreSelectViewController_gv)
        [[self appStoreSelectViewController] updateActiveAppStore];
}

#pragma mark - AppStoreSelectViewControllerDelegate Methods

- (void)dismissSelectViewControllerWithNoChange
{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)dismissSelectViewControllerWithNewAppStore:(NSString*)argSelectedAppStore;
{
    [[self delegate] updateAppStoreCountry:argSelectedAppStore];
    [self dismissModalViewControllerAnimated:YES];
    //[[self delegate] populateInitialAppsForCurrentCountry];
}

#pragma mark - MailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissModalViewControllerAnimated:YES];
}

# pragma mark - MailComposeViewController

- (MFMailComposeViewController*)mailComposeViewController
{
    if (mailComposeViewController_gv)
        return mailComposeViewController_gv;
    mailComposeViewController_gv = [[MFMailComposeViewController alloc] init];
    [mailComposeViewController_gv setMailComposeDelegate:self];
    [mailComposeViewController_gv setToRecipients:[NSArray arrayWithObject:@"contact@seetheapp.com"]];
    [mailComposeViewController_gv setSubject:@"See the App"];
    return mailComposeViewController_gv;
}

#pragma mark - AppStoreSelectViewController

- (SeeTheAppAppStoreSelectViewController*)appStoreSelectViewController
{
    if (appStoreSelectViewController_gv)
        return appStoreSelectViewController_gv;
    appStoreSelectViewController_gv = [[SeeTheAppAppStoreSelectViewController alloc] initWithDelegate:self];
    // set delegate to this so we can get the info coming back
    return appStoreSelectViewController_gv;
}

#pragma mark - AppStoreCountry Arrays

- (void)createAppStoreArrays
{
    NSBundle *settingsBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"]];
    NSString *rootPlistPath = [settingsBundle pathForResource:@"Root" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:rootPlistPath];
    NSArray *preferenceSpecifiersArray = [dictionary valueForKey:@"PreferenceSpecifiers"];
    NSDictionary *appStorePreferenceDictionary = [preferenceSpecifiersArray lastObject];
    appStoreCountryTitles_gv = [[appStorePreferenceDictionary valueForKey:@"Titles"] retain];
    appStoreCountryCodes_gv = [[appStorePreferenceDictionary valueForKey:@"Values"] retain];
}

- (NSArray*)appStoreCountryTitles
{
    if (appStoreCountryTitles_gv)
        return appStoreCountryTitles_gv;
    [self createAppStoreArrays];
    return appStoreCountryTitles_gv;
}

- (NSArray*)appStoreCountryCodes
{
    if (appStoreCountryCodes_gv)
        return appStoreCountryCodes_gv;
    [self createAppStoreArrays];
    return appStoreCountryCodes_gv;
}

#pragma mark - Properties

@synthesize delegate;

@synthesize currentAppStoreLabel;
@synthesize appStoreExplanationLabel;
@synthesize appStoreButton;

@synthesize emailUsLabel;
@synthesize emailUsButton;

@end
