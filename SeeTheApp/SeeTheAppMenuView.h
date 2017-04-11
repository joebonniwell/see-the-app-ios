//
//  SeeTheAppMenuView.h
//  SeeTheApp
//
//  Created by goVertex on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SeeTheAppMenuViewDelegate <NSObject>

- (NSArray*)allMenuItems;
- (void)menuButtonTapped:(NSInteger)argButtonIndex;

@end

@interface SeeTheAppMenuView : UIView
{
    id delegate;
    UIScrollView *scrollView;
    
    @private
    UIImage *corkBackgroundImage_gv;
    UIImage *menuButtonImage_gv;
    UIImage *menuButtonHighlightedImage_gv;
}

@property (nonatomic, assign) id<SeeTheAppMenuViewDelegate> delegate;
@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic, retain, readonly) UIImage *corkBackgroundImage;
@property (nonatomic, retain, readonly) UIImage *menuButtonImage;
@property (nonatomic, retain, readonly) UIImage *menuButtonHighlightedImage;

- (id)initWithFrame:(CGRect)argFrame delegate:(id<SeeTheAppMenuViewDelegate>)argDelegate;

- (void)resetMenuTitles;

@end
