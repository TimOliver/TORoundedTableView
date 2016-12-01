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

- (void)setUpBackgroundViews
{
    Class class = [UIImageView class];
    if ([self.backgroundView isKindOfClass:class] && [self.selectedBackgroundView isKindOfClass:class]) {
        return;
    }
    
    // Configure the default background view
    self.backgroundView = [[UIImageView alloc] initWithImage:nil];
    self.backgroundView.layer.magnificationFilter = kCAFilterNearest;
    self.backgroundView.tintColor = [UIColor whiteColor];
    self.backgroundView.hidden = YES;
    
    // Configure the 'tapped' background view
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:nil];
    self.selectedBackgroundView.layer.magnificationFilter = kCAFilterNearest;
    self.selectedBackgroundView.tintColor = self.selectedBackgroundColor;
    self.selectedBackgroundView.backgroundColor = self.selectedBackgroundColor;
}

#pragma mark - Update Image State -
- (void)setBackgroundImage:(UIImage *)image
{
    // Set up the background views as image views
    [self setUpBackgroundViews];
    
    UIImageView *backgroundView = (UIImageView *)self.backgroundView;
    UIImageView *selectedBackgroundView = (UIImageView *)self.selectedBackgroundView;
    
    if (image && !backgroundView.image) {
        self.originalBackgroundColor = self.backgroundColor;
        self.backgroundColor = [UIColor clearColor];
        
        backgroundView.image = image;
        backgroundView.tintColor = self.originalBackgroundColor;
        
        selectedBackgroundView.image = image;
        selectedBackgroundView.backgroundColor = [UIColor clearColor];
        selectedBackgroundView.tintColor = self.selectedBackgroundColor;
        
        backgroundView.frame = self.bounds;
        selectedBackgroundView.frame = self.bounds;
        
        backgroundView.hidden = NO;
    }
    else if (!image && backgroundView.image) {
        self.backgroundColor = self.originalBackgroundColor ?: [UIColor whiteColor];
        backgroundView.image = nil;
        backgroundView.hidden = YES;
        
        selectedBackgroundView.image = nil;
        selectedBackgroundView.backgroundColor = self.selectedBackgroundColor;
    }
}

#pragma mark - Layout Overrides -

- (void)setFrame:(CGRect)frame
{
    // Clamp the width of the view to the width of the wrapper
    CGFloat wrapperWidth = self.superview.frame.size.width;
    frame.size.width = wrapperWidth;
    [super setFrame:frame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Search for any section exterior separator views that were added and hide them
    for (UIView *view in self.subviews) {
        if (NSStringFromClass(view.class).hash != 1141955748541228649U) { continue; } //_UITableViewCellSeparatorView

        CGFloat hairLineHeight = 1.0f / [UIScreen mainScreen].scale;
        CGFloat totalWidth = self.frame.size.width;
        
        CGRect frame = view.frame;
        if (frame.origin.x > FLT_EPSILON)                       { continue; } // Doesn't start at the very edge
        if (frame.size.height > hairLineHeight + FLT_EPSILON)   { continue; } // View is thicker than a hairline
        if (frame.size.width < totalWidth - FLT_EPSILON)        { continue; } // Doesn't span the entire length of cell
        
        self.exteriorSeparatorView = view;
        view.backgroundColor = [UIColor clearColor];
    }
}

@end
