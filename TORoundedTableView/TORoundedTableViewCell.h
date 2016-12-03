//
//  TORoundedTableViewCell.h
//  TORoundedTableView
//
//  Created by Tim Oliver on 11/30/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TORoundedTableViewCell : UITableViewCell

/** The parent table view */
@property (nonatomic, weak) UITableView *tableView;

/** Set the background color of the cell when selected */
@property (nonatomic, strong) UIColor *selectedBackgroundColor;


@end
