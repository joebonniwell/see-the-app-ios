//
//  SeeTheAppAppStoreSelectViewController.h
//  SeeTheApp
//
//  Created by goVertex on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AppStoreSelectViewControllerDelegate <NSObject>

- (void)dismissSelectViewControllerWithNoChange;
- (void)dismissSelectViewControllerWithNewAppStore:(NSString*)argSelectedAppStore;

- (NSArray*)appStoreCountryTitles;
- (NSArray*)appStoreCountryCodes;

@end

@interface SeeTheAppAppStoreSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    id delegate;
    
    UITableView *appStoreCountriesTableView;
    
    NSInteger selectedCountryIndex;
    
    UIBarButtonItem *appStoreBarButtonLabel;
}

@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) UITableView *appStoreCountriesTableView;

@property NSInteger selectedCountryIndex;

@property (nonatomic, retain) UIBarButtonItem *appStoreBarButtonLabel;

- (id)initWithDelegate:(id)argDelegate;

- (void)updateActiveAppStore;

- (void)resetText;

@end
