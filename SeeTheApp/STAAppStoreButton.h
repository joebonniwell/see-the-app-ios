//
//  STAAppStoreButton.h
//  SeeTheApp
//
//  Created by goVertex on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STAAppStoreButton : UIButton
{
    @private
    UILabel *availableLabel;
    UILabel *appStoreLabel;
}

- (void)updateTextColorForCurrentState;

- (void)setAvailableLabelText:(NSString*)argText;
- (void)setAppStoreLabelText:(NSString*)argText;

- (void)setAppStoreLabelsNormal;
- (void)setAppStoreLabelsUpsideDown;

@end
