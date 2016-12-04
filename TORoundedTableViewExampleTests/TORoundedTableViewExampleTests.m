//
//  TORoundedTableViewExampleTests.m
//  TORoundedTableViewExampleTests
//
//  Created by Tim Oliver on 4/12/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TORoundedTableView.h"

@interface TORoundedTableViewExampleTests : XCTestCase

@end

@implementation TORoundedTableViewExampleTests

- (void)testCreateTableView {
    // A VERY basic test to ensure the library actually compiles
    
    CGRect rect = CGRectMake(0,0,320,480);
    UIView *parentView = [[UIView alloc] initWithFrame:rect];
    TORoundedTableView *tableView = [[TORoundedTableView alloc] initWithFrame:rect];
    [parentView addSubview:tableView];
    
    XCTAssertNotNil(tableView);
}

@end
