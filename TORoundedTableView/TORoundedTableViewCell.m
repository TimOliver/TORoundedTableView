//
//  TORoundedTableViewCell.m
//  TORoundedTableView
//
//  Created by Tim Oliver on 11/30/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "TORoundedTableViewCell.h"

@interface TORoundedTableViewCell ()

- (void)sizeToFitWrapper;
- (CGRect)frameToFitWrapperWithFrame:(CGRect)frame;

@end

@implementation TORoundedTableViewCell

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self sizeToFitWrapper];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:[self frameToFitWrapperWithFrame:frame]];
}

- (CGRect)frameToFitWrapperWithFrame:(CGRect)frame
{
    CGFloat wrapperWidth = self.superview.frame.size.width;
    if (frame.size.width < wrapperWidth + FLT_EPSILON) {
        return frame;
    }
    
    frame.size.width = wrapperWidth;
    return frame;
}

- (void)sizeToFitWrapper
{
    self.frame = [self frameToFitWrapperWithFrame:self.frame];
}

@end
