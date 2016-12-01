//
//  TORoundedTableView.m
//  TORoundedTableView
//
//  Created by Tim Oliver on 29/11/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "TORoundedTableView.h"

@interface TORoundedTableView ()

@property (nonatomic, strong) UIImage *topBackgroundImage;
@property (nonatomic, strong) UIImage *bottomBackgroundImage;
@property (nonatomic, strong) UIImage *topAndBottomBackgroundImage;

@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, strong) NSArray *previousVisibleCells;

// View Lifecyle
- (void)setUp;
- (void)loadBackgroundImages;

// Table View Introspection
- (UIView *)wrapperViewForTable;

// Size Caluclations
- (CGFloat)widthForCurrentSizeClass;

// View resizing
- (void)resizeWrapperView:(UIView *)wrapperView forColumnWidth:(CGFloat)columnWidth;
- (void)resizeAuxiliaryViewsInWrapperView:(UIView *)wrapperView forColumnWidth:(CGFloat)width;
- (void)resizeView:(UIView *)view forColumnWidth:(CGFloat)width;

// Table cell configuration
- (void)removeExteriorCellSeparatorViewsFromCell:(UITableViewCell *)cell;
- (void)configureBackgroundViewsForCell:(UITableViewCell *)cell;
- (void)configureVisibleTableViewCellsInWrapperView:(UIView *)wrapperView withColumnWidth:(CGFloat)columnWidth;
- (void)configureStyleForTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// Image Generation
+ (UIImage *)resizabledRoundedImageWithRadius:(CGFloat)radius topRounded:(BOOL)top bottomRounded:(BOOL)bottom;
+ (UIImage *)singlePixelImage;

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
    _regularWidthFraction = 0.8f;
    _cornerRadius = 8.0f;
}

