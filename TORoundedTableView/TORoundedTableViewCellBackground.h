//
//  TORoundedTableBackgroundView.h
//  TORoundedTableView
//
//  Created by Tim Oliver on 12/2/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TORoundedTableViewCellBackground : UIView

@property (nonatomic, strong) UIImage *roundedCornerImage;

@property (nonatomic, assign) BOOL topCornersRounded;
@property (nonatomic, assign) BOOL bottomCornersRounded;

@end
