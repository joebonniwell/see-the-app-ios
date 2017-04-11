//
//  SeeTheAppMainMenuViewController.h
//  SeeTheApp
//
//  Created by goVertex on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeeTheAppMenuView.h"

@protocol STAMainMenuDelegate <NSObject>

- (void)mainMenuRowSelected:(NSInteger)argRow;

@end

@interface SeeTheAppMainMenuViewController : UIViewController <SeeTheAppMenuViewDelegate>
{
    id delegate;
    NSArray *allMenuItems;
    SeeTheAppMenuView *menuView;
}

@property (nonatomic, assign) id <STAMainMenuDelegate>delegate;
@property (nonatomic, retain) NSArray *allMenuItems;
@property (nonatomic, retain) SeeTheAppMenuView *menuView;

- (id)initWithDelegate:(id)argDelegate;

- (void)resetText;

@end
