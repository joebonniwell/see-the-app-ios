//
//  GVGalleryView.h
//  SeeTheApp
//
//  Created by goVertex on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GVGalleryViewCell.h"

@protocol GVGalleryViewDataSource;
@protocol GVGalleryViewDelegate;

@interface GVGalleryView : UIScrollView 
{    
    id delegate;
    
    NSObject<GVGalleryViewDataSource> *dataSource;
    
    NSMutableSet *unusedCells;
    
    CGFloat rowWidth;
    
    NSInteger currentRow;
}

@property (nonatomic, assign) id<GVGalleryViewDelegate, UIScrollViewDelegate> delegate;

@property (nonatomic, assign) NSObject<GVGalleryViewDataSource> *dataSource;

@property (nonatomic, retain) NSMutableSet *unusedCells;

@property (nonatomic) CGFloat rowWidth;

@property NSInteger currentRow;

- (GVGalleryViewCell*)dequeueCell;
- (GVGalleryViewCell*)visibleCellForRow:(NSInteger)argRow;
- (void)reloadData;

@end

@protocol GVGalleryViewDataSource <NSObject>

- (NSInteger)numberOfRowsInGalleryView:(GVGalleryView*)argGalleryView;
- (GVGalleryViewCell*)galleryView:(GVGalleryView*)argGalleryView cellForRow:(NSInteger)argRow;
- (UIView*)headerViewForGalleryView:(GVGalleryView*)argGalleryView;
- (UIView*)footerViewForGalleryView:(GVGalleryView*)argGalleryView;

@end

@protocol GVGalleryViewDelegate <NSObject>

- (void)didUpdateDisplayRow:(NSInteger)argRow;

@end