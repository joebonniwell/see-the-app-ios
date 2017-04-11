//
//  STAAppStoreButton.m
//  SeeTheApp
//
//  Created by goVertex on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "STAAppStoreButton.h"

@implementation STAAppStoreButton
         
- (id)init
{
    CGRect buttonFrame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        buttonFrame = CGRectMake(171.0f, 820.0f, 310.0f, 110.0f);
    else
        buttonFrame = CGRectMake(56.0f, 349.0f, 148.0f, 54.0f);
    
    if ((self = [super initWithFrame:buttonFrame]))
    {
        CGRect availableLabelFrame;
        CGRect appStoreLabelFrame;
        
        UIImage *appStoreButtonImage;
        UIImage *appStoreButtonHighlightedImage;
        UIImage *appStoreButtonDisabledImage;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            availableLabelFrame = CGRectMake(STAConstantAvailableLabelHDX, STAConstantAvailableLabelHDY, STAConstantAvailableLabelHDWidth, STAConstantAvailableLabelHDHeight);
            appStoreLabelFrame = CGRectMake(STAConstantAppStoreLabelHDX, STAConstantAppStoreLabelHDY, STAConstantAppStoreLabelHDWidth, STAConstantAppStoreLabelHDHeight);
            
            appStoreButtonImage = [UIImage imageNamed:@"STAAppStoreButtonHD.png"];
            appStoreButtonHighlightedImage = [UIImage imageNamed:@"STAAppStoreButtonHighlightedHD.png"];
            appStoreButtonDisabledImage = [UIImage imageNamed:@"STAAppStoreButtonDisabledHD.png"];
        }
        else
        {
            availableLabelFrame = CGRectMake(STAConstantAvailableLabelX, STAConstantAvailableLabelY, STAConstantAvailableLabelWidth, STAConstantAvailableLabelHeight);
            appStoreLabelFrame = CGRectMake(STAConstantAppStoreLabelX, STAConstantAppStoreLabelY, STAConstantAppStoreLabelWidth, STAConstantAppStoreLabelHeight);
            
            appStoreButtonImage = [UIImage imageNamed:@"STAAppStoreButton.png"];
            appStoreButtonHighlightedImage = [UIImage imageNamed:@"STAAppStoreButtonHighlighted.png"];
            appStoreButtonDisabledImage = [UIImage imageNamed:@"STAAppStoreButtonDisabled.png"];
        }
        
        [self setTag:STAAppStoreButtonTag];
        
        [self setImage:appStoreButtonImage forState:UIControlStateNormal];
        [self setImage:appStoreButtonHighlightedImage forState:UIControlStateHighlighted];
        [self setImage:appStoreButtonDisabledImage forState:UIControlStateDisabled];
        
        // Available on the label
        availableLabel = [[UILabel alloc] initWithFrame:availableLabelFrame];
        [availableLabel setTag:30];
        [availableLabel setBackgroundColor:[UIColor clearColor]];
        //[availableLabel setBackgroundColor:[UIColor redColor]];
        [availableLabel setOpaque:NO];
        [availableLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
        [availableLabel setTextColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f]];
        [self setAvailableLabelText:NSLocalizedString(@"Available on the", @"Available on the")];
        [self addSubview:availableLabel];
        [availableLabel release];
        
        // App Store label
        appStoreLabel = [[UILabel alloc] initWithFrame:appStoreLabelFrame];
        [appStoreLabel setTag:31];
        [appStoreLabel setBackgroundColor:[UIColor clearColor]];
        //[appStoreLabel setBackgroundColor:[UIColor blueColor]];
        [appStoreLabel setOpaque:NO];
        [appStoreLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
        [appStoreLabel setTextColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f]];
        [self setAppStoreLabelText:NSLocalizedString(@"App Store", @"App Store")];
        [self addSubview:appStoreLabel];
        [appStoreLabel release];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self updateTextColorForCurrentState];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self updateTextColorForCurrentState];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self updateTextColorForCurrentState];
}

- (void)updateTextColorForCurrentState
{
    if ([self isEnabled] == NO)
    {
        [availableLabel setTextColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.25f]];
        [appStoreLabel setTextColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.25f]];
        return;
    }
    if ([self isHighlighted])
    {
        [availableLabel setTextColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.80f]];
        [appStoreLabel setTextColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.80f]];
        return;
    }
    [availableLabel setTextColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.80f]];
    [appStoreLabel setTextColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.80f]];
}

- (void)setAvailableLabelText:(NSString*)argText
{
    float fontSize = [[availableLabel font] pointSize];
    CGSize textSize = [argText sizeWithFont:[UIFont systemFontOfSize:fontSize]];
        
    if (textSize.height > availableLabel.frame.size.height || textSize.width > availableLabel.frame.size.width || fontSize == 0)
    {
        fontSize = 60.0f;
        textSize = [argText sizeWithFont:[UIFont systemFontOfSize:fontSize]];
        while ((textSize.height > availableLabel.frame.size.height || textSize.width > availableLabel.frame.size.width) && fontSize > 0) 
        {
            fontSize = fontSize - 1.0f;
            textSize = [argText sizeWithFont:[UIFont systemFontOfSize:fontSize]];
        }
    
        if (fontSize == 0.0f)
        {
            NSLog(@"Error, text will not fit");
            return;
        }
        [availableLabel setFont:[UIFont systemFontOfSize:fontSize]];
    }
    else
    {
        textSize = [argText sizeWithFont:[UIFont systemFontOfSize:(fontSize + 1.0f)]];
        if (textSize.height < availableLabel.frame.size.height && textSize.width < availableLabel.frame.size.width)
        {
            fontSize = fontSize + 1.0f;
            while (textSize.height < availableLabel.frame.size.height && textSize.width < availableLabel.frame.size.width)
            {
                fontSize = fontSize + 1.0f;
                textSize = [argText sizeWithFont:[UIFont systemFontOfSize:fontSize]];
            }
            if (textSize.height > availableLabel.frame.size.height || textSize.width > availableLabel.frame.size.width)
                fontSize = fontSize - 1.0f;
        }
        [availableLabel setFont:[UIFont systemFontOfSize:fontSize]];
    }
    [availableLabel setText:argText];
}

- (void)setAppStoreLabelText:(NSString*)argText
{
    float fontSize = 60.0f;
    CGSize textSize = [argText sizeWithFont:[UIFont systemFontOfSize:fontSize]];
    
    if (textSize.height > appStoreLabel.frame.size.height || textSize.width > appStoreLabel.frame.size.width || fontSize == 0)
    {
        fontSize = 60.0f;
        textSize = [argText sizeWithFont:[UIFont systemFontOfSize:fontSize]];
        while ((textSize.height > appStoreLabel.frame.size.height || textSize.width > appStoreLabel.frame.size.width) && fontSize > 0) 
        {
            fontSize = fontSize - 1.0f;
            textSize = [argText sizeWithFont:[UIFont systemFontOfSize:fontSize]];
        }
    
        if (fontSize == 0.0f)
        {
            NSLog(@"Error, text will not fit");
            return;
        }
        [appStoreLabel setFont:[UIFont systemFontOfSize:fontSize]];
    }
    else
    {
        textSize = [argText sizeWithFont:[UIFont systemFontOfSize:(fontSize + 1.0f)]];
        if (textSize.height < appStoreLabel.frame.size.height && textSize.width < appStoreLabel.frame.size.width)
        {
            fontSize = fontSize + 1.0f;
            while (textSize.height < appStoreLabel.frame.size.height && textSize.width < appStoreLabel.frame.size.width)
            {
                fontSize = fontSize + 1.0f;
                textSize = [argText sizeWithFont:[UIFont systemFontOfSize:fontSize]];
            }
            if (textSize.height > appStoreLabel.frame.size.height || textSize.width > appStoreLabel.frame.size.width)
                fontSize = fontSize - 1.0f;
        }
        [appStoreLabel setFont:[UIFont systemFontOfSize:fontSize]];
    }
    [appStoreLabel setText:argText];
}

- (void)setAppStoreLabelsNormal
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [availableLabel setFrame:CGRectMake(STAConstantAvailableLabelHDX, STAConstantAvailableLabelHDY, STAConstantAvailableLabelHDWidth, STAConstantAvailableLabelHDHeight)];
        [appStoreLabel setFrame:CGRectMake(STAConstantAppStoreLabelHDX, STAConstantAppStoreLabelHDY, STAConstantAppStoreLabelHDWidth, STAConstantAppStoreLabelHDHeight)];
    }
    else
    {
        [availableLabel setFrame:CGRectMake(STAConstantAvailableLabelX, STAConstantAvailableLabelY, STAConstantAvailableLabelWidth, STAConstantAvailableLabelHeight)];
        [appStoreLabel setFrame:CGRectMake(STAConstantAppStoreLabelX, STAConstantAppStoreLabelY, STAConstantAppStoreLabelWidth, STAConstantAppStoreLabelHeight)];
    }
}

- (void)setAppStoreLabelsUpsideDown
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [availableLabel setFrame:CGRectMake(STAConstantAvailableLabelHDX, STAConstantAvailableLabelHDYJapanese, STAConstantAvailableLabelHDWidth, STAConstantAvailableLabelHDHeight)];
        [appStoreLabel setFrame:CGRectMake(STAConstantAppStoreLabelHDX, STAConstantAppStoreLabelHDYJapanese, STAConstantAppStoreLabelHDWidth, STAConstantAppStoreLabelHDHeight)];
    }
    else
    {
        [availableLabel setFrame:CGRectMake(STAConstantAvailableLabelX, STAConstantAvailableLabelYJapanese, STAConstantAvailableLabelWidth, STAConstantAvailableLabelHeight)];
        [appStoreLabel setFrame:CGRectMake(STAConstantAppStoreLabelX, STAConstantAppStoreLabelYJapanese, STAConstantAppStoreLabelWidth, STAConstantAppStoreLabelHeight)];
    }
}

@end
