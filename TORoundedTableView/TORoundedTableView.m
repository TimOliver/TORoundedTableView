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

@property (nonatomic, strong) UIImage *roundedCornerImage;

// View Lifecyle
- (void)setUp;
- (void)loadCornerImage;

// Size Caluclations
- (CGFloat)widthForCurrentSizeClass;

// View resizing
- (void)resizeView:(UIView *)view forColumnWidth:(CGFloat)width centered:(BOOL)centered;

// Image Generation
+ (UIImage *)roundedCornerImageWithRadius:(CGFloat)radius;

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
    _horizontalInset = 22.0f;
    _maximumWidth = 675.0f;
}

- (void)loadCornerImage
{
    // Load the top image
    if (!self.roundedCornerImage) {
        self.roundedCornerImage = [[self class] roundedCornerImageWithRadius:self.sectionCornerRadius];
    }
}

- (void)didMoveToSuperview
{
    if (self.superview == nil) {
        return;
    }
    
    [self loadCornerImage];
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

    // Work out the width of the column
    CGFloat columnWidth = [self widthForCurrentSizeClass];
    
    // Loop through every subview related to 'UITableView' and resize it
    Class imageViewClass = [UIImageView class];
    for (UIView *subview in self.subviews) {
        if (![subview isKindOfClass:imageViewClass]) { // Resize everything but the scroll indicators
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
    
    self.roundedCornerImage = nil;
    
    [self loadCornerImage];
    [self reloadData];
}

#pragma mark - Image Generation -
+ (UIImage *)roundedCornerImageWithRadius:(CGFloat)radius
{
    UIImage *image = nil;
    
    // Rectangle if only one side is rounded, square otherwise
    CGRect rect = CGRectMake(0, 0, radius * 2, radius * 2);
    CGSize size = (CGSize){radius, radius};
    
    // Generation the image
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    {
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
        [[UIColor whiteColor] set];
        [bezierPath fill];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    // Make the image conform to the tint color
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
