//
//  SeeTheAppDownloadOperation.m
//  SeeTheApp
//
//  Created by goVertex on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SeeTheAppDownloadOperation.h"
#import "SBJson.h"

@implementation SeeTheAppDownloadOperation

- (id)initWithAppID:(NSInteger)argAppID appObjectID:(NSManagedObjectID*)argAppObjectID delegate:(id)argDelegate displayIndex:(NSInteger)argDisplayIndex canTrimCache:(BOOL)argCanTrimCache
{
    if ((self = [super init]))
    {
        [self setDelegate:argDelegate];
        [self setAppID:argAppID];
        [self setAppObjectID:argAppObjectID];
        [self setDisplayIndex:argDisplayIndex];
        [self setCanTrimCache:argCanTrimCache];
    }
    return self;
}

- (void)main
{   
    //NSLog(@"Download Operation Starting");
    
    if ([self isCancelled]) return;
    
    releasePool = [[NSAutoreleasePool alloc] init];
    
    // =======================================================================================================================
    // Perform iTunes Lookup
    // =======================================================================================================================
    
    NSString *iTunesLookupString = [[NSString alloc] initWithFormat:@"http://itunes.apple.com/lookup?id=%ld", [self appID]];
    NSURL *iTunesLookupURL = [[NSURL alloc] initWithString:iTunesLookupString];
    NSURLRequest *iTunesDataRequest = [[NSURLRequest alloc] initWithURL:iTunesLookupURL];
    
    NSData *iTunesResponseData = [NSURLConnection sendSynchronousRequest:iTunesDataRequest returningResponse:nil error:nil];
    
    [iTunesLookupString release];
    [iTunesLookupURL release];
    [iTunesDataRequest release];
    
    if ([self isCancelled])
    {
        [self cleanup];
        return;
    }
    
    if (!iTunesResponseData)
    {
        #ifdef LOG_DownloadFailures
            NSLog(@"Invalid iTunes Response Data");
        #endif
        [[self delegate] performSelectorOnMainThread:@selector(downloadFailed) withObject:nil waitUntilDone:NO];
        [self cleanup];
        return;
    }
    
    // =======================================================================================================================
    // Parse Lookup Data
    // =======================================================================================================================
    
    responseString = [[NSString alloc] initWithData:iTunesResponseData encoding:NSUTF8StringEncoding];
    
    NSDictionary *appInfoResults = [responseString JSONValue];
    
    if ([self isCancelled])
    {
        [self cleanup];
        return;
    }
    
    if ([[appInfoResults valueForKey:@"resultCount"] integerValue] == 0)
    {
        #ifdef LOG_DownloadFailures
            NSLog(@"No lookup results");
        #endif
        [[self delegate] performSelectorOnMainThread:@selector(downloadFailed) withObject:nil waitUntilDone:NO];
        [self cleanup];
        return;
    }
    
    NSDictionary *appInfo = [[appInfoResults valueForKey:@"results"] objectAtIndex:0];
        
    NSString *appURLString = [appInfo valueForKey:@"trackViewUrl"];
        
    NSString *screenshotsKey;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        screenshotsKey = @"ipadScreenshotUrls";
    else
        screenshotsKey = @"screenshotUrls";
        
    NSArray *screenshotsArray = [appInfo valueForKey:screenshotsKey];
    
    if ([self isCancelled])
    {
        [self cleanup];
        return;
    }
    
    if ([screenshotsArray count] == 0)
    {
        #ifdef LOG_DownloadFailures
            NSLog(@"No screenshots");
        #endif
        [[self delegate] performSelectorOnMainThread:@selector(downloadFailed) withObject:nil waitUntilDone:NO];
        [self cleanup];
        return;
    }
    
    // =======================================================================================================================
    // Download Screenshot
    // =======================================================================================================================
    
    NSString *screenshotURLString = [screenshotsArray objectAtIndex:0];
    NSURL *screenshotURL = [NSURL URLWithString:screenshotURLString];
    NSURLRequest *screenshotRequest = [[NSURLRequest alloc] initWithURL:screenshotURL];
            
    NSData *screenshotImageData = [NSURLConnection sendSynchronousRequest:screenshotRequest returningResponse:nil error:nil];
            
    [screenshotRequest release];
         
    if ([self isCancelled])
    {
        [self cleanup];
        return;
    }
    
    if (!screenshotImageData)
    {
        #ifdef LOG_DownloadFailures
            NSLog(@"Invalid or missing screenshot data");
        #endif
        [[self delegate] performSelectorOnMainThread:@selector(downloadFailed) withObject:nil waitUntilDone:NO];
        [self cleanup];
        return;
    }

    // =======================================================================================================================
    // Save Screenshot and Trim Cache
    // =======================================================================================================================
    
    NSString *imagePath = [[self pathForScreenshotsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.imgdata", [self displayIndex]]];
    
    NSFileManager *tempFileManager = [[NSFileManager alloc] init];
    [self setFileManager:tempFileManager];
    [tempFileManager release];
    
    BOOL imageSaveResult = [[self fileManager] createFileAtPath:imagePath contents:screenshotImageData attributes:nil];
    
    if ([self canTrimCache])
    {
        NSArray *cachedImages = [self cachedImages];
    
        NSMutableArray *cachedImagesToRemove = [NSMutableArray array];
    
        NSInteger currentRow = [[self delegate] currentRow];
    
        NSInteger highCacheLimit = currentRow + 80;
        NSInteger lowCacheLimit = currentRow - 40;
        if (lowCacheLimit < 1)
            lowCacheLimit = 1;
    
        // Determine the images to remove
        for (NSNumber *cachedImage in cachedImages)
        {
            if ([cachedImage integerValue] > highCacheLimit || [cachedImage integerValue] < lowCacheLimit)
                [cachedImagesToRemove addObject:cachedImage];
        }
        
        // Remove those images
        if ([cachedImagesToRemove count] > 0)
        {
            for (NSNumber *cachedImageToRemove in cachedImagesToRemove)
            {
                NSString *pathForCachedImageToRemove = [[self pathForScreenshotsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.imgdata", [cachedImageToRemove integerValue]]];
                [[self fileManager] removeItemAtPath:pathForCachedImageToRemove error:NULL];
            }
        }
    }
   
    if (imageSaveResult == NO && [self isCancelled] == NO)
    {
        BOOL secondImageSaveResult = [[self fileManager] createFileAtPath:imagePath contents:screenshotImageData attributes:nil];
        
        if (secondImageSaveResult == NO)
        {
            #ifdef LOG_DownloadFailures
                NSLog(@"Failed to save");
            #endif
            [[self delegate] performSelectorOnMainThread:@selector(downloadFailed) withObject:nil waitUntilDone:NO];
            [self cleanup];
            return;
        }
    }
        
    // =======================================================================================================================
    // Notify Delegate of Success
    // =======================================================================================================================
    
    NSDictionary *appInfoDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                [NSNumber numberWithInteger:[self appID]], STAAppInfoAppID,
                                                [NSNumber numberWithInteger:[self displayIndex]], STAAppInfoDisplayIndex,
                                                [self appObjectID], STAAppInfoObjectID,
                                                imagePath, STAAppInfoImagePath,
                                                appURLString, STAAppInfoAppURL,
                                                nil];
            
    [[self delegate] performSelectorOnMainThread:@selector(imageDownloadedForApp:) withObject:appInfoDictionary waitUntilDone:YES];
          
    [appInfoDictionary release];
    
    [self cleanup];
}

- (void)cleanup
{
    if (pathForLibraryDirectory_gv)
        [pathForLibraryDirectory_gv release];
    
    if (pathForScreenshotsDirectory_gv)
        [pathForScreenshotsDirectory_gv release];
    
    if (responseString)
        [responseString release];
    
    [self setAppObjectID:nil];
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
@synthesize appID;
@synthesize appObjectID;
@synthesize displayIndex;
@synthesize canTrimCache;
@synthesize fileManager;
@end
