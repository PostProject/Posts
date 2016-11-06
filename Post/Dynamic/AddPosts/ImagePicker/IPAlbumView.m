//
//  IPAlbumView.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPAlbumView.h"
#import "IPAlbumModel.h"
#import "IPAlbumCell.h"

@interface IPAlbumView ()<UITableViewDataSource,UITableViewDelegate>

/**数据*/
@property (nonatomic, strong)NSArray *dataSource;

/**内容视图*/
@property (nonatomic, weak)UITableView *mainView;

/**背景图*/
@property (nonatomic, weak)UIButton *backView;

/**上一个被选中cell 对应的数据*/
@property (nonatomic, strong)IPAlbumModel *preModel;
@end


@implementation IPAlbumView
+ (instancetype)albumViewWithData:(NSArray *)data{
    IPAlbumView *ablumView = [[self alloc]init];
    ablumView.dataSource = [NSArray arrayWithArray:data];
    [ablumView.dataSource enumerateObjectsUsingBlock:^(IPAlbumModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSelected) {
            ablumView.preModel = obj;
            *stop = YES;
        }
    }];
    return ablumView;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpViews];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setUpViews];
    }
    return self;
}
- (void)setUpViews{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor clearColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundColor:[UIColor clearColor]];
    
    [btn addTarget:self action:@selector(dismissFromSuper) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    self.backView = btn;
    
    UITableView *tableView =[[UITableView alloc]init];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self addSubview:tableView];
    self.mainView = tableView;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat height = self.dataSource.count * 50;
    if (height > 325) {
        height = 325;
    }
    self.mainView.frame = CGRectMake(0, 0, self.bounds.size.width, height);
    self.backView.frame = self.bounds;
}

- (void)dismissFromSuper{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldRemoveFrom:)]) {
        [self.delegate shouldRemoveFrom:self];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (IPAlbumCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *albumID = @"albumCell";
    IPAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:albumID];
    if (cell == nil) {
        cell = [[IPAlbumCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:albumID];
    }
    
    IPAlbumModel *model = self.dataSource[indexPath.row];
    cell.model = model;
   
    return cell;
}
- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    IPAlbumCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}
- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    IPAlbumCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCellForIndex:ForView:)]) {
        [self.delegate clickCellForIndex:indexPath ForView:self];
    }
    IPAlbumModel *model = self.dataSource[indexPath.row];
    if (model == self.preModel) {
        return;
    }
    model.isSelected = YES;
    self.preModel.isSelected = NO;
    NSInteger index = (NSInteger)[self.dataSource indexOfObject:self.preModel];
    NSIndexPath *preIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [tableView reloadRowsAtIndexPaths:@[indexPath,preIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    self.preModel = model;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}
@end
