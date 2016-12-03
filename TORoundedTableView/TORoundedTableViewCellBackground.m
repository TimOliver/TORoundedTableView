//
//  TORoundedTableBackgroundView.m
//  TORoundedTableView
//
//  Created by Tim Oliver on 12/2/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "TORoundedTableViewCellBackground.h"

typedef NS_ENUM(NSInteger, TORoundedTableViewCellBackgroundView) {
    TORoundedTableViewCellBackgroundViewTop,
    TORoundedTableViewCellBackgroundViewMiddle,
    TORoundedTableViewCellBackgroundViewBottom,
    TORoundedTableViewCellBackgroundViewNum
};

typedef NS_ENUM(NSInteger, TORoundedTableViewCellBackgroundCorner) {
    TORoundedTableViewCellBackgroundCornerTopLeft,
    TORoundedTableViewCellBackgroundCornerTopRight,
    TORoundedTableViewCellBackgroundCornerBottomRight,
    TORoundedTableViewCellBackgroundCornerBottomLeft,
    TORoundedTableViewCellBackgroundCornerNum
};

@interface TORoundedTableViewCellBackground ()

@property (nonatomic, strong) NSArray *views;
@property (nonatomic, strong) NSArray *cornerViews;

- (void)setUp;

@end

@implementation TORoundedTableViewCellBackground

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    self.backgroundColor = [UIColor clearColor];
    
    if (self.views == nil) {
        NSMutableArray *views = [NSMutableArray arrayWithCapacity:3];
        for (NSInteger i = 0; i < TORoundedTableViewCellBackgroundViewNum; i++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
            view.backgroundColor = [UIColor whiteColor];
            [views addObject:view];
            [self addSubview:view];
        }
        
        self.views = [NSArray arrayWithArray:views];
    }

    if (self.cornerViews == nil) {
        NSMutableArray *corners = [NSMutableArray arrayWithCapacity:4];
        for (NSInteger i = 0; i < TORoundedTableViewCellBackgroundCornerNum; i++) {
            UIImageView *cornerView = [[UIImageView alloc] init];
            cornerView.tintColor = [UIColor whiteColor];
            [corners addObject:cornerView];
            [self addSubview:cornerView];
        }
        
        self.cornerViews = [NSArray arrayWithArray:corners];
    }

}

#pragma mark - Layout -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frame = CGRectZero;
    
    //Layout top section
    UIImageView *topLeftImageView  = self.cornerViews[TORoundedTableViewCellBackgroundCornerTopLeft];
    UIImageView *topRightImageView = self.cornerViews[TORoundedTableViewCellBackgroundCornerTopRight];
    UIView *topView = self.views[TORoundedTableViewCellBackgroundViewTop];
    
    topLeftImageView.hidden = !self.topCornersRounded;
    topRightImageView.hidden = !self.topCornersRounded;
    topView.hidden = !self.topCornersRounded;
    
    if (self.topCornersRounded) {
        topLeftImageView.frame = (CGRect){CGPointZero, topLeftImageView.image.size};
        
        frame = topLeftImageView.frame;
        frame.origin.x = boundsSize.width - frame.size.width;
        topRightImageView.frame = frame;
        topRightImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
        
        frame.origin.x = CGRectGetMaxX(topLeftImageView.frame);
        frame.size.width = boundsSize.width - (frame.origin.x * 2);
        topView.frame = frame;
    }
    
    UIView *midView = self.views[TORoundedTableViewCellBackgroundViewMiddle];
    
    // Layout out the middle rect
    frame = self.bounds;
    if (self.topCornersRounded) {
        frame.origin.y += self.roundedCornerImage.size.height;
        frame.size.height -= self.roundedCornerImage.size.height;
    }
    
    if (self.bottomCornersRounded) {
        frame.size.height -= self.roundedCornerImage.size.height;
    }
    
    midView.frame = frame;
    
    // Layout bottom section
    UIImageView *bottomLeftImageView  = self.cornerViews[TORoundedTableViewCellBackgroundCornerBottomLeft];
    UIImageView *bottomRightImageView = self.cornerViews[TORoundedTableViewCellBackgroundCornerBottomRight];
    UIView *bottomView = self.views[TORoundedTableViewCellBackgroundViewBottom];
    
    bottomLeftImageView.hidden = !self.bottomCornersRounded;
    bottomRightImageView.hidden = !self.bottomCornersRounded;
    bottomView.hidden = !self.bottomCornersRounded;
    
    if (self.bottomCornersRounded) {
        frame = self.bounds;
        frame.origin.y = boundsSize.height - self.roundedCornerImage.size.height;
        frame.size = self.roundedCornerImage.size;
        bottomLeftImageView.frame = frame;
        bottomLeftImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * 1.5f);
        
        frame.origin.x = boundsSize.width - self.roundedCornerImage.size.width;
        bottomRightImageView.frame = frame;
        bottomRightImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
        
        frame.origin.x = self.roundedCornerImage.size.width;
        frame.size.width = (boundsSize.width - (self.roundedCornerImage.size.width * 2));
        bottomView.frame = frame;
    }
}

#pragma mark - Accessor -

- (void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:alpha];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    for (UIView *view in self.views) {
        view.backgroundColor = backgroundColor;
    }
    
    for (UIImageView *view in self.cornerViews) {
        view.tintColor = backgroundColor;
    }
}

- (void)setRoundedCornerImage:(UIImage *)roundedCornerImage
{
    if (_roundedCornerImage == roundedCornerImage) {
        return;
    }
    
    _roundedCornerImage = roundedCornerImage;
    
    for (UIImageView *imageView in self.cornerViews) {
        imageView.image = _roundedCornerImage;
    }
}

@end
