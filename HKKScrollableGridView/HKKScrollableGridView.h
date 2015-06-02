//
//  HKKScrollableGridView.h
//  HKKScrollableGridView
//
//  Created by kyokook on 2014. 11. 10..
//  Copyright (c) 2014년 rhlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKKScrollableGridTableCellView : UIView

@property (nonatomic, strong) UIView *fixedView;            ///< A base view for fixed area which is placed in front of the cell view.
@property (nonatomic, strong) UIView *scrolledContentView;  ///< A base view for scrollable area followed by fixedView.

@property (nonatomic, readonly) BOOL isScrollable;          ///< check if cell view is able to scroll it's scrolledContentView or not.

- (void)didUpdateScrollOffset:(CGPoint)offset;        ///< overridable. when a scrollView's contentOffset is changed, the method is called.

// helper methods
- (void)makeScrollableContentViewBeEmpty;       // make a scrollable view being empty.
- (void)makeFixedViewBeEmpty;                   // make a fixed view being empty.
@end



@protocol HKKScrollableGridViewDataSource;
@protocol HKKScrollableGridViewDelegate;

/**
 HKKScrollableGridView is a grid view which has a style like a sheet UI such as Excel spread sheet.
 It consist of a fixed area leftside and scrollable area rightside and fixed header area on top of it.
 */
@interface HKKScrollableGridView : UIView

@property (nonatomic, weak) id<HKKScrollableGridViewDataSource> dataSource;
@property (nonatomic, weak) id<HKKScrollableGridViewDelegate> delegate;

@property (nonatomic, assign) BOOL verticalBounce;

- (void)reloadData;

- (void)registerClassForGridCellView:(Class)cellViewClass reuseIdentifier:(NSString *)identifier;
- (HKKScrollableGridTableCellView *)dequeueReusableViewForRowIndex:(NSUInteger)rowIndex reuseIdentifier:(NSString *)identifier;
@end


@protocol HKKScrollableGridViewDataSource <NSObject>
@required
- (NSUInteger)numberOfRowInScrollableGridView:(HKKScrollableGridView *)gridView;
- (HKKScrollableGridTableCellView *)scrollableGridView:(HKKScrollableGridView *)gridView viewForRowIndex:(NSUInteger)rowIndex;
@end



@protocol HKKScrollableGridViewDelegate <NSObject>
@required
- (CGFloat)widthOfFixedAreaForScrollableGridView:(HKKScrollableGridView *)gridView;
- (CGFloat)widthOfScrollableAreaForScrollableGridView:(HKKScrollableGridView *)gridView;

- (HKKScrollableGridTableCellView *)viewForHeaderForScrollableGridView:(HKKScrollableGridView *)gridView;

@optional
- (CGFloat)heightForHeaderViewOfScrollableGridView:(HKKScrollableGridView *)gridView;
- (CGFloat)scrollableGridView:(HKKScrollableGridView *)gridView heightForRowIndex:(NSUInteger)rowIndex;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end