//
//  SeeTheAppOptionsViewController.h
//  SeeTheApp
//
//  Created by goVertex on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SeeTheAppAppStoreSelectViewController.h"

@protocol SeeTheAppOptionsViewControllerDelegate <NSObject>

- (void)updateAppStoreCountry:(NSString*)argCountryCode;
- (void)populateInitialAppsForCurrentCountry;

@end

@interface SeeTheAppOptionsViewController : UIViewController <MFMailComposeViewControllerDelegate, AppStoreSelectViewControllerDelegate>
{
    id delegate;
    
    UILabel *currentAppStoreLabel;
    UILabel *appStoreExplanationLabel;
    UIButton *appStoreButton;
    
    UILabel *emailUsLabel;
    UIButton *emailUsButton;
    
    @private
    
    MFMailComposeViewController *mailComposeViewController_gv;
    SeeTheAppAppStoreSelectViewController *appStoreSelectViewController_gv;
    
    NSArray *appStoreCountryTitles_gv;
    NSArray *appStoreCountryCodes_gv;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign, readonly) MFMailComposeViewController *mailComposeViewController;
@property (nonatomic, assign, readonly) SeeTheAppAppStoreSelectViewController *appStoreSelectViewController;

@property (nonatomic, retain) UILabel *currentAppStoreLabel;
@property (nonatomic, retain) UILabel *appStoreExplanationLabel;
@property (nonatomic, retain) UIButton *appStoreButton;

@property (nonatomic, retain) UILabel *emailUsLabel;
@property (nonatomic, retain) UIButton *emailUsButton;

@property (nonatomic, retain, readonly) NSArray *appStoreCountryTitles;
@property (nonatomic, retain, readonly) NSArray *appStoreCountryCodes;

- (id)initWithDelegate:(id)argDelegate;

- (void)refreshAppStoreCountryLabel;

- (void)resetText;

@end
