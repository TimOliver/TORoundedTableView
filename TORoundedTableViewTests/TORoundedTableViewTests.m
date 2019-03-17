//
//  TORoundedTableViewTests.m
//  TORoundedTableViewTests
//
//  Created by Tim Oliver on 17/3/19.
//  Copyright © 2019 Tim Oliver. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TORoundedTableView.h"

@interface TORoundedTableViewTests : XCTestCase

@end

@implementation TORoundedTableViewTests

- (void)testBasicCreation {
    UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){0,0,320,480}];

    TORoundedTableView *tableView = [[TORoundedTableView alloc] initWithFrame:containerView.bounds];
    [containerView addSubview:tableView];

    XCTAssert(tableView != nil);
    XCTAssert(tableView.superview == containerView);
}

- (void)testDefaultValues {
    // Ensure default properties are correctly set on object creation
    TORoundedTableView *tableView = [[TORoundedTableView alloc] initWithFrame:CGRectZero];
    XCTAssertNotNil(tableView);

    XCTAssertEqual(tableView.horizontalInset, 22.0f);
    XCTAssertEqual(tableView.accessoryHorizontalInset, MAXFLOAT);
    XCTAssertEqual(tableView.maximumWidth, 675.0f);
    XCTAssertEqual(tableView.sectionCornerRadius, 5.0f);
    XCTAssertEqual(tableView.cellBackgroundColor, [UIColor whiteColor]);
}

@end
