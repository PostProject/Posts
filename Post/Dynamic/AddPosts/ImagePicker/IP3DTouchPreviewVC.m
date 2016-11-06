//
//  IP3DTouchPreviewVC.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/4/23.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IP3DTouchPreviewVC.h"
#import "IPAssetModel.h"
#import "IPAssetManager.h"

@interface IP3DTouchPreviewVC ()
/**数据模型*/
@property (nonatomic, strong)IPAssetModel *dataModel;

/**容器*/
@property (nonatomic, weak)UIImageView *imgView;

@end

@implementation IP3DTouchPreviewVC
+ (instancetype)previewViewControllerWithModel:(IPAssetModel *)model{
    IP3DTouchPreviewVC *vc = [[self alloc]init];
    vc.dataModel = model;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView = imgView;
    [self.view addSubview:imgView];
}

- (void)cancle{
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[IPAssetManager defaultAssetManager]getFullScreenImageWithAsset:self.dataModel photoWidth:self.view.bounds.size completion:^(UIImage *photo, NSDictionary *info) {
        
//        self.imgView.frame = CGRectMake(0, 0, photo.size.width, photo.size.height);
//        self.imgView.center = self.view.center;
        
        self.imgView.image = photo;
    }];
}

@end
