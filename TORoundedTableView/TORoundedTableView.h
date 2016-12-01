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

@property (nonatomic, assign) CGFloat regularWidthFraction;
@property (nonatomic, assign) CGFloat maximumWidth;
@property (nonatomic, assign) CGFloat cornerRadius;

- (void)configureStyleForCell:(TORoundedTableViewCell *)cell firstInSection:(BOOL)first lastInSection:(BOOL)last;

@end
