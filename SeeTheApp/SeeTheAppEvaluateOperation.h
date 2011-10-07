//
//  SeeTheAppEvaluateOperation.h
//  SeeTheApp
//
//  Created by goVertex on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SeeTheAppEvaluateOperationDelegate <NSObject>

- (void)evaluateOperationFinishedWithNextAction:(NSDictionary*)argActionDictionary;

@end

@interface SeeTheAppEvaluateOperation : NSOperation 
{
    NSObject<SeeTheAppEvaluateOperationDelegate> *delegate;
    NSInteger currentRow;
    NSFileManager *fileManager;
    
    NSAutoreleasePool *releasePool;
    
    @private
    
    NSString *pathForLibraryDirectory_gv;
    NSString *pathForScreenshotsDirectory_gv;
}

@property (assign) NSObject<SeeTheAppEvaluateOperationDelegate> *delegate;
@property NSInteger currentRow;
@property (nonatomic, retain) NSFileManager *fileManager;

- (id)initWithCurrentRow:(NSInteger)argCurrentRow delegate:(id)argDelegate;
- (void)cleanup;

// Other Methods
- (NSArray*)cachedImages;

// File Methods
- (NSString*)pathForLibraryDirectory;
- (NSString*)pathForScreenshotsDirectory;

@end
