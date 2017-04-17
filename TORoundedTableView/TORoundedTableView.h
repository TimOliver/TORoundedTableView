//
//  TORoundedTableView.h
//
//  Copyright 2016 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <UIKit/UIKit.h>

@class TORoundedTableViewCell;

@interface TORoundedTableView : UITableView

/** The distance from the edges of each side of the table view (Default is 22 points) */
@property (nonatomic, assign) CGFloat horizontalInset;

/** From the edge of the table view cells, the horizontal inset of the accessory views. (Defaults to `separatorInset.left`) */
@property (nonatomic, assign) CGFloat accessoryHorizontalInset;

/** The maximum width that the table content may be scale to (Default is 675) */
@property (nonatomic, assign) CGFloat maximumWidth;

/** The corner radius of each section (Default value is 5) */
@property (nonatomic, assign) CGFloat sectionCornerRadius;

/** The default background color of every cell (Default color is white) */
@property (nonatomic, strong) UIColor *cellBackgroundColor;

/** The default background color of each cell when tapped (Default color is light grey) */
@property (nonatomic, strong) UIColor *cellSelectedBackgroundColor;

@end
