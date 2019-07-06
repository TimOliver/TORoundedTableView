//
//  TORoundedTableViewCapCell.m
//
//  Copyright 2016-2019 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TORoundedTableViewCapCell.h"

#import "TORoundedTableView.h"
#import "TORoundedTableViewCellBackground.h"

// ---

@interface TORoundedTableView ()
@property (nonatomic, strong) UIImage *roundedCornerImage;
@property (nonatomic, strong) UIImage *selectedRoundedCornerImage;
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
    self.backgroundView.backgroundColor = self.tableView.cellBackgroundColor;
    
    self.selectedBackgroundView.roundedCornerImage = self.tableView.selectedRoundedCornerImage;
    self.selectedBackgroundView.backgroundColor = self.tableView.cellSelectedBackgroundColor;
}

#pragma mark - Layout -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    
    // Because the background view is slightly smaller than the cell size by default,
    // the table background pokes through. Extend this cell by an extra point to explicitly
    // cover that gap
    if (self.topCornersRounded && !self.bottomCornersRounded) {
        CGRect backgroundViewFrame = CGRectZero;
        backgroundViewFrame = self.bounds;
        backgroundViewFrame.size.height += 1.0f;
        self.backgroundView.frame = backgroundViewFrame;
    }

    // Check if we're enabled or not by seeing if we are stretching edge-to-edge
    // Account for the invisible container view on iOS 10 and below
    UIView *containerView = self;
    if (@available(iOS 11.0, *)) { }
    else { containerView = self.superview; }

    if (containerView.frame.origin.x <= FLT_EPSILON) {
        return;
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
