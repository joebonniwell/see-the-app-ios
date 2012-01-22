//
//  SeeTheAppScreenshotLoadOperation.h
//  SeeTheApp
//
//  Created by goVertex on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SeeTheAppScreenshotLoadOperation : NSOperation 
{
    id delegate;
    NSString *imageFilePath;
    NSInteger row;
}

@property (assign) id delegate;
@property (copy) NSString *imageFilePath;
@property NSInteger row;

+ (id)operationWithPath:(NSString*)argImageFilePath row:(NSInteger)argRow delegate:(id)argDelegate;

@end
