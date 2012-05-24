//
//  GVGalleryView.m
//  SeeTheApp
//
//  Created by goVertex on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GVGalleryView.h"


@implementation GVGalleryView

- (id)initWithFrame:(CGRect)argFrame
{
    if ((self = [super initWithFrame:argFrame]))
    {
        [self setCurrentRow:0];
        [self setContentOffset:CGPointMake(0.0f, 0.0f)];
        //NSLog(@"Setting galleryView Row to 0");
        [self setUnusedCells:[NSMutableSet set]];
        [self setUserInteractionEnabled:YES];
        [self setCanCancelContentTouches:YES];
    }
    return self;
}
- (void)displayRow:(NSInteger)argRow animated:(BOOL)argAnimated
{
    [self setContentOffset:CGPointMake(argRow * [self frame].size.width, 0.0f) animated:argAnimated];
    NSInteger actualRow = floor(([self contentOffset].x + 0.5f * [self frame].size.width) / [self frame].size.width);
    [self setCurrentRow:actualRow];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return YES;
}

- (GVGalleryViewCell*)dequeueCell
{
    if ([[self unusedCells] count] > 0)
    {
        GVGalleryViewCell *cell = (GVGalleryViewCell*)[[self unusedCells] anyObject];
        [[cell retain] autorelease];
        [[self unusedCells] removeObject:cell];
        return cell;
    }
    return nil;
}

- (void)reloadData
{
    //NSLog(@"GalleryView is reloading data");
            
    for (UIView *view in [self subviews])
    {
        if ([view tag] == kGVGalleryViewCell)
        {
            GVGalleryViewCell *cell = (GVGalleryViewCell*)view;
            [[self unusedCells] addObject:cell];
            [cell removeFromSuperview];
        }
    }
    
    [self layoutSubviews];
}

- (GVGalleryViewCell*)visibleCellForRow:(NSInteger)argRow
{
    NSArray *subviews = [self subviews];
    for (UIView *view in subviews)
    {
        if ([view tag] == kGVGalleryViewCell)
        {
            GVGalleryViewCell *cell = (GVGalleryViewCell*)view;
            if ([cell row] == argRow)
                return cell;
        }
    }
    return nil;
}

- (NSInteger)rowForOffset:(CGFloat)offset
{    
    return offset / [self rowWidth];
}

- (NSArray*)visibleCells
{
    NSMutableArray *array = [NSMutableArray array];
    NSArray *subviews = [self subviews];
    for (UIView *view in subviews)
    {
        if ([view tag] == kGVGalleryViewCell)
            [array addObject:(GVGalleryViewCell*)view];
    }
    return array;
}