- (void)loadBackgroundImages
{
    // Load the top image
    if (!self.topBackgroundImage) {
        self.topBackgroundImage = [[self class] resizabledRoundedImageWithRadius:self.cornerRadius topRounded:YES bottomRounded:NO];
    }
    
    // Load the singular image
    if (!self.topAndBottomBackgroundImage) {
        self.topAndBottomBackgroundImage = [[self class] resizabledRoundedImageWithRadius:self.cornerRadius topRounded:YES bottomRounded:YES];
    }
    
    // Load the bottom image
    if (!self.bottomBackgroundImage) {
        self.bottomBackgroundImage = [[self class] resizabledRoundedImageWithRadius:self.cornerRadius topRounded:NO bottomRounded:YES];
    }
    
    // Load the solid image
    if (!self.backgroundImage) {
        self.backgroundImage = [[self class] singlePixelImage];
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

- (UIView *)wrapperViewForTable
{
    UIView *wrapperView = nil;
    for (UIView *view in self.subviews) {
        NSUInteger hash = NSStringFromClass([view class]).hash;
        if (hash == (NSUInteger)10216744557202100403U) { // UITableViewWrapperView
            wrapperView = view;
            break;
        }
    }
    
    return wrapperView;
}

- (CGFloat)widthForCurrentSizeClass
{
    return self.frame.size.width * self.regularWidthFraction;
}

- (void)resizeView:(UIView *)view forColumnWidth:(CGFloat)width
{
    CGRect frame = view.frame;
    if (frame.size.width < width + FLT_EPSILON) { return; }
    frame.size.width = width;
    view.frame = frame;
}

- (void)resizeWrapperView:(UIView *)wrapperView forColumnWidth:(CGFloat)columnWidth
{
    CGRect frame = wrapperView.frame;
    if (frame.size.width < columnWidth + FLT_EPSILON) { return; }
    frame.size.width = columnWidth;
    frame.origin.x = (self.frame.size.width - columnWidth) * 0.5f;
    wrapperView.frame = frame;
}

- (void)resizeAuxiliaryViewsInWrapperView:(UIView *)wrapperView forColumnWidth:(CGFloat)width
{
    for (UIView *view in wrapperView.subviews) {
        // skip table cells; we'll handle those later
        if ([view isKindOfClass:[UITableViewCell class]]) {
            continue;
        }
        
        [self resizeView:view forColumnWidth:width];
    }
}

- (void)removeExteriorCellSeparatorViewsFromCell:(UITableViewCell *)cell
{
    CGFloat hairLineHeight = 1.0f / [UIScreen mainScreen].scale;
    CGFloat totalWidth = cell.frame.size.width;
    
    for (UIView *view in cell.subviews) {
        CGRect frame = view.frame;
        if (frame.origin.x > FLT_EPSILON)                       { continue; } // Doesn't start at the very edge
        if (frame.size.height > hairLineHeight + FLT_EPSILON)   { continue; } // View is thicker than a hairline
        if (frame.size.width < totalWidth - FLT_EPSILON)        { continue; } // Doesn't span the entire length of cell
        [view removeFromSuperview];
    }
}

- (void)configureBackgroundViewsForCell:(UITableViewCell *)cell
{
    Class class = [UIImageView class];
    if ([cell.backgroundView isKindOfClass:class] && [cell.selectedBackgroundView isKindOfClass:class]) {
        return;
    }
    
    // Configure the default background view
    cell.backgroundView = [[UIImageView alloc] initWithImage:self.backgroundImage];
    cell.backgroundView.layer.magnificationFilter = kCAFilterNearest;
    cell.backgroundView.tintColor = [UIColor whiteColor];
    cell.backgroundView.hidden = YES;
    
    // Configure the 'tapped' background view
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:self.backgroundImage];
    cell.selectedBackgroundView.layer.magnificationFilter = kCAFilterNearest;
    cell.selectedBackgroundView.tintColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
}

- (void)configureStyleForTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    BOOL firstCellInSection = indexPath.row == 0;
    BOOL lastCellInSection = indexPath.row == ([self numberOfRowsInSection:indexPath.section]-1);
    
    if (!firstCellInSection && !lastCellInSection) {
        cell.backgroundColor = [UIColor whiteColor];
        cell.backgroundView.hidden = YES;
        return;
    }
    
    // Remove the section border separator lines
    [self removeExteriorCellSeparatorViewsFromCell:cell];
    
    UIImageView *backgroundView = (UIImageView *)cell.backgroundView;
    UIImageView *selectedBackgroundView = (UIImageView *)cell.selectedBackgroundView;
    
    UIImage *image = firstCellInSection ? self.topBackgroundImage : self.bottomBackgroundImage;
    if (firstCellInSection && lastCellInSection) {
        image = self.topAndBottomBackgroundImage;
    }
    
    if (!backgroundView.hidden && image == backgroundView.image) { return; }
    
    backgroundView.image = image;
    selectedBackgroundView.image = image;
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.hidden = NO;
}

- (void)configureVisibleTableViewCellsInWrapperView:(UIView *)wrapperView withColumnWidth:(CGFloat)columnWidth
{
    NSArray *indexPaths = [self indexPathsForVisibleRows];
    BOOL pendingChanges = ![self.previousVisibleCells isEqualToArray:indexPaths];
    
    if (!pendingChanges) {
        return;
    }
    
    for (NSIndexPath *indexPath in indexPaths) {
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        if (cell == nil) { continue; }
    
        [self resizeView:cell forColumnWidth:columnWidth];
        [self configureBackgroundViewsForCell:cell];
        [self configureStyleForTableViewCell:cell atIndexPath:indexPath];
    }
    
    self.previousVisibleCells = indexPaths;
}

#pragma mark - Layout Override -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //Loop through the subviews to find the wrapper view
    UIView *wrapperView = [self wrapperViewForTable];
    if (!wrapperView) { return; }
    
    CGFloat columnWidth = [self widthForCurrentSizeClass];

    // Set the width / inset of the wrapper view
    [self resizeWrapperView:wrapperView forColumnWidth:columnWidth];
    
    // Resize all non-table cell views
    //[self resizeAuxiliaryViewsInWrapperView:wrapperView forColumnWidth:columnWidth];

    // Restyle and reconfigure each table view cell
    //[self configureVisibleTableViewCellsInWrapperView:wrapperView withColumnWidth:columnWidth];
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

+ (UIImage *)singlePixelImage
{
    UIImage *image = nil;
    CGRect rect = (CGRect){0, 0, 1.0f, 1.0f};
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0f);
    {
        [[UIColor whiteColor] set];
        [[UIBezierPath bezierPathWithRect:rect] fill];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
