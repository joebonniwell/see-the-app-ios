//
//  SeeTheAppCategoriesMenuViewController.m
//  SeeTheApp
//
//  Created by goVertex on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SeeTheAppCategoriesMenuViewController.h"

@implementation SeeTheAppCategoriesMenuViewController

- (id)initWithDelegate:(id)argDelegate
{
    if ((self = [super init]))
    {
        [self setDelegate:argDelegate];
        
        [[self navigationItem] setTitle:NSLocalizedString(@"Categories", @"Categories")];
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
    
    [self setMenuView:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - SeeTheAppMenuViewDelegate Methods

- (void)menuButtonTapped:(NSInteger)argButtonIndex
{
    NSInteger category = [[[[[self delegate] categoriesInfo] objectAtIndex:argButtonIndex] valueForKey:@"CategoryCode"] integerValue];
    [[self delegate] categoriesMenuCategorySelected:category];
}

- (NSArray*)allMenuItems
{
    if (allMenuItems_gv)
        return allMenuItems_gv;
    NSMutableArray *tempAllMenuItems_gv = [[NSMutableArray alloc] init];
    NSArray *categoryDicts = [[self delegate] categoriesInfo];
    for (NSDictionary *categoryDict in categoryDicts)
    {
        [tempAllMenuItems_gv addObject:[categoryDict valueForKey:@"CategoryName"]];
    }
    allMenuItems_gv = tempAllMenuItems_gv;
    return allMenuItems_gv;
}

#pragma mark - Localization Methods

- (void)resetText
{
    [[self navigationItem] setTitle:NSLocalizedString(@"Categories", @"Categories")];
    if (allMenuItems_gv)
    {
        [allMenuItems_gv release];
        allMenuItems_gv = nil;
        [self allMenuItems];
    }
    [[self menuView] resetMenuTitles];
}

#pragma mark - Property Synthesis

@synthesize delegate;
@synthesize menuView;
@end
