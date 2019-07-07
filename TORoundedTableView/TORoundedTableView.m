//
//  TORoundedTableView.m
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

#import "TORoundedTableView.h"
#import "TORoundedTableViewCell.h"
#import "TORoundedTableViewCapCell.h"

#define TOROUNDEDTABLEVIEW_SELECTED_BACKGROUND_COLOR_LIGHT [UIColor colorWithWhite:0.85f alpha:1.0f]
#define TOROUNDEDTABLEVIEW_SELECTED_BACKGROUND_COLOR_DARK  [UIColor colorWithRed:0.227f green:0.227f blue:0.235f alpha:1.0f]

// -------------------------------------------------------

// Private declaration of internal cell properties
@interface TORoundedTableViewCell ()
- (void)setBackgroundImage:(UIImage *)image;
@end

// -------------------------------------------------------
// These functions handle resizing the subviews to fit centered horizontally when presented in regular mode.
// Because they are in a for-loop that is iterated once per animation frame, they've been made inline functions
// in an attempt to minimize as much of the Objective-C overhead as possible.

static inline void TORoundedTableViewResizeView(UIView *view, TORoundedTableView *tableView, CGFloat columnWidth, BOOL centered)
{
    CGRect frame = view.frame;

    // Cap the width to the available columnc width, and center if need be
    if (frame.size.width < columnWidth + FLT_EPSILON) { return; }
    frame.size.width = columnWidth;
    if (centered) { frame.origin.x = (tableView.frame.size.width - columnWidth) * 0.5f; }

    // Adjust horizontal insets for devices with additional safe area requirements (eg, iPhone XS Max)
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) { safeAreaInsets = tableView.safeAreaInsets; }
    if (safeAreaInsets.right > 0.0) { frame.size.width -= safeAreaInsets.right; }
    if (safeAreaInsets.left > 0.0) { frame.origin.x += safeAreaInsets.left; frame.size.width -= safeAreaInsets.left; }

    view.frame = frame;
}

static inline void TORoundedTableViewResizeAccessoryView(UITableViewHeaderFooterView *view, TORoundedTableView *tableView,
                                                         CGFloat columnWidth, CGFloat inset, BOOL centered)
{
    // Work out which inset to apply
    CGFloat horizontalInset = tableView.separatorInset.left;
    if (inset < MAXFLOAT - FLT_EPSILON) {
        horizontalInset = inset;
    }

    // Inset the text label
    CGRect frame = view.textLabel.frame;
    frame.origin.x = horizontalInset;
    view.textLabel.frame = frame;

    // Inset the detail text label
    frame = view.detailTextLabel.frame;
    frame.origin.x = horizontalInset;
    view.detailTextLabel.frame = frame;
}

// -------------------------------------------------------

@interface TORoundedTableViewCapCell (Private)

- (void)refreshBackgroundContent;

@end

// -------------------------------------------------------

@interface TORoundedTableView ()

@property (nonatomic, strong) UIImage *roundedCornerImage;
@property (nonatomic, strong) UIImage *selectedRoundedCornerImage;

@end

// -------------------------------------------------------

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
    _showRoundedCorners = YES;
    _sectionCornerRadius = 7.0f;
    _horizontalInset = 18.0f;
    _maximumWidth = 675.0f;
    _accessoryHorizontalInset = MAXFLOAT;

    // Set the default color values of the cell backgrounds
    [self setDefaultCellBackgroundColors];

    // Load the corner images immediately in case we need layout data before even
    // being added to the view hierarchy
    [self loadCornerImages];

    // On iOS 9 and up, table views will automatically drastically indent the cell
    // content so it won't look too strange on big screens such as iPad Pro. Since we're
    // manually controlling the content insets, we don't need this.
    if (@available(iOS 9.0, *)) {
        self.cellLayoutMarginsFollowReadableWidth = NO;
    }
}

