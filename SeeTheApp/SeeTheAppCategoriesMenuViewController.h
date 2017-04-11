//
//  SeeTheAppCategoriesMenuViewController.h
//  SeeTheApp
//
//  Created by goVertex on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeeTheAppMenuView.h"

@protocol STACategoriesMenuDelegate <NSObject>

- (void)categoriesMenuCategorySelected:(NSInteger)argRow;
- (NSArray*)categoriesInfo;

@end

@interface SeeTheAppCategoriesMenuViewController : UIViewController <SeeTheAppMenuViewDelegate>
{
    id delegate;
    
    SeeTheAppMenuView *menuView;
    
    @private
    
    NSArray *allMenuItems_gv;
}

@property (nonatomic, assign) id <STACategoriesMenuDelegate>delegate;
@property (nonatomic, retain, readonly) NSArray *allMenuItems;
@property (nonatomic, retain) SeeTheAppMenuView *menuView;

- (id)initWithDelegate:(id)argDelegate;

- (void)resetText;

@end