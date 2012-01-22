//
//  STASearchBar.m
//  SeeTheApp
//
//  Created by goVertex on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "STASearchBar.h"

@implementation STASearchBar

- (id)init
{
    if ((self = [super init]))
    {
        [self applyTransparentBackground];
        
        for (UIView *subview in [self subviews])
            NSLog(@"Subview: %@", [subview description]);
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self applyTransparentBackground];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSLog(@"Drawing searchbar");
    
    NSLog(@"Subviews: %d", [[self subviews] count]);
}

- (void)applyTransparentBackground
{
    [self setBarStyle:UIBarStyleDefault];
    [self setTintColor:[UIColor brownColor]];
    while ([[self subviews] count] > 1) 
    {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    
    [self setBackgroundColor:[UIColor clearColor]];
    //[self setOpaque:NO];
    //[self setTranslucent:YES];
    //[self setTintColor:[UIColor clearColor]];
}

@end
