//
//  TORoundedTableViewCapCell.h
//  TORoundedTableView
//
//  Created by Tim Oliver on 2/12/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "TORoundedTableViewCell.h"

@interface TORoundedTableViewCapCell : TORoundedTableViewCell

/** Shows the rounded edges on the top of the cell. */
@property (nonatomic, assign) BOOL topCornersRounded;

/** Shows the rounded edges on the bottom of the cell. */
@property (nonatomic, assign) BOOL bottomCornersRounded;

@end
