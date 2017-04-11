//
//  SeeTheAppDownloadOperation.h
//  SeeTheApp
//
//  Created by goVertex on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SeeTheAppDownloadOperationDelegate <NSObject>

- (NSInteger)currentRow;

@end

@interface SeeTheAppDownloadOperation : NSOperation 
{
    id delegate;
    NSInteger appID;
    NSManagedObjectID *appObjectID;
    
    NSInteger displayIndex;
    BOOL canTrimCache;
    
    NSAutoreleasePool *releasePool;
    
    NSFileManager *fileManager;
    
    NSString *pathForLibraryDirectory_gv;
    NSString *pathForScreenshotsDirectory_gv;
    
    NSString *responseString;
}

@property (assign) id delegate;
@property NSInteger appID;
@property (retain) NSManagedObjectID *appObjectID;
@property NSInteger displayIndex;
@property BOOL canTrimCache;
@property (retain) NSFileManager *fileManager;

- (id)initWithAppID:(NSInteger)argAppID appObjectID:(NSManagedObjectID*)argAppObjectID delegate:(id)argDelegate displayIndex:(NSInteger)argDisplayIndex canTrimCache:(BOOL)argCanTrimCache;
- (void)cleanup;

- (NSArray*)cachedImages;

// File Methods
- (NSString*)pathForLibraryDirectory;
- (NSString*)pathForScreenshotsDirectory;

@end
