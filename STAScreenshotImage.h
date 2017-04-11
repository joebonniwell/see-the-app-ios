//
//  STAScreenshotImage.h
//  SeeTheApp
//
//  Created by goVertex on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STAScreenshotImage : UIImage
{
    NSDate *lastAccessedDate;
}

@property (nonatomic, retain) NSDate *lastAccessedDate;

@end
