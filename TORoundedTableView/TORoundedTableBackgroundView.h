//
//  TORoundedTableBackgroundView.h
//  TORoundedTableView
//
//  Created by Tim Oliver on 12/2/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TORoundedTableBackgroundView : UIView

@property (nonatomic, strong) UIImage *roundedCornerImage;

@property (nonatomic, assign) BOOL showTopCorners;
@property (nonatomic, assign) BOOL showBottomCorners;

@end
