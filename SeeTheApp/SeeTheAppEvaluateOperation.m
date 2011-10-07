//
//  SeeTheAppEvaluateOperation.m
//  SeeTheApp
//
//  Created by goVertex on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SeeTheAppEvaluateOperation.h"

@implementation SeeTheAppEvaluateOperation

- (id)initWithCurrentRow:(NSInteger)argCurrentRow delegate:(NSObject<SeeTheAppEvaluateOperationDelegate>*)argDelegate
{
    if ((self = [super init]))
    {
        [self setDelegate:argDelegate];
        [self setCurrentRow:argCurrentRow];
    }
    return self;
}

- (void)main
{    
    if ([self isCancelled]) return;
    
    releasePool = [[NSAutoreleasePool alloc] init];

#ifdef LOG_EvaluationOperation
    NSLog(@"-------------------------------------------- Eval Op Start -------------------------------------------------------");
#endif
    
    // Create File Manager
    NSFileManager *tempFileManager = [[NSFileManager alloc] init];
    [self setFileManager:tempFileManager];
    [tempFileManager release];
    
    // Get the Max Cache Size
    NSInteger maxCachedImages = [[[NSUserDefaults standardUserDefaults] valueForKey:STADefaultsCacheSizeKey] integerValue];
    
    // Index to download
    NSInteger displayIndexToDownload = -1;
    BOOL canTrimCache = NO;
    
    // =======================================================================================================================
    // Evaluate Current Cache State
    // =======================================================================================================================
    
    NSArray *cachedImagesArray = [self cachedImages];
        
    NSInteger displayIndexOfNextImageToCheck = [self currentRow];
    
    NSInteger displayIndexOfPreviousImageToCheck = [self currentRow] - 2;
    
#ifdef LOG_EvaluationOperation
    NSLog(@"CachedImagesArray Count: %d", [cachedImagesArray count]);
    NSLog(@"Current Row: %d", [self currentRow]);
#endif
    
    for (int cacheImageCounter = 0; cacheImageCounter < maxCachedImages; cacheImageCounter++)
    {
        if ([self currentRow] == 0)
        {
            // Start with displayIndex 0 and increment only
            NSNumber *imageForDisplayIndex = [NSNumber numberWithInteger:cacheImageCounter];
            if ([cachedImagesArray containsObject:imageForDisplayIndex] == NO)
            {
                displayIndexToDownload = cacheImageCounter;
                break;
            }
        }
        else
        {   
            if (cacheImageCounter == 0)
            {
                // Check if current image
                NSNumber *currentImage = [NSNumber numberWithInteger:([self currentRow] - 1)];
                if ([cachedImagesArray containsObject:currentImage] == NO)
                {
                    displayIndexToDownload = [self currentRow] - 1;
                    break;
                }
            }
            else if (cacheImageCounter % 3)  // Next Image
            {
                NSNumber *nextImage = [NSNumber numberWithInteger:displayIndexOfNextImageToCheck];
                if ([cachedImagesArray containsObject:nextImage] == NO)
                {
                    
                    #ifdef LOG_EvaluationOperation
                        NSLog(@"Check for Image: %d  cached: NO", [nextImage integerValue]);
                    #endif
                    // Download nextImage
                    displayIndexToDownload = displayIndexOfNextImageToCheck;
                    break;
                }
                else
                {
                    #ifdef LOG_EvaluationOperation
                        NSLog(@"Check for Image: %d  cached: YES", [nextImage integerValue]);
                    #endif
                }
                displayIndexOfNextImageToCheck++;
            }
            else // Previous Image
            {
                if (displayIndexOfPreviousImageToCheck > 0)
                {
                    NSNumber *previousImage = [NSNumber numberWithInteger:displayIndexOfPreviousImageToCheck];
                    if ([cachedImagesArray containsObject:previousImage] == NO)
                    {
                        
                        #ifdef LOG_EvaluationOperation
                            NSLog(@"Check for Image: %d  cached: NO", [previousImage integerValue]);
                        #endif
                                                
                        // Download previousImage
                        displayIndexToDownload = displayIndexOfPreviousImageToCheck;
                        break;
                    }
                    else
                    {
                        #ifdef LOG_EvaluationOperation
                            NSLog(@"Check for Image: %d  cached: YES", [previousImage integerValue]);
                        #endif
                    }
                }
                displayIndexOfPreviousImageToCheck--;
            }
        }
    }
    
    #ifdef LOG_EvaluationOperation
        NSLog(@"Eval says download image: %d", displayIndexToDownload);
    #endif
    
    // =======================================================================================================================
    // Determine Appropriate Action
    // =======================================================================================================================
    
    if (displayIndexToDownload >= 0)
    {        
        NSDictionary *fileSystemAttributes = [[self fileManager] attributesOfFileSystemForPath:[self pathForLibraryDirectory] error:NULL];
        
        unsigned long long int fileSystemSpaceAvailable = [[fileSystemAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
        
        if ([cachedImagesArray count] < maxCachedImages && fileSystemSpaceAvailable < 1000000)
        {
            
            #ifdef LOG_EvaluationOperation
                NSLog(@"Cache is disk limited");
            #endif
            
            NSInteger cacheHighLimit = [self currentRow] + floor(2.0f * [cachedImagesArray count] / 3.0f);
            
            NSInteger cacheLowLimit = [self currentRow] - floor(1.0f * [cachedImagesArray count] / 3.0f);
            if (cacheLowLimit < 1)
                cacheLowLimit = 1;

            if (displayIndexToDownload >= cacheLowLimit && displayIndexToDownload <= cacheHighLimit)
            {
                // Download that image
                canTrimCache = YES;
            }
            else
            {
                displayIndexToDownload = -1;
            }            
        }
        else
        {
            if ([cachedImagesArray count] >= 120)
                canTrimCache = YES;
        }
    }
    
#ifdef LOG_EvaluationOperation
    if (canTrimCache == YES)
        NSLog(@"Eval operation says trim cache");
    else
        NSLog(@"Eval operation says do NOT trim cache");
#endif
    
    if ([self isCancelled])
    {
        [self cleanup];
        return;
    }
    
    // =======================================================================================================================
    // Notify Delegate of Next Action
    // =======================================================================================================================
    
    NSDictionary *evaluationResult = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:[self currentRow]], @"Row", [NSNumber numberWithInteger:displayIndexToDownload], @"Index", [NSNumber numberWithBool:canTrimCache], @"CanTrimCache", nil];
    
    [[self delegate] performSelectorOnMainThread:@selector(evaluateOperationFinishedWithRowAndIndex:) withObject:evaluationResult waitUntilDone:YES];
    
    [self cleanup];
}

