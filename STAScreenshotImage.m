//
//  STAScreenshotImage.m
//  SeeTheApp
//
//  Created by goVertex on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "STAScreenshotImage.h"

@implementation STAScreenshotImage

- (id)init
{
    if ((self = [super init]))
    {
        [self setLastAccessedDate:[NSDate date]];
    }
    return self;
}

- (id)initWithData:(NSData*)argData
{
    if ((self = [super initWithData:argData]))
    {
        [self setLastAccessedDate:[NSDate date]];
    }
    return self;
}

- (id)initWithCGImage:(CGImageRef)argCGImage scale:(CGFloat)argScale orientation:(UIImageOrientation)argOrientation
{
    if ((self = [super initWithCGImage:argCGImage scale:argScale orientation:argOrientation]))
    {
        [self setLastAccessedDate:[NSDate date]];
    }
    return self;
}

- (void)dealloc
{
    [self setLastAccessedDate:nil];
    [super dealloc];
}

@synthesize lastAccessedDate;
@end