- (void)setDefaultCellBackgroundColors
{
    // If nil, reset the default color of a non selected cell
    if (_cellBackgroundColor == nil) {
        _cellBackgroundColor = [UIColor whiteColor];

        // Set the dynamic color in iOS 13
        if (@available(iOS 13.0, *)) {
            #ifdef __IPHONE_13_0
            _cellBackgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
            #endif
        }
    }

    // If nil, reset the selected cell color
    if (_cellSelectedBackgroundColor == nil) {
        _cellSelectedBackgroundColor = TOROUNDEDTABLEVIEW_SELECTED_BACKGROUND_COLOR_LIGHT;

        // Because the real cell selection color isn't public, we'll need to "simulate" the
        // native colors by providing our own
        if (@available(iOS 13.0, *)) {
            #ifdef __IPHONE_13_0
            _cellSelectedBackgroundColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
                BOOL isDarkMode = traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
                return isDarkMode ? TOROUNDEDTABLEVIEW_SELECTED_BACKGROUND_COLOR_DARK : TOROUNDEDTABLEVIEW_SELECTED_BACKGROUND_COLOR_LIGHT;
            }];
            #endif
        }
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

#pragma mark - Layout Override -

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Skip if we've disabled showing the rounded corners
    if (!self.showRoundedCorners) {
        return;
    }

    // Work out the width of the column
    // Loop through every subview related to 'UITableView' and resize it
    // ----
    // This unfortunately needs to be done on every animation frame of the table view
    // to ensure the default behaviour doesn't revert.
    CGFloat columnWidth = [self widthForCurrentSizeClass];
    Class accessoryViewClass = [UITableViewHeaderFooterView class];
    Class imageViewClass = [UIImageView class];
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:imageViewClass]) { continue; } // Skip anything that looks like a scroll indicator

        // Resize the view
        TORoundedTableViewResizeView(subview, self, columnWidth, YES);

        // Re-align the accessory view
        if ([subview isKindOfClass:accessoryViewClass]) {
            TORoundedTableViewResizeAccessoryView((UITableViewHeaderFooterView *)subview, self, columnWidth, self.accessoryHorizontalInset, YES);
        }
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    // Annoying hack. While other views automatically resize/reposition when adjusting between size classes,
    // the table footer view doesn't move back to its origin of 0.0
    // This forcibly resets the position of the footer view
    if (!self.showRoundedCorners && self.tableFooterView) {
        CGRect frame = self.tableFooterView.frame;
        frame.origin.x = 0.0f;
        self.tableFooterView.frame = frame;
    }

    // On iOS 13, if a system wide appearence change happens, flush all the images and reload the lot
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            [self reloadColorAppearenceInContentViews];
        }
    }
#endif
}

- (void)reloadColorAppearenceInContentViews
{
    // Purge the current corner images
    self.roundedCornerImage = nil;
    self.selectedRoundedCornerImage = nil;

    // Reload new ones off the new color settings
    [self loadCornerImages];

    // Reload the table
    [self reloadData];
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

    // Set the new color, and reset back to default it it was nil
    _cellBackgroundColor = cellBackgroundColor;
    if (_cellBackgroundColor == nil) { [self setDefaultCellBackgroundColors]; }

    // Delete the current rounded image we have now and regenerate
    self.roundedCornerImage = nil;
    [self loadCornerImages];

    // Reload the visible cells so the change is immediately visible
    [self reloadRowsAtIndexPaths:self.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setCellSelectedBackgroundColor:(UIColor *)cellSelectedBackgroundColor
{
    if (_cellSelectedBackgroundColor == cellSelectedBackgroundColor) {
        return;
    }

    // Update the selected cell color and revert if it was nil
    _cellSelectedBackgroundColor = cellSelectedBackgroundColor;
    if (_cellSelectedBackgroundColor == nil) { [self setDefaultCellBackgroundColors]; }

    // Delete the original rounded corner image and regenerate
    self.selectedRoundedCornerImage = nil;
    [self loadCornerImages];

    // Update the visible cells to reflect the new change
    [self reloadRowsAtIndexPaths:self.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Image Generation -
+ (UIImage *)roundedCornerImageWithRadius:(CGFloat)radius color:(UIColor *)color
{
    UIImage *image = nil;

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
