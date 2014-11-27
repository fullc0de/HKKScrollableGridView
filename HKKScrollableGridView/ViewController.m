//
//  ViewController.m
//  HKKScrollableGridView
//
//  Created by kyokook on 2014. 11. 10..
//  Copyright (c) 2014 rhlab. All rights reserved.
//

#import "ViewController.h"

#import "HKKScrollableGridView.h"

#import "MyScrollableGridHeaderView.h"
#import "MyScrollableGridRowView.h"

@interface ViewController () <HKKScrollableGridViewDataSource, HKKScrollableGridViewDelegate>
@property (nonatomic, strong) HKKScrollableGridView *gridView;
@property (nonatomic, strong) MyScrollableGridHeaderView *gridHeaderView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _gridView = [[HKKScrollableGridView alloc] initWithFrame:CGRectMake(10, 80, 300, 400)];
    _gridView.dataSource = self;
    _gridView.delegate = self;
    _gridView.verticalBounce = NO;
    _gridView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0f];
    [_gridView registerClassForGridCellView:[MyScrollableGridRowView class]];
    
    [self.view addSubview:_gridView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MyScrollableGridHeaderView *)gridHeaderView
{
    if (_gridHeaderView == nil) {
        _gridHeaderView = [[MyScrollableGridHeaderView alloc] init];
        _gridHeaderView.fixedString = @"fixed";
        _gridHeaderView.scrollableString = @"c1 c2 c3 c4 c5 c6 c7 c8 c9 c1 c2 c3 c4 c5 c6 ca cb cc cd ce";
    }
    return _gridHeaderView;
}

- (NSUInteger)numberOfRowInScrollableGridView:(HKKScrollableGridView *)gridView
{
    return 30;
}

- (HKKScrollableGridTableCellView *)scrollableGridView:(HKKScrollableGridView *)gridView viewForRowIndex:(NSUInteger)rowIndex;
{
    MyScrollableGridRowView *cellView = (MyScrollableGridRowView *)[gridView dequeueReusableViewForRowIndex:rowIndex];
    cellView.fixedString = [NSString stringWithFormat:@"R%ld", (long)rowIndex];
    cellView.scrollableString = @"1  2  3  4  5  6  7  8  9  1  2  3  4  5  6  a  b  c  d  e  f  g  h  i  j  k";
    return cellView;
}


- (CGFloat)widthOfFixedAreaForScrollableGridView:(HKKScrollableGridView *)gridView
{
    return 40.0f;
}

- (CGFloat)widthOfScrollableAreaForScrollableGridView:(HKKScrollableGridView *)gridView
{
    return 500.0f;
}

- (HKKScrollableGridTableCellView *)viewForHeaderForScrollableGridView:(HKKScrollableGridView *)gridView
{
    return self.gridHeaderView;
}

- (CGFloat)heightForHeaderViewOfScrollableGridView:(HKKScrollableGridView *)gridView
{
    return 40.0f;
}
- (CGFloat)scrollableGridView:(HKKScrollableGridView *)gridView heightForRowIndex:(NSUInteger)rowIndex
{
    return 40.0f;
}


@end