- (NSArray*)rowsForVisibleCells
{
    NSMutableArray *array = [NSMutableArray array];
    NSArray *subviews = [self subviews];
    for (UIView *view in subviews)
    {
        if ([view tag] == kGVGalleryViewCell)
        {
            GVGalleryViewCell *cell = (GVGalleryViewCell*)view;
            [array addObject:[NSNumber numberWithInteger:[cell row]]];
        }
    }
    return array;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    #ifdef LOG_PrintContentOffset
        NSLog(@"Content Offset: %f", [self contentOffset].x);
    #endif
    
    NSInteger totalRows = [[self dataSource] numberOfRowsInGalleryView:self];
    
    [self setContentSize:CGSizeMake(totalRows * [self frame].size.width, [self frame].size.height)];
    
    // =========================================================================
    // Determine Visible Cells
    // =========================================================================
    
    CGFloat minimumVisibleOffset = [self contentOffset].x - [self frame].origin.x;
    CGFloat maximumVisibleOffset = minimumVisibleOffset + [[self superview] frame].size.width;
    
    CGFloat scanOffset = floor(minimumVisibleOffset / [self frame].size.width) * [self frame].size.width;
    
    if ([[NSThread currentThread] isEqual:[NSThread mainThread]] == NO)
        NSLog(@"Not main thread");
    
    NSMutableArray *rowsToDisplay = [[NSMutableArray alloc] init];
    
    while (scanOffset <= maximumVisibleOffset) 
    {
        NSNumber *rowToDisplay = [NSNumber numberWithInteger:floor(scanOffset / [self frame].size.width)];
        if ([rowToDisplay integerValue] >= 0 && [rowToDisplay integerValue] <= totalRows - 1)
        {
            [rowsToDisplay addObject:rowToDisplay];
        }
        scanOffset += [self frame].size.width;
    }
    
    // =========================================================================
    // Remove any unnecessary cells
    // =========================================================================
    
    NSArray *subviews = [self subviews];
    for (UIView *subview in subviews)
    {
        if ([subview tag] == kGVGalleryViewCell)
        {
            GVGalleryViewCell *cell = (GVGalleryViewCell*)subview;
            NSNumber *cellRow = [[NSNumber alloc] initWithInteger:[cell row]];
            if ([rowsToDisplay containsObject:cellRow])
            {
                [rowsToDisplay removeObject:cellRow];
            }
            else
            {
                [[self unusedCells] addObject:cell];
                [cell removeFromSuperview];
            }
            [cellRow release];
            [self setNeedsDisplay];
        }
    }
    
    // =========================================================================
    // Add any missing cells
    // =========================================================================
    
    for (NSNumber *rowToDisplay in rowsToDisplay)
    {
        GVGalleryViewCell *cell = [[self dataSource] galleryView:self cellForRow:[rowToDisplay integerValue]];
        [cell setCenter:CGPointMake(([rowToDisplay integerValue] + 0.5f) * [self frame].size.width, 0.5f * [self frame].size.height)];
        [self addSubview:cell];
        [self setNeedsDisplay];
    }
         
    [rowsToDisplay release];
    
    // =========================================================================
    // Check for header and footer
    // =========================================================================
    
    if ([self contentOffset].x <= [self frame].origin.x)
    {
        if (![self viewWithTag:kGVGalleryViewHeaderView])
        {
            #ifdef LOG_HeaderFooterRequests
                NSLog(@"Requesting HeaderView");
            #endif
            
            UIView *headerView = [[self dataSource] headerViewForGalleryView:self];
            [headerView setCenter:CGPointMake(-0.5f * [headerView frame].size.width, 0.5f * [self frame].size.height)];
            [self addSubview:headerView];
        }
    }
    
    if ([self contentOffset].x >= totalRows * [self frame].size.width - [[self superview] frame].size.width)
    {
        UIView *footerView = [self viewWithTag:kGVGalleryViewFooterView];
        if (!footerView)
        {
            #ifdef LOG_HeaderFooterRequests
                NSLog(@"Requesting FooterView");
            #endif
        
            footerView = [[self dataSource] footerViewForGalleryView:self];
            [self addSubview:footerView];
        }
        [footerView setCenter:CGPointMake(0.5f * [footerView frame].size.width + totalRows * [self frame].size.width, 0.5f * [self frame].size.height)];

        #ifdef LOG_FooterLocation
            NSLog(@"Footer Location: %f, %f", [[self viewWithTag:kGVGalleryViewFooterView ] center].x, [[self viewWithTag:kGVGalleryViewFooterView ] center].y);
        #endif                                                         
    }
    
    // =========================================================================
    // Check for a newly displayed row
    // =========================================================================
    
    NSInteger actualRow = floor(([self contentOffset].x + 0.5f * [self frame].size.width) / [self frame].size.width);
    if (actualRow >= 0 && actualRow != [self currentRow])
    {
        [self setCurrentRow:actualRow];
        NSNotification *galleryViewDidChangeRowNotification = [NSNotification notificationWithName:@"GalleryViewRowDidChangeNotification" object:self];
        [[NSNotificationQueue defaultQueue] enqueueNotification:galleryViewDidChangeRowNotification postingStyle:NSPostASAP coalesceMask:NSNotificationCoalescingOnName forModes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    }
}

@synthesize delegate;
@synthesize dataSource;
@synthesize unusedCells;
@synthesize rowWidth;
@synthesize currentRow;
@end
