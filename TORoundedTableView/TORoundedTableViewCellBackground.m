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

/** 
 Layers are used to avoid `UITableViewCell`'s defualt functionality
 of making the background view transparent when it is tapped.
 */
@property (nonatomic, strong) NSArray<CALayer *> *layers;
@property (nonatomic, strong) NSArray<CALayer *> *cornerLayers;

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
    [super setBackgroundColor: [UIColor clearColor]];
    
    if (self.layers == nil) {
        NSMutableArray *layers = [NSMutableArray arrayWithCapacity:3];
        for (NSInteger i = 0; i < TORoundedTableViewCellBackgroundViewNum; i++) {
            CALayer *layer = [[CALayer alloc] init];
            layer.backgroundColor = ([UIColor whiteColor].CGColor);
            [layers addObject:layer];
            [self.layer addSublayer:layer];
        }
        
        self.layers = [NSArray arrayWithArray:layers];
    }

    if (self.cornerLayers == nil) {
        NSMutableArray *corners = [NSMutableArray arrayWithCapacity:4];
        for (NSInteger i = 0; i < TORoundedTableViewCellBackgroundCornerNum; i++) {
            CALayer *cornerLayer = [[CALayer alloc] init];
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
    
    CGSize boundsSize = self.bounds.size;
    CGRect frame = CGRectZero;
    
    CGSize imageSize = self.roundedCornerImage.size;
    CGSize cornerLayerSize = (CGSize){imageSize.width * 0.5f, imageSize.height * 0.5f};
    
    //Layout top section
    CALayer *topLeftCornerLayer  = self.cornerLayers[TORoundedTableViewCellBackgroundCornerTopLeft];
    CALayer *topRightCornerLayer = self.cornerLayers[TORoundedTableViewCellBackgroundCornerTopRight];
    CALayer *topLayer = self.layers[TORoundedTableViewCellBackgroundViewTop];
    
    topLeftCornerLayer.hidden = !self.topCornersRounded;
    topRightCornerLayer.hidden = !self.topCornersRounded;
    topLayer.hidden = !self.topCornersRounded;
    
    if (self.topCornersRounded) {
        topLeftCornerLayer.frame = (CGRect){CGPointZero, cornerLayerSize};
        
        frame = topLeftCornerLayer.frame;
        frame.origin.x = boundsSize.width - frame.size.width;
        topRightCornerLayer.frame = frame;
        
        frame.origin.x = CGRectGetMaxX(topLeftCornerLayer.frame);
        frame.size.width = boundsSize.width - (frame.origin.x * 2);
        topLayer.frame = frame;
    }
    
    CALayer *midLayer = self.layers[TORoundedTableViewCellBackgroundViewMiddle];
    
    // Layout out the middle rect
    frame = self.bounds;
    if (self.topCornersRounded) {
        frame.origin.y += cornerLayerSize.height;
        frame.size.height -= cornerLayerSize.height;
    }
    
    if (self.bottomCornersRounded) {
        frame.size.height -= cornerLayerSize.height;
    }
    
    midLayer.frame = frame;
    
    // Layout bottom section
    CALayer *bottomLeftCornerLayer  = self.cornerLayers[TORoundedTableViewCellBackgroundCornerBottomLeft];
    CALayer *bottomRightCornerLayer = self.cornerLayers[TORoundedTableViewCellBackgroundCornerBottomRight];
    CALayer *bottomLayer            = self.layers[TORoundedTableViewCellBackgroundViewBottom];
    
    bottomLeftCornerLayer.hidden    = !self.bottomCornersRounded;
    bottomRightCornerLayer.hidden   = !self.bottomCornersRounded;
    bottomLayer.hidden              = !self.bottomCornersRounded;
    
    if (self.bottomCornersRounded) {
        frame = self.bounds;
        frame.origin.y = boundsSize.height - cornerLayerSize.height;
        frame.size = cornerLayerSize;
        bottomLeftCornerLayer.frame = frame;
        
        frame.origin.x = boundsSize.width - cornerLayerSize.width;
        bottomRightCornerLayer.frame = frame;
        
        frame.origin.x = cornerLayerSize.width;
        frame.size.width = (boundsSize.width - (cornerLayerSize.width * 2));
        bottomLayer.frame = frame;
    }
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
