//
//  SeeTheAppGamesSubcategoriesMenuViewController.h
//  SeeTheApp
//
//  Created by goVertex on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeeTheAppMenuView.h"

@protocol STAGamesSubcategoriesMenuDelegate <NSObject>

- (void)gamesSubcategoriesMenuCategorySelected:(NSInteger)argRow;
- (NSArray*)gameCategoriesInfo;

@end

@interface SeeTheAppGamesSubcategoriesMenuViewController : UIViewController <SeeTheAppMenuViewDelegate>
{
    id delegate;
    
    SeeTheAppMenuView *menuView;
    
    @private
    
    NSArray *allMenuItems_gv;
}

@property (nonatomic, assign) id <STAGamesSubcategoriesMenuDelegate>delegate;
@property (nonatomic, retain, readonly) NSArray *allMenuItems;
@property (nonatomic, retain) SeeTheAppMenuView *menuView;

- (id)initWithDelegate:(id)argDelegate;

- (void)resetText;

@end