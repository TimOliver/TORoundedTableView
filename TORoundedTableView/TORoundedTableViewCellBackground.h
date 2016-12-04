//
//  TORoundedTableBackgroundView.h
//  TORoundedTableView
//
//  Created by Tim Oliver on 12/2/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TORoundedTableViewCellBackground : UIView

/** Shows the rounded corners on the top of the cell. */
@property (nonatomic, assign) BOOL topCornersRounded;

/** Shows the rounded corners on the bottom of the cell. */
@property (nonatomic, assign) BOOL bottomCornersRounded;

/** The circle image used for the rounded corners. */
@property (nonatomic, strong) UIImage *roundedCornerImage;

@end
