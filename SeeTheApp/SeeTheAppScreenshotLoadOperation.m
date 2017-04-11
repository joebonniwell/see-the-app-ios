//
//  SeeTheAppScreenshotLoadOperation.m
//  SeeTheApp
//
//  Created by goVertex on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SeeTheAppScreenshotLoadOperation.h"


@implementation SeeTheAppScreenshotLoadOperation

+ (id)operationWithPath:(NSString*)argImageFilePath row:(NSInteger)argRow delegate:(id)argDelegate
{    
    SeeTheAppScreenshotLoadOperation *newOp = [[SeeTheAppScreenshotLoadOperation alloc] init];
    [newOp setRow:argRow];
    [newOp setDelegate:argDelegate];
    [newOp setImageFilePath:argImageFilePath];
    return [newOp autorelease];
}

- (void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Load the data from file
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:[self imageFilePath]];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    // Perform orientation adjustment here...
    
    
    NSDictionary *imageAndRowPackage = [[NSDictionary alloc] initWithObjectsAndKeys:image, @"ImageKey", [NSNumber numberWithInteger:[self row]], @"RowKey", nil];
    [[self delegate] performSelectorOnMainThread:@selector(cacheImage:) withObject:imageAndRowPackage waitUntilDone:NO];
    
    [imageData release];
    [image release];
    [imageAndRowPackage release];
    
    [pool drain];
}

- (void)dealloc
{
    [self setDelegate:nil];
    [self setImageFilePath:nil];
    
    [super dealloc];
}

@synthesize delegate;
@synthesize imageFilePath;
@synthesize row;

@end
