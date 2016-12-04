//
//  TORoundedTableViewCell.m
//  TORoundedTableView
//
//  Created by Tim Oliver on 11/30/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "TORoundedTableViewCell.h"

@implementation TORoundedTableViewCell

- (void)setFrame:(CGRect)frame
{
    // Clamp the width of the view to the width of the wrapper
    if (self.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClassCompact) {
        frame.size.width = self.superview.frame.size.width;
    }
    
    [super setFrame:frame];
}

@end
