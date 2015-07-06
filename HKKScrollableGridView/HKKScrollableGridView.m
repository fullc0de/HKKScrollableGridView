//
//  HKKScrollableGridView.m
//  HKKScrollableGridView
//
//  Created by kyokook on 2014. 11. 10..
//  Copyright (c) 2014년 rhlab. All rights reserved.
//

#import "HKKScrollableGridView.h"

static NSString * const kHKKScrollableGridTableCellViewScrollOffsetChanged = @"kHKKScrollableGridTableCellViewScrollOffsetChanged";
static NSString * const kNotificationUserInfoContentOffset = @"kNotificationUserInfoContentOffset";

#pragma mark -
#pragma mark - HKKScrollableGridTableCellView Implementations
#pragma mark -

@interface HKKScrollableGridTableCellView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, readonly) NSLayoutConstraint *fixedWidthConstraint;
@end

@implementation HKKScrollableGridTableCellView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)dealloc
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didUpdateScrollOffset:(CGPoint)offset
{

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGPoint old = [[change objectForKey:@"old"] CGPointValue];
    CGPoint new = [[change objectForKey:@"new"] CGPointValue];
    
    if (CGPointEqualToPoint(old, new) == NO) {
        [self didUpdateScrollOffset:_scrollView.contentOffset];
        NSValue *offset = [NSValue valueWithCGPoint:_scrollView.contentOffset];
        [[NSNotificationCenter defaultCenter] postNotificationName:kHKKScrollableGridTableCellViewScrollOffsetChanged
                                                            object:self
                                                          userInfo:@{kNotificationUserInfoContentOffset:offset}];
    }
}

- (void)contentOffsetDidChanged:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NSValue *value = [userInfo objectForKey:kNotificationUserInfoContentOffset];
    if (value) {
        CGPoint newPoint = [value CGPointValue];
        if (CGPointEqualToPoint(_scrollView.contentOffset, newPoint) == NO) {
            _scrollView.contentOffset = newPoint;
        }
    }
}

- (void)initView
{
    _fixedView = [UIView new];
    _scrollView = [UIScrollView new];
    _scrolledContentView = [UIView new];
//    _fixedView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    _scrolledContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    _fixedView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
//    _scrolledContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _fixedView.backgroundColor = [UIColor clearColor];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrolledContentView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_scrollView];
    [self addSubview:_fixedView];
    [_scrollView addSubview:_scrolledContentView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[_fixedView]-0-[_scrollView]-0-|"
                                                                 options:NSLayoutFormatAlignAllBaseline
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_fixedView, _scrollView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_fixedView]-0-|"
                                                                 options:NSLayoutFormatAlignAllBaseline
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_fixedView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_scrollView]-0-|"
                                                                 options:NSLayoutFormatAlignAllBaseline
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_scrollView)]];
    
    _fixedWidthConstraint = [NSLayoutConstraint constraintWithItem:_fixedView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0f
                                                          constant:0.0f];
    [self addConstraint:_fixedWidthConstraint];
    
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentOffsetDidChanged:)
                                                 name:kHKKScrollableGridTableCellViewScrollOffsetChanged
                                               object:nil];
}

- (BOOL)isScrollable
{
    return _scrollView.frame.size.width < _scrollView.contentSize.width;
}

- (void)makeScrollableContentViewBeEmpty
{
    [_scrolledContentView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];
}

- (void)makeFixedViewBeEmpty
{
    [_fixedView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];
}

@end


#pragma mark -
#pragma mark - HKKScrollableGridTableCell Implementations
#pragma mark -
@interface HKKScrollableGridTableCell : UITableViewCell
@property (nonatomic, strong) Class cellViewClass;
@property (nonatomic, strong) HKKScrollableGridTableCellView *baseView;
@end


@implementation HKKScrollableGridTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style cellViewClass:(Class)cellViewClass reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setCellViewClass:(Class)cellViewClass
{
    _cellViewClass = cellViewClass;
    
    if (_baseView.superview) {
        [_baseView removeFromSuperview];
    }
    
    _baseView = (HKKScrollableGridTableCellView *)[[cellViewClass alloc] initWithFrame:self.bounds];
    _baseView.backgroundColor = [UIColor clearColor];
    _baseView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:_baseView];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_baseView]-0-|"
                                                                             options:NSLayoutFormatAlignAllBaseline
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_baseView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_baseView]-0-|"
                                                                             options:NSLayoutFormatAlignAllBaseline
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_baseView)]];
}

@end




#pragma mark - 
#pragma mark - HKKScrollableGridView Implementations
#pragma mark -
@interface HKKScrollableGridView () <UITableViewDataSource, UITableViewDelegate>
{
//    Class _cellViewClass;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSIndexPath *temporaryIndexPath;
@property (nonatomic, strong) HKKScrollableGridTableCell *temporaryCell;

@property (nonatomic, strong) NSMutableDictionary *registeredClass;

@property (nonatomic, assign) CGFloat offsetX;

@property (nonatomic, assign) CGFloat heightForHeader;
@property (nonatomic, assign) CGFloat heightForRow;

@property (nonatomic, assign) CGFloat fixedWidth;
@property (nonatomic, assign) CGFloat scrollableWidth;
@end

@implementation HKKScrollableGridView

#pragma mark - Initializer
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentOffsetDidChanged:)
                                                 name:kHKKScrollableGridTableCellViewScrollOffsetChanged
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Events
- (void)contentOffsetDidChanged:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NSValue *value = [userInfo objectForKey:kNotificationUserInfoContentOffset];
    if (value) {
        CGPoint point = value.CGPointValue;
        if (_offsetX != point.x) {
            _offsetX = point.x;
        }
    }
}

