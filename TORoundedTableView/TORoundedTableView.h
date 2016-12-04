//
//  TORoundedTableView.h
//  TORoundedTableView
//
//  Created by Tim Oliver on 29/11/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TORoundedTableViewCell;

@interface TORoundedTableView : UITableView

/** The distance from the edges of each side of the table view (Default is 22 points) */
@property (nonatomic, assign) CGFloat horizontalInset;

/** The maximum width that the table content may be scale to (Default is 675) */
@property (nonatomic, assign) CGFloat maximumWidth;

/** The corner radius of each section (Default value is 5) */
@property (nonatomic, assign) CGFloat sectionCornerRadius;

/** The default background color of every cell (Default color is white) */
@property (nonatomic, strong) UIColor *cellBackgroundColor;

/** The default background color of each cell when tapped (Default color is light grey) */
@property (nonatomic, strong) UIColor *cellSelectedBackgroundColor;

@end
