//
//  TORoundedTableView.m
//
//  Copyright 2016 Timothy Oliver. All rights reserved.
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

#import "TORoundedTableView.h"
#import "TORoundedTableViewCell.h"

#define TOROUNDEDTABLEVIEW_SELECTED_BACKGROUND_COLOR [UIColor colorWithWhite:0.85f alpha:1.0f]

// Private declaration of internal cell properties
@interface TORoundedTableViewCell ()
- (void)setBackgroundImage:(UIImage *)image;
@end

// -------------------------------------------------------

@interface TORoundedTableView ()

@property (nonatomic, strong) UIImage *roundedCornerImage;
@property (nonatomic, strong) UIImage *selectedRoundedCornerImage;

// View Lifecyle
- (void)setUp;
- (void)loadCornerImages;

// Size Caluclations
- (CGFloat)widthForCurrentSizeClass;

// View resizing
- (void)resizeView:(UIView *)view forColumnWidth:(CGFloat)width centered:(BOOL)centered;

// Image Generation
+ (UIImage *)roundedCornerImageWithRadius:(CGFloat)radius color:(UIColor *)color;

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
    _sectionCornerRadius = 5.0f;
    _horizontalInset = 22.0f;
    _maximumWidth = 675.0f;
    _cellBackgroundColor = [UIColor whiteColor];
    _cellSelectedBackgroundColor = TOROUNDEDTABLEVIEW_SELECTED_BACKGROUND_COLOR;
    _accessoryHorizontalInset = MAXFLOAT;
    
    // On iOS 9 and up, table views will automatically drastically indent the cell
    // content so it won't look too strange on big screens such as iPad Pro. Since we're
    // manually controlling the content insets, we don't need this.
    if ([self respondsToSelector:NSSelectorFromString(@"setCellLayoutMarginsFollowReadableWidth:")]) {
        self.cellLayoutMarginsFollowReadableWidth = NO;
    }
}

- (void)loadCornerImages
{
    // Load the rounded image for default cell state
    if (!self.roundedCornerImage) {
        self.roundedCornerImage = [[self class] roundedCornerImageWithRadius:self.sectionCornerRadius
                                                                       color:self.cellBackgroundColor];
    }
    
    // Load the rounded image for when the cell is selected
    if (!self.selectedRoundedCornerImage) {
        self.selectedRoundedCornerImage = [[self class] roundedCornerImageWithRadius:self.sectionCornerRadius
                                                                               color:self.cellSelectedBackgroundColor];
    }
}

- (void)didMoveToSuperview
{
    if (self.superview == nil) {
        return;
    }
    
    [self loadCornerImages];
    [self layoutSubviews];
}

#pragma mark - Content Resizing / Layout -

- (CGFloat)widthForCurrentSizeClass
{
    CGFloat width = self.frame.size.width;
    width -= self.horizontalInset * 2.0f;
    
    if (self.maximumWidth > 0.0f) {
        width = MIN(self.maximumWidth, width);
    }

    return width;
}

- (void)resizeAccessoryView:(UITableViewHeaderFooterView *)view forColumnWidth:(CGFloat)columnWidth centered:(BOOL)centered
{
    // Resize to the same base width as the main cells
    [self resizeView:view forColumnWidth:columnWidth centered:centered];

    // Work out which inset to apply
    CGFloat inset = self.separatorInset.left;
    if (self.accessoryHorizontalInset < MAXFLOAT - FLT_EPSILON) {
        inset = self.accessoryHorizontalInset;
    }

    // Inset the text label
    CGRect frame = view.textLabel.frame;
    frame.origin.x = inset;
    view.textLabel.frame = frame;

    // Inset the detail text label
    frame = view.detailTextLabel.frame;
    frame.origin.x = inset;
    view.detailTextLabel.frame = frame;
}

- (void)resizeView:(UIView *)view forColumnWidth:(CGFloat)columnWidth centered:(BOOL)centered
{
    CGRect frame = view.frame;
    if (frame.size.width < columnWidth + FLT_EPSILON) { return; }
    frame.size.width = columnWidth;
    if (centered) { frame.origin.x = (self.frame.size.width - columnWidth) * 0.5f; }
    view.frame = frame;
}

#pragma mark - Layout Override -

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClassRegular) {
        return;
    }

    // Work out the width of the column
    // Loop through every subview related to 'UITableView' and resize it
    CGFloat columnWidth = [self widthForCurrentSizeClass];
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UITableViewHeaderFooterView class]])
        { // Resize the accessory view
            [self resizeAccessoryView:(UITableViewHeaderFooterView *)subview forColumnWidth:columnWidth centered:YES];
        }
    }
}

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];

    // Work out the width of the column
    // Loop through every subview related to 'UITableView' and resize it
    CGFloat columnWidth = [self widthForCurrentSizeClass];
    for (UIView *subview in self.subviews) {
        // Skip anything that looks like a scroll indicator
        if (subview.frame.size.width < self.frame.size.width - FLT_EPSILON) { continue; }

        // Resize all non-accessory views
        if (![subview isKindOfClass:[UITableViewHeaderFooterView class]]) {
            [self resizeView:subview forColumnWidth:columnWidth centered:YES];
        }
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    // Annoying hack. While other views automatically resize/reposition when adjusting between size classes,
    // the table footer view doesn't move back to its origin of 0.0
    // This forcibly resets the position of the footer view
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact && self.tableFooterView) {
        CGRect frame = self.tableFooterView.frame;
        frame.origin.x = 0.0f;
        self.tableFooterView.frame = frame;
    }
}

#pragma mark - Accessor Overrides -

- (void)setSectionCornerRadius:(CGFloat)sectionCornerRadius
{
    if (fabs(sectionCornerRadius - _sectionCornerRadius) < FLT_EPSILON) {
        return;
    }
    
    _sectionCornerRadius = sectionCornerRadius;

    self.roundedCornerImage = nil;
    self.selectedRoundedCornerImage = nil;
    
    [self loadCornerImages];
    [self reloadData];
}

- (void)setCellBackgroundColor:(UIColor *)cellBackgroundColor
{
    if (cellBackgroundColor == _cellBackgroundColor) {
        return;
    }
    
    _cellBackgroundColor = cellBackgroundColor;
    
    self.roundedCornerImage = nil;
    [self loadCornerImages];
    [self reloadData];
}

- (void)setCellSelectedBackgroundColor:(UIColor *)cellSelectedBackgroundColor
{
    if (_cellSelectedBackgroundColor == cellSelectedBackgroundColor) {
        return;
    }
    
    _cellSelectedBackgroundColor = cellSelectedBackgroundColor;
    
    self.selectedRoundedCornerImage = nil;
    [self loadCornerImages];
    [self reloadData];
}

#pragma mark - Image Generation -
+ (UIImage *)roundedCornerImageWithRadius:(CGFloat)radius color:(UIColor *)color
{
    UIImage *image = nil;
    
    // Make sure we have a valid color
    if (color == nil) { color = [UIColor whiteColor]; }
    
    // Rectangle if only one side is rounded, square otherwise
    CGRect rect = CGRectMake(0, 0, radius * 2, radius * 2);
    
    // Generation the image
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    {
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:rect];
        [color set];
        [bezierPath fill];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    // Make the image conform to the tint color
    return image;
}

@end
