//
//  TORoundedTableViewCell.m
//  TORoundedTableView
//
//  Created by Tim Oliver on 11/30/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "TORoundedTableViewCell.h"

#define TOROUNDEDTABLEVIEW_DEFAULT_SELECTED_COLOR [UIColor colorWithWhite:0.85f alpha:1.0f]

@interface TORoundedTableViewCell ()

/** Keep a copy of the original background color, since it needs to be clear for images */
@property (nonatomic, strong) UIColor *originalBackgroundColor;

/** Hang onto a reference to the exterior separator if we need to restore it. */
@property (nonatomic, weak) UIView *exteriorSeparatorView;

/** Set up */
- (void)setUp;

/** Set up the background views */
- (void)setUpBackgroundViews;

/** Change the background to an image, or back to the original color */
- (void)setBackgroundImage:(UIImage *)image;

@end

@implementation TORoundedTableViewCell

#pragma mark - Set Up -
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    self.backgroundColor = [UIColor whiteColor];
    _selectedBackgroundColor = TOROUNDEDTABLEVIEW_DEFAULT_SELECTED_COLOR;

}

//- (void)setUpBackgroundViews
//{
//    Class class = [UIImageView class];
//    if ([self.backgroundView isKindOfClass:class] && [self.selectedBackgroundView isKindOfClass:class]) {
//        return;
//    }
//    
//    // Configure the default background view
//    self.backgroundView = [[UIImageView alloc] initWithImage:nil];
//    self.backgroundView.layer.magnificationFilter = kCAFilterNearest;
//    self.backgroundView.tintColor = [UIColor whiteColor];
//    self.backgroundView.hidden = YES;
//    
//    // Configure the 'tapped' background view
//    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:nil];
//    self.selectedBackgroundView.layer.magnificationFilter = kCAFilterNearest;
//    self.selectedBackgroundView.tintColor = self.selectedBackgroundColor;
//    self.selectedBackgroundView.backgroundColor = self.selectedBackgroundColor;
//}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (self.superview == nil || self.tableView) {
        return;
    }
    
    // Work out our parent table view
    UIView *superview = self.superview;
    do {
        if ([superview isKindOfClass:[UITableView class]]) {
            self.tableView = (UITableView *)superview;
            break;
        }
    } while ((superview = superview.superview));
}

#pragma mark - Update Image State -
- (void)setBackgroundImage:(UIImage *)image
{
//    UIImageView *backgroundView = (UIImageView *)self.backgroundView;
//    UIImageView *selectedBackgroundView = (UIImageView *)self.selectedBackgroundView;
//    
//    if (image && backgroundView.image != image) {
//        UIColor *clearColor = [UIColor clearColor];
//        if (self.backgroundColor != clearColor) {
//            self.originalBackgroundColor = self.backgroundColor;
//        }
//        self.backgroundColor = clearColor;
//        
//        backgroundView.image = image;
//        backgroundView.tintColor = self.originalBackgroundColor;
//        backgroundView.hidden = NO;
//        
//        selectedBackgroundView.image = image;
//        selectedBackgroundView.backgroundColor = clearColor;
//    }
//    else {
//        self.backgroundColor = self.originalBackgroundColor ?: [UIColor whiteColor];
//        backgroundView.image = nil;
//        backgroundView.hidden = YES;
//        
//        selectedBackgroundView.image = nil;
//        selectedBackgroundView.backgroundColor = self.selectedBackgroundColor;
//    }
}

#pragma mark - Layout Overrides -

- (void)setFrame:(CGRect)frame
{
    // Clamp the width of the view to the width of the wrapper
    frame.size.width = self.superview.frame.size.width;
    [super setFrame:frame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    if (!self.backgroundView.hidden) {
//        CGRect backgroundViewFrame = self.backgroundView.frame;
//        backgroundViewFrame = self.bounds;
//        backgroundViewFrame.size.height += 1.0f;
//        self.backgroundView.frame = backgroundViewFrame;
//    }
//    
//    // Search for any section exterior separator views that were added and hide them
//    for (UIView *view in self.subviews) {
//        if (!(NSStringFromClass(view.class).hash == 1141955748541228649U)) { continue; } //_UITableViewCellSeparatorView
//
//        CGRect frame = view.frame;
//        if (frame.origin.x > FLT_EPSILON)             { continue; } // Doesn't start at the very edge
//        if (frame.size.height > 1.0f + FLT_EPSILON)   { continue; } // View is thicker than a hairline
//        
//        self.exteriorSeparatorView = view;
//        view.backgroundColor = [UIColor clearColor];
//    }
}

@end