- (void)cleanup
{
    
#ifdef LOG_EvaluationOperation
    NSLog(@"-------------------------------------------- Eval Op Start -------------------------------------------------------");
#endif
    
    if (pathForLibraryDirectory_gv)
        [pathForLibraryDirectory_gv release];
    
    if (pathForScreenshotsDirectory_gv)
        [pathForScreenshotsDirectory_gv release];
    
    [self setFileManager:nil];
    
    [releasePool drain];
}

#pragma mark - Other Methods

- (NSArray*)cachedImages
{
    // ==============================================================================================
    // Create an ordered array of all displayIndex values currently in cache
    // ==============================================================================================
    
    NSMutableArray *cachedImagesArray = [NSMutableArray array];
    
    NSArray *screenshotFileNames = [[self fileManager] contentsOfDirectoryAtPath:[self pathForScreenshotsDirectory] error:NULL];
    
    for (NSString *fileName in screenshotFileNames)
    {
        NSInteger fileDisplayIndex = [[fileName stringByDeletingPathExtension] integerValue];
        [cachedImagesArray addObject:[NSNumber numberWithInteger:fileDisplayIndex]];
    }
    
    NSSortDescriptor *displayIndexSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"integerValue" ascending:YES];
    [cachedImagesArray sortUsingDescriptors:[NSArray arrayWithObject:displayIndexSortDescriptor]];
    
    return cachedImagesArray;
}

#pragma mark - File Methods

- (NSString*)pathForLibraryDirectory
{
    if (pathForLibraryDirectory_gv)
        return pathForLibraryDirectory_gv;
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    pathForLibraryDirectory_gv = [[searchPaths objectAtIndex:0] retain];
    return pathForLibraryDirectory_gv;
}

- (NSString*)pathForScreenshotsDirectory
{
    if (pathForScreenshotsDirectory_gv)
        return pathForScreenshotsDirectory_gv;
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [searchPaths objectAtIndex:0];
    pathForScreenshotsDirectory_gv = [[libraryPath stringByAppendingPathComponent:@"STAScreenshots"] retain];
    return pathForScreenshotsDirectory_gv;
}

#pragma mark - Property Synthesis

@synthesize delegate;
@synthesize currentRow;
@synthesize fileManager;

@end