#pragma mark - Override
- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self reloadData];
}

#pragma mark - Interfaces
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[HKKScrollableGridTableCell class] forCellReuseIdentifier:@"HKKScrollableGridTableCell"];
        [self addSubview:_tableView];
        
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[table]-0-|" options:0 metrics:nil views:@{@"table":_tableView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[table]-0-|" options:0 metrics:nil views:@{@"table":_tableView}]];

        _heightForHeader = 40.0f;
        _heightForRow = 40.0f;
    }
    return _tableView;
}

- (void)setVerticalBounce:(BOOL)verticalBounce
{
    _verticalBounce = verticalBounce;
    self.tableView.bounces = _verticalBounce;
}

- (void)reloadData
{
    _fixedWidth = [_delegate widthOfFixedAreaForScrollableGridView:self];
    _scrollableWidth = [_delegate widthOfScrollableAreaForScrollableGridView:self];
    [self.tableView reloadData];
}

- (void)registerClassForGridCellView:(Class)cellViewClass reuseIdentifier:(NSString *)identifier
{
    if (_registeredClass == nil) {
        _registeredClass = @{}.mutableCopy;
    }
    
    NSAssert([cellViewClass isSubclassOfClass:[HKKScrollableGridTableCellView class]], @"CellViewClass being try to registered should be a subclass of HKKScrollableGridTableCellView");
    if ([cellViewClass isSubclassOfClass:[HKKScrollableGridTableCellView class]]) {
        [_registeredClass setObject:cellViewClass forKey:identifier];
    }
}

- (HKKScrollableGridTableCellView *)dequeueReusableViewForRowIndex:(NSUInteger)rowIndex reuseIdentifier:(NSString *)identifier
{
    NSAssert(_registeredClass.count > 0, @"HKKScrollableGridTableCellView class should be registered first!");
    NSAssert(_temporaryIndexPath != nil, @"temporary index path shouldn't be nil!");
    
    Class classForIdentifier = [_registeredClass objectForKey:identifier];
    
    HKKScrollableGridTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HKKScrollableGridTableCell" forIndexPath:_temporaryIndexPath];
    if (cell.cellViewClass == nil || [cell.baseView isMemberOfClass:classForIdentifier] == NO) {
        cell.cellViewClass = classForIdentifier;
    }
    _temporaryCell = cell;
    return cell.baseView;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_delegate scrollViewDidScroll:scrollView];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [_dataSource numberOfRowInScrollableGridView:self];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _temporaryIndexPath = indexPath;
    HKKScrollableGridTableCellView *view = [_dataSource scrollableGridView:self viewForRowIndex:indexPath.row];
    NSAssert(view != nil, @"view shouldn't be nil!");
    
    if (_temporaryCell == nil) {
        _temporaryCell = [self.tableView dequeueReusableCellWithIdentifier:@"HKKScrollableGridTableCell" forIndexPath:indexPath];
    }
    
    if (_temporaryCell.baseView != view) {
        _temporaryCell.baseView = view;
    }

    _temporaryCell.baseView.fixedWidthConstraint.constant = _fixedWidth;
    _temporaryCell.baseView.scrollView.contentSize = CGSizeMake(_scrollableWidth, _heightForRow);
    _temporaryCell.baseView.scrollView.contentOffset = CGPointMake(_offsetX, 0);
    _temporaryCell.baseView.scrolledContentView.frame = CGRectMake(0, 0, _scrollableWidth, _heightForRow);
    [_temporaryCell updateConstraintsIfNeeded];
    
    UITableViewCell *cell = _temporaryCell;
    _temporaryCell = nil;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    HKKScrollableGridTableCellView *cellView = [_delegate viewForHeaderForScrollableGridView:self];

    if (cellView) {
        cellView.fixedWidthConstraint.constant = _fixedWidth;
        cellView.scrollView.contentSize = CGSizeMake(_scrollableWidth, _heightForHeader);
        cellView.scrollView.contentOffset = CGPointMake(_offsetX, 0);
        cellView.scrolledContentView.frame = CGRectMake(0, 0, _scrollableWidth, _heightForHeader);
        [_temporaryCell updateConstraintsIfNeeded];
    }
    
    return cellView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([_delegate respondsToSelector:@selector(heightForHeaderViewOfScrollableGridView:)]) {
        _heightForHeader = [_delegate heightForHeaderViewOfScrollableGridView:self];
    }
    return _heightForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(scrollableGridView:heightForRowIndex:)]) {
        _heightForRow = [_delegate scrollableGridView:self heightForRowIndex:indexPath.row];
    }
    return _heightForRow;
}

@end
