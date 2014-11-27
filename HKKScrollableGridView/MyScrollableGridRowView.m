//
//  MyScrollableGridRowView.m
//  HKKScrollableGridView
//
//  Created by kyokook on 2014. 11. 18..
//  Copyright (c) 2014 rhlab. All rights reserved.
//

#import "MyScrollableGridRowView.h"

@interface MyScrollableGridRowView ()

@property (nonatomic, strong) UILabel *fixedLabel;
@property (nonatomic, strong) UILabel *scrollableLabel;

@end

@implementation MyScrollableGridRowView

- (void)setFixedString:(NSString *)fixedString
{
    _fixedString = fixedString.copy;
    self.fixedLabel.text = fixedString;
}

- (void)setScrollableString:(NSString *)scrollableString
{
    _scrollableString = scrollableString.copy;
    self.scrollableLabel.text = scrollableString;
}

- (UILabel *)fixedLabel
{
    if (_fixedLabel == nil) {
        _fixedLabel = [[UILabel alloc] initWithFrame:self.fixedView.bounds];
        _fixedLabel.textAlignment = NSTextAlignmentCenter;
        _fixedLabel.backgroundColor = [UIColor yellowColor];
        _fixedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.fixedView addSubview:_fixedLabel];
    }
    return _fixedLabel;
}

- (UILabel *)scrollableLabel
{
    if (_scrollableLabel == nil) {
        _scrollableLabel = [[UILabel alloc] initWithFrame:self.scrolledContentView.bounds];
        _scrollableLabel.backgroundColor = [UIColor lightGrayColor];
        _scrollableLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.scrolledContentView addSubview:_scrollableLabel];
    }
    return _scrollableLabel;
}

@end
