//
//  TORoundedTableViewCell.m
//
//  Copyright 2016-2019 Timothy Oliver. All rights reserved.
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

#import "TORoundedTableViewCell.h"
#import "TORoundedTableView.h"

static Class _tableViewClass = NULL;

@implementation TORoundedTableViewCell

- (void)setFrame:(CGRect)frame
{
    /** On iOS 10 and down, table cells are kept in `UITableViewWrapperView`,
     which abstracts away our control of the frame from `TORoundedTableView`.
     As such, it's necessary to override `setFrame` and force the cell width to match
     that container view.

     On iOS 11, that is no longer the case. Cells are direct subviews of the table view.
     As such, this isn't necessary anymore.
     */
    if (!_tableViewClass) { _tableViewClass = [TORoundedTableView class]; }
    if (![self.superview isKindOfClass:_tableViewClass]) {
        frame.size.width = self.superview.frame.size.width;
    }

    // Not sure why, but on iOS 13, the bound origin is not set to 0
    // in order to offset the safe area. Force this back to zero if need be.
    CGRect bounds = self.contentView.bounds;
    bounds.origin = CGPointZero;
    self.contentView.bounds = bounds;

    // Apply the frame value back up to the super class
    [super setFrame:frame];
}

@end
