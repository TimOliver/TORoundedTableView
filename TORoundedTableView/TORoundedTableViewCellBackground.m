//
//  TORoundedTableViewCellBackground.m
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

/** 
 Layers are used to avoid `UITableViewCell`'s defualt functionality
 of making the background view transparent when it is tapped.
 */
@property (nonatomic, strong) NSArray<CALayer *> *layers;
@property (nonatomic, strong) NSArray<CALayer *> *cornerLayers;

- (void)setUp;
- (void)animateLayer:(CALayer *)layer forNewFrame:(CGRect)newFrame fromAnimation:(CAAnimation *)animation;

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
    [super setBackgroundColor: [UIColor clearColor]];
    
    if (self.layers == nil) {
        NSMutableArray *layers = [NSMutableArray arrayWithCapacity:3];
        for (NSInteger i = 0; i < TORoundedTableViewCellBackgroundViewNum; i++) {
            CALayer *layer = [[CALayer alloc] init];
            layer.backgroundColor = ([UIColor whiteColor].CGColor);
            layer.actions = @{@"position": [NSNull null], @"bounds": [NSNull null], @"hidden": [NSNull null]};
            [layers addObject:layer];
            [self.layer addSublayer:layer];
        }
        
        self.layers = [NSArray arrayWithArray:layers];
    }

    if (self.cornerLayers == nil) {
        NSMutableArray *corners = [NSMutableArray arrayWithCapacity:4];
        for (NSInteger i = 0; i < TORoundedTableViewCellBackgroundCornerNum; i++) {
            CALayer *cornerLayer = [[CALayer alloc] init];
            cornerLayer.actions = @{@"position": [NSNull null], @"bounds": [NSNull null], @"hidden": [NSNull null]};
            [corners addObject:cornerLayer];
            [self.layer addSublayer:cornerLayer];
        }
        
        self.cornerLayers = [NSArray arrayWithArray:corners];
    }
}

#pragma mark - Layout -

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Check if we're enabled or not by seeing if we are stretching edge-to-edge
    BOOL hideRoundedCorners = (self.superview.frame.origin.x <= FLT_EPSILON);

    CABasicAnimation *resizeAnimation = (CABasicAnimation *)[self.layer animationForKey:@"bounds.size"];
    if (resizeAnimation == nil) {
        resizeAnimation = (CABasicAnimation *)[self.layer animationForKey:@"bounds"];
    }
    
    CGSize boundsSize = self.bounds.size;
    CGRect frame = CGRectZero;
    
    CGSize imageSize = self.roundedCornerImage.size;
    CGSize cornerLayerSize = (CGSize){imageSize.width * 0.5f, imageSize.height * 0.5f};
    
    //Layout top section
    CALayer *topLeftCornerLayer  = self.cornerLayers[TORoundedTableViewCellBackgroundCornerTopLeft];
    CALayer *topRightCornerLayer = self.cornerLayers[TORoundedTableViewCellBackgroundCornerTopRight];
    CALayer *topLayer = self.layers[TORoundedTableViewCellBackgroundViewTop];
    
    topLeftCornerLayer.hidden  = !self.topCornersRounded || hideRoundedCorners;
    topRightCornerLayer.hidden = !self.topCornersRounded || hideRoundedCorners;
    topLayer.hidden            = !self.topCornersRounded || hideRoundedCorners;
    
    if (self.topCornersRounded && !hideRoundedCorners) {
        frame = (CGRect){CGPointZero, cornerLayerSize};
        [self animateLayer:topLeftCornerLayer forNewFrame:frame fromAnimation:resizeAnimation];
        topLeftCornerLayer.frame = frame;
        
        frame = topLeftCornerLayer.frame;
        frame.origin.x = boundsSize.width - frame.size.width;
        [self animateLayer:topRightCornerLayer forNewFrame:frame fromAnimation:resizeAnimation];
        topRightCornerLayer.frame = frame;
        
        frame.origin.x = CGRectGetMaxX(topLeftCornerLayer.frame);
        frame.size.width = boundsSize.width - (frame.origin.x * 2);
        [self animateLayer:topLayer forNewFrame:frame fromAnimation:resizeAnimation];
        topLayer.frame = frame;
    }
    
    CALayer *midLayer = self.layers[TORoundedTableViewCellBackgroundViewMiddle];
    
    // Layout out the middle rect
    frame = self.bounds;
    if (self.topCornersRounded && !hideRoundedCorners) {
        frame.origin.y += cornerLayerSize.height;
        frame.size.height -= cornerLayerSize.height;
    }
    
    if (self.bottomCornersRounded && !hideRoundedCorners) {
        frame.size.height -= cornerLayerSize.height;
    }
    
    [self animateLayer:midLayer forNewFrame:frame fromAnimation:resizeAnimation];
    midLayer.frame = frame;
    
    // Layout bottom section
    CALayer *bottomLeftCornerLayer  = self.cornerLayers[TORoundedTableViewCellBackgroundCornerBottomLeft];
    CALayer *bottomRightCornerLayer = self.cornerLayers[TORoundedTableViewCellBackgroundCornerBottomRight];
    CALayer *bottomLayer            = self.layers[TORoundedTableViewCellBackgroundViewBottom];
    
    bottomLeftCornerLayer.hidden    = !self.bottomCornersRounded || hideRoundedCorners;
    bottomRightCornerLayer.hidden   = !self.bottomCornersRounded || hideRoundedCorners;
    bottomLayer.hidden              = !self.bottomCornersRounded || hideRoundedCorners;
    
    if (self.bottomCornersRounded && !hideRoundedCorners) {
        frame = self.bounds;
        frame.origin.y = boundsSize.height - cornerLayerSize.height;
        frame.size = cornerLayerSize;
        [self animateLayer:bottomLeftCornerLayer forNewFrame:frame fromAnimation:resizeAnimation];
        bottomLeftCornerLayer.frame = frame;
        
        frame.origin.x = boundsSize.width - cornerLayerSize.width;
        [self animateLayer:bottomRightCornerLayer forNewFrame:frame fromAnimation:resizeAnimation];
        bottomRightCornerLayer.frame = frame;
        
        frame.origin.x = cornerLayerSize.width;
        frame.size.width = (boundsSize.width - (cornerLayerSize.width * 2));
        [self animateLayer:bottomLayer forNewFrame:frame fromAnimation:resizeAnimation];
        bottomLayer.frame = frame;
    }
}

- (void)animateLayer:(CALayer *)layer forNewFrame:(CGRect)newFrame fromAnimation:(CABasicAnimation *)animation
{
    /**
     If this view plays a resizing animation (For example, when doing a screen rotation), 
     those size animations aren't implicitly forwarded to these layers.
     As such, it's necessary to manually forward the animations to each layer.
     */
    
    if (animation == nil || self.hidden || self.alpha < FLT_EPSILON) {
        return;
    }
    
    // `layoutSubviews` gets called multiple times during a rotation.
    // If we've already set up the animations, don't apply them again as the
    // original ones will get cancelled
    if ([layer animationForKey:@"frame"]) {
        return;
    }
    
    CGRect oldFrame = layer.frame;
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    CGPoint oldPoint = (CGPoint){CGRectGetMidX(oldFrame), CGRectGetMidY(oldFrame)};
    positionAnimation.fromValue = [NSValue valueWithCGPoint:oldPoint];
    CGPoint newPoint = (CGPoint){CGRectGetMidX(newFrame), CGRectGetMidY(newFrame)};
    positionAnimation.toValue = [NSValue valueWithCGPoint:newPoint];
    
    CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.fromValue = [NSValue valueWithCGRect:(CGRect){CGPointZero, oldFrame.size}];
    boundsAnimation.toValue = [NSValue valueWithCGRect:(CGRect){CGPointZero, newFrame.size}];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[positionAnimation, boundsAnimation];
    animationGroup.duration = animation.duration;
    animationGroup.timingFunction = animation.timingFunction;
    [layer addAnimation:animationGroup forKey:@"frame"];
}

#pragma mark - Accessor -

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:[UIColor clearColor]];
    
    for (CALayer *layer in self.layers) {
        layer.backgroundColor = backgroundColor.CGColor;
    }
}

- (void)setRoundedCornerImage:(UIImage *)roundedCornerImage
{
    if (_roundedCornerImage == roundedCornerImage) {
        return;
    }
    
    _roundedCornerImage = roundedCornerImage;
    
    CGSize imageSize = _roundedCornerImage.size;
    CGSize layerSize = (CGSize){imageSize.width * 0.5f, imageSize.height * 0.5f};
    CGSize contentsSize = (CGSize){0.5f, 0.5f};
    
    for (NSInteger i = 0; i < TORoundedTableViewCellBackgroundCornerNum; i++) {
        CALayer *layer = self.cornerLayers[i];
        layer.contents = (id)_roundedCornerImage.CGImage;
        layer.frame = (CGRect){CGPointZero, layerSize};
        
        switch (i) {
            case TORoundedTableViewCellBackgroundCornerTopLeft:
                layer.contentsRect = (CGRect){CGPointZero, contentsSize};
                break;
            case TORoundedTableViewCellBackgroundCornerTopRight:
                layer.contentsRect = (CGRect){{0.5f, 0.0f}, contentsSize};
                break;
            case TORoundedTableViewCellBackgroundCornerBottomLeft:
                layer.contentsRect = (CGRect){{0.0f, 0.5f}, contentsSize};
                break;
            case TORoundedTableViewCellBackgroundCornerBottomRight:
                layer.contentsRect = (CGRect){{0.5f, 0.5f}, contentsSize};
                break;
        }
    }
}

@end
