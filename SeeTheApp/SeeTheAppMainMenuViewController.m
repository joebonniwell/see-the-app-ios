//
//  SeeTheAppMainMenuViewController.m
//  SeeTheApp
//
//  Created by goVertex on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SeeTheAppMainMenuViewController.h"

@implementation SeeTheAppMainMenuViewController

- (id)initWithDelegate:(id)argDelegate
{
    if ((self = [super init]))
    {
        [self setDelegate:argDelegate];
        
        [[self navigationItem] setTitle:NSLocalizedString(@"Menu", @"Menu")];
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
    // Get the frame
    CGRect viewFrame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        viewFrame = CGRectMake(0.0f, 0.0f, 768.0f, 960.0f);
    else
        viewFrame = CGRectMake(0.0f, 0.0f, 320.0f, 416.0f);
    
    // Create the view
    UIView *tempView = [[UIView alloc] initWithFrame:viewFrame];
    [self setView:tempView];
    [tempView release];
    
    // Create the menu items array
    [self setAllMenuItems:[NSArray arrayWithObjects:
                           NSLocalizedString(@"Browse All Apps", @"Browse All Apps"),
                           NSLocalizedString(@"Categories", @"Categories"),
                           NSLocalizedString(@"Options", @"Options"),
                           nil]];
    
    // Create and add the menu view
    SeeTheAppMenuView *tempMenuView = [[SeeTheAppMenuView alloc] initWithFrame:viewFrame delegate:self];
    [self setMenuView:tempMenuView];
    [[self view] addSubview:tempMenuView];
    [tempMenuView release];
    
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

- (void)viewDidUnload
{
    [super viewDidUnload];

    [self setAllMenuItems:nil];
    
    [self setMenuView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Localization Methods

- (void)resetText
{
    [[self navigationItem] setTitle:NSLocalizedString(@"Menu", @"Menu")];
    [self setAllMenuItems:[NSArray arrayWithObjects:
                           NSLocalizedString(@"Browse All Apps", @"Browse All Apps"),
                           NSLocalizedString(@"Categories", @"Categories"),
                           NSLocalizedString(@"Options", @"Options"),
                           nil]];
    [[self menuView] resetMenuTitles];
}

#pragma mark - SeeTheAppMenuViewDelegate Methods

- (void)menuButtonTapped:(NSInteger)argButtonIndex
{
    [[self delegate] mainMenuRowSelected:argButtonIndex];
}

#pragma mark - Property Synthesis

@synthesize delegate;
@synthesize allMenuItems;
@synthesize menuView;
@end
