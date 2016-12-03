//
//  TORoundedTableViewCapCell.m
//  TORoundedTableView
//
//  Created by Tim Oliver on 2/12/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "TORoundedTableViewCapCell.h"

#import "TORoundedTableView.h"
#import "TORoundedTableViewCellBackground.h"

#define TOROUNDEDTABLEVIEW_DEFAULT_SELECTED_COLOR [UIColor colorWithWhite:0.85f alpha:1.0f]

// ---

@interface TORoundedTableView ()
@property (nonatomic, strong) UIImage *roundedCornerImage;
@end

// ---

@interface TORoundedTableViewCapCell ()

/** The table view that we belong to */
@property (nonatomic, weak) TORoundedTableView *tableView;

/** Hang onto a reference to the exterior separator if we need to restore it. */
@property (nonatomic, weak) UIView *topSeparatorView;
@property (nonatomic, weak) UIView *bottomSeparatorView;

@property (nonatomic, strong) TORoundedTableViewCellBackground *backgroundView;
@property (nonatomic, strong) TORoundedTableViewCellBackground *selectedBackgroundView;

- (void)setUp;

@end

@implementation TORoundedTableViewCapCell

@synthesize backgroundView = __roundedCellBackgroundView;
@synthesize selectedBackgroundView = _roundedSelectedCellBackgroundView;

- (void)setUp
{
    if (self.backgroundColor != [UIColor clearColor]) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    if (self.backgroundView == nil) {
        self.backgroundView = [[TORoundedTableViewCellBackground alloc] init];
        [super setBackgroundView:self.backgroundView];
    }
    
    if (self.selectedBackgroundView == nil) {
        self.selectedBackgroundView = [[TORoundedTableViewCellBackground alloc] init];
        self.selectedBackgroundView.backgroundColor = TOROUNDEDTABLEVIEW_DEFAULT_SELECTED_COLOR;
        [super setSelectedBackgroundView:self.selectedBackgroundView];
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    [self setUp];
    
    if (self.superview == nil || self.tableView) {
        return;
    }
    
    // Work out our parent table view
    UIView *superview = self.superview;
    do {
        if ([superview isKindOfClass:[UITableView class]]) {
            self.tableView = (TORoundedTableView *)superview;
            break;
        }
    } while ((superview = superview.superview));
    
    self.backgroundView.roundedCornerImage = self.tableView.roundedCornerImage;
    self.selectedBackgroundView.roundedCornerImage = self.tableView.roundedCornerImage;
}

#pragma mark - Layout -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Because the background view is slightly smaller than the cell size by default,
    // the table background pokes through. Extend this cell by an extra point to explicitly
    // cover that gap
    if (self.topCornersRounded && !self.bottomCornersRounded) {
        CGRect backgroundViewFrame = self.backgroundView.frame;
        backgroundViewFrame = self.bounds;
        backgroundViewFrame.size.height += 1.0f;
        self.backgroundView.frame = backgroundViewFrame;
    }
    
    // Hide the exterior separator view
    // Search for any section exterior separator views that were added and hide them
    for (UIView *view in self.subviews) {
        CGRect frame = view.frame;
        if (frame.size.height > 1.0f + FLT_EPSILON) { continue; } // View is thicker than a hairline
        if (frame.origin.x > FLT_EPSILON)           { continue; } // Doesn't start at the very edge

        // The top hairline
        if (self.topCornersRounded && frame.origin.y < FLT_EPSILON) {
            self.topSeparatorView = view;
            view.backgroundColor = [UIColor clearColor];
        }
        
        // The bottom hairline
        if (self.bottomCornersRounded && frame.origin.y > CGRectGetHeight(self.bounds) - (1.0f + FLT_EPSILON)) {
            self.bottomSeparatorView = view;
            view.backgroundColor = [UIColor clearColor];
        }
    }
}

#pragma mark - Accessors -

- (void)setTopCornersRounded:(BOOL)topCornersRounded
{
    [self setUp];
    
    _topCornersRounded = topCornersRounded;
 
    self.selectedBackgroundView.topCornersRounded = _topCornersRounded;
    self.backgroundView.topCornersRounded = _topCornersRounded;
}

- (void)setBottomCornersRounded:(BOOL)bottomCornersRounded
{
    [self setUp];
    
    _bottomCornersRounded = bottomCornersRounded;
    
    self.selectedBackgroundView.bottomCornersRounded = _bottomCornersRounded;
    self.backgroundView.bottomCornersRounded = _bottomCornersRounded;
}

@end
