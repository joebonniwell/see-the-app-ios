//
//  SeeTheAppMenuView.m
//  SeeTheApp
//
//  Created by goVertex on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SeeTheAppMenuView.h"

@implementation SeeTheAppMenuView

- (id)initWithFrame:(CGRect)argFrame delegate:(id<SeeTheAppMenuViewDelegate>)argDelegate
{
    self = [super initWithFrame:argFrame];
    if (self) 
    {
        [self setDelegate:argDelegate];
        
        UIScrollView *tempScrollView = [[UIScrollView alloc] initWithFrame:argFrame];
        [self setScrollView:tempScrollView];
        [self addSubview:tempScrollView];
        [tempScrollView release];
        
        NSInteger numberOfMenuItems = [[[self delegate] allMenuItems] count];
        
        float offset;
        float menuItemHeight;
        float fontSize;
        float minFontSize;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            offset = 40.0f;
            menuItemHeight = 150.0f;
            fontSize = 26.0f;
            minFontSize = 14.0f;
        }
        else
        {
            offset = 10.0f;
            menuItemHeight = 86.0f;
            fontSize = 20.0f;
            minFontSize = 12.0f;
        }
            
        float totalMenuHeight = numberOfMenuItems * menuItemHeight + offset;
        
        [tempScrollView setContentSize:CGSizeMake(argFrame.size.width, totalMenuHeight)];
        
        // Cork Background
        UIImageView *headerImageView;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, -960.0f, 768.0f, 960.0f)];
        else
            headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, -416.0f, 320.0f, 416.0f)];
        [headerImageView setImage:[self corkBackgroundImage]];
        [headerImageView setTag:-1];
        [[self scrollView] addSubview:headerImageView];
        [headerImageView release];
        
        float corkOffset = 0;
        if (numberOfMenuItems > 0)
        {
            while (corkOffset <= totalMenuHeight) 
            {
                UIImageView *corkBackgroundImageView;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    corkBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, corkOffset, 768.0f, 960.0f)];
                else
                    corkBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, corkOffset, 320.0f, 416.0f)];
                [corkBackgroundImageView setImage:[self corkBackgroundImage]];
                [corkBackgroundImageView setTag:-1];
                [[self scrollView] addSubview:corkBackgroundImageView];
                [corkBackgroundImageView release];
                
                corkOffset += [corkBackgroundImageView frame].size.height;                
            }
        }
        
        UIImageView *footerImageView;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            footerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, corkOffset, 768.0f, 960.0f)];
        else
            footerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, corkOffset, 320.0f, 416.0f)];
        [footerImageView setImage:[self corkBackgroundImage]];
        [footerImageView setTag:-1];
        [[self scrollView] addSubview:footerImageView];
        [footerImageView release];

        // Create Menu Items
        NSArray *menuItems = [[self delegate] allMenuItems];
        if ([menuItems count] > 0)
        {
            for (int menuItemIndex = 0; menuItemIndex < [menuItems count]; menuItemIndex++)
            {
                UIButton *newMenuItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    [newMenuItemButton setFrame:CGRectMake(184.0f, offset, 400.0f, 120.0f)];
                    [newMenuItemButton setTitleEdgeInsets:UIEdgeInsetsMake(10.0f, 100.0f, 10.0f, 10.0f)];
                    //UIEdgeInsetsMake(<#CGFloat top#>, <#CGFloat left#>, <#CGFloat bottom#>, <#CGFloat right#>)
                }
                else
                {
                    [newMenuItemButton setFrame:CGRectMake(10.0f, offset, 300.0f, 80.0f)];
                    [newMenuItemButton setTitleEdgeInsets:UIEdgeInsetsMake(6.0f, 60.0f, 6.0f, 10.0f)];
                }
                
                [newMenuItemButton setTitle:[menuItems objectAtIndex:menuItemIndex] forState:UIControlStateNormal];
                [newMenuItemButton setTag:(menuItemIndex + 10)];
                [newMenuItemButton setTitleColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.79f] forState:UIControlStateNormal];
                [[newMenuItemButton titleLabel] setTextAlignment:UITextAlignmentLeft];
                [[newMenuItemButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
                [[newMenuItemButton titleLabel] setMinimumFontSize:minFontSize];
                [[newMenuItemButton titleLabel] setFont:[UIFont systemFontOfSize:fontSize]];
                [newMenuItemButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                [newMenuItemButton setBackgroundImage:[self menuButtonImage] forState:UIControlStateNormal];
                [newMenuItemButton setBackgroundImage:[self menuButtonHighlightedImage] forState:UIControlStateHighlighted];
                [newMenuItemButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [[self scrollView] addSubview:newMenuItemButton];
                
                offset += menuItemHeight;
            }
        }
    }
    return self;
}

- (void)resetMenuTitles
{
    for (UIView *subview in [[self scrollView] subviews])
    {
        NSInteger index = [subview tag];
        if (index >= 10)
        {
            UIButton *menuButton = (UIButton*)subview;
            if ((index - 10) < [[[self delegate] allMenuItems] count])
                [menuButton setTitle:[[[self delegate] allMenuItems] objectAtIndex:(index - 10)] forState:UIControlStateNormal];
            else
                [menuButton removeFromSuperview];
        }
    }
}

- (void)buttonTapped:(UIButton*)argButton
{
    [[self delegate] menuButtonTapped:([argButton tag] - 10)];
}

#pragma mark - Cork Image

- (UIImage*)corkBackgroundImage
{
    if (corkBackgroundImage_gv)
        return corkBackgroundImage_gv;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        corkBackgroundImage_gv = [[UIImage imageNamed:@"STACorkBackgroundHD.png"] retain];
    else
        corkBackgroundImage_gv = [[UIImage imageNamed:@"STACorkBackground.png"] retain];
    
    return corkBackgroundImage_gv;
}

#pragma mark - Button Images

- (UIImage*)menuButtonImage
{
    if (menuButtonImage_gv)
        return menuButtonImage_gv;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        menuButtonImage_gv = [[UIImage imageNamed:@"STAMenuButtonHD.png"] retain];
    else
        menuButtonImage_gv = [[UIImage imageNamed:@"STAMenuButton.png"] retain];
    
    return menuButtonImage_gv;
}

- (UIImage*)menuButtonHighlightedImage
{
    if (menuButtonHighlightedImage_gv)
        return menuButtonHighlightedImage_gv;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        menuButtonHighlightedImage_gv = [[UIImage imageNamed:@"STAMenuButtonHighlightedHD.png"] retain];
    else
        menuButtonHighlightedImage_gv = [[UIImage imageNamed:@"STAMenuButtonHighlighted.png"] retain];
    
    return menuButtonHighlightedImage_gv;
}

#pragma mark - Property Synthesis

@synthesize delegate;
@synthesize scrollView;

@end
