//
//  TORoundedTableView.h
//  TORoundedTableView
//
//  Created by Tim Oliver on 29/11/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TORoundedTableView : UITableView

@property (nonatomic, assign) CGFloat regularWidthFraction;
@property (nonatomic, assign) CGFloat compactPadding;
@property (nonatomic, assign) CGFloat maximumWidth;

@end
