//
//  TORoundedTableView.m
//  TORoundedTableView
//
//  Created by Tim Oliver on 29/11/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "TORoundedTableView.h"
#import "TORoundedTableViewCell.h"

// Private declaration of internal cell properties
@interface TORoundedTableViewCell ()
- (void)setBackgroundImage:(UIImage *)image;
@end

// -------------------------------------------------------

@interface TORoundedTableView ()

@property (nonatomic, strong) UIImage *topBackgroundImage;
@property (nonatomic, strong) UIImage *bottomBackgroundImage;
@property (nonatomic, strong) UIImage *topAndBottomBackgroundImage;

// View Lifecyle
- (void)setUp;
- (void)loadBackgroundImages;

// Size Caluclations
- (CGFloat)widthForCurrentSizeClass;

// View resizing
- (void)resizeView:(UIView *)view forColumnWidth:(CGFloat)width centered:(BOOL)centered;

// Image Generation
+ (UIImage *)resizabledRoundedImageWithRadius:(CGFloat)radius topRounded:(BOOL)top bottomRounded:(BOOL)bottom;

@end

@implementation TORoundedTableView

#pragma mark - View Creation -

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:UITableViewStyleGrouped]) {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame style:UITableViewStyleGrouped]) {
        [self setUp];
    }
    
    return self;
}

- (instancetype)init
{
    if (self = [super initWithFrame:CGRectZero style:UITableViewStyleGrouped]) {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        if (self.style != UITableViewStyleGrouped) {
            // We can't override this property after creation, so trigger an exception
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                    reason:@"Must be initialized with UITableViewStyleGrouped style."
                                   userInfo:nil] raise];
        }
        
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    _sectionCornerRadius = 8.0f;
}

- (void)loadBackgroundImages
{
    // Load the top image
    if (!self.topBackgroundImage) {
        self.topBackgroundImage = [[self class] resizabledRoundedImageWithRadius:self.sectionCornerRadius topRounded:YES bottomRounded:NO];
    }
    
    // Load the singular image
    if (!self.topAndBottomBackgroundImage) {
        self.topAndBottomBackgroundImage = [[self class] resizabledRoundedImageWithRadius:self.sectionCornerRadius topRounded:YES bottomRounded:YES];
    }
    
    // Load the bottom image
    if (!self.bottomBackgroundImage) {
        self.bottomBackgroundImage = [[self class] resizabledRoundedImageWithRadius:self.sectionCornerRadius topRounded:NO bottomRounded:YES];
    }
}

- (void)didMoveToSuperview
{
    if (self.superview == nil) {
        return;
    }
    
    [self loadBackgroundImages];
}

#pragma mark - Content Resizing / Layout -

- (CGFloat)widthForCurrentSizeClass
{
    return self.frame.size.width - 100.0f;
}

- (void)resizeView:(UIView *)view forColumnWidth:(CGFloat)columnWidth centered:(BOOL)centered
{
    CGRect frame = view.frame;
    if (frame.size.width < columnWidth + FLT_EPSILON) { return; }
    frame.size.width = columnWidth;
    if (centered) { frame.origin.x = (self.frame.size.width - columnWidth) * 0.5f; }
    view.frame = frame;
}

#pragma mark - Cell Configuration -
- (void)configureStyleForCell:(TORoundedTableViewCell *)cell firstInSection:(BOOL)first lastInSection:(BOOL)last
{
    UIImage *image = nil;
    
    if (first && last) { image = self.topAndBottomBackgroundImage; }
    else if (first)    { image = self.topBackgroundImage; }
    else if (last)     { image = self.bottomBackgroundImage; }
    
    [cell setBackgroundImage:image];
}

#pragma mark - Layout Override -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Work out the width of the column
    CGFloat columnWidth = [self widthForCurrentSizeClass];
    
    // Loop through every subview related to 'UITableView' and resize it
    for (UIView *subview in self.subviews) {
        if (![subview isKindOfClass:[UIImageView class]]) { // Resize everything but the scroll indicators
            [self resizeView:subview forColumnWidth:columnWidth centered:YES];
        }
    }
}

#pragma mark - Accessor Overrides -

- (void)setSectionCornerRadius:(CGFloat)sectionCornerRadius
{
    if (fabs(sectionCornerRadius - _sectionCornerRadius) < FLT_EPSILON) {
        return;
    }
    
    _sectionCornerRadius = sectionCornerRadius;
    
    self.topBackgroundImage = nil;
    self.bottomBackgroundImage = nil;
    self.topAndBottomBackgroundImage = nil;
    
    [self loadBackgroundImages];
    [self reloadData];
}

#pragma mark - Image Generation -
+ (UIImage *)resizabledRoundedImageWithRadius:(CGFloat)radius topRounded:(BOOL)top bottomRounded:(BOOL)bottom
{
    UIImage *image = nil;
    
    // Rectangle if only one side is rounded, square otherwise
    CGRect rect = CGRectMake(0, 0, (radius * 2) + 2, radius * (top && bottom ? 2 : 1) + 2);
    
    // Work out the mask for which corners to be rounded
    NSUInteger cornerMask = bottom ? (UIRectCornerBottomLeft|UIRectCornerBottomRight) : 0;
    cornerMask |= top ? (UIRectCornerTopLeft|UIRectCornerTopRight) : 0;
    
    // Generation the image
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    {
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                         byRoundingCorners:cornerMask
                                                               cornerRadii:CGSizeMake(radius, radius)];
        
        [[UIColor whiteColor] set];
        [bezierPath fill];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();

    // Work out the resiable insets
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top = top ? radius : 1.0f;
    insets.left = radius;
    insets.right = radius;
    insets.bottom = bottom ? radius : 1.0f;
    
    // Make the image resizable
    image = [image resizableImageWithCapInsets:insets];
    
    // Make the image conform to the tint color
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
