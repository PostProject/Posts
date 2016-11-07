//
//  AddPostsTableViewController.m
//  Post
//
//  Created by 陈世文 on 2016/11/6.
//  Copyright © 2016年 Post. All rights reserved.
//

#import "AddPostsTableViewController.h"
#import "SelectView.h"
#import "IPAssetManager.h"
#import "IPickerViewController.h"

@interface AddPostsTableViewController ()<IPickerViewControllerDelegate>

{
    int _imageNum;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picImageViewH;
@property (weak, nonatomic) IBOutlet UIView *picImageView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UIButton *btnLocaltion;
@property (weak, nonatomic) IBOutlet UIButton *btnRedType;
@property (weak, nonatomic) IBOutlet UIView *speckView;
@property (nonatomic , strong) SelectView *selectView;
@property (nonatomic , strong) IPickerViewController *imagePickerController;
@property (nonatomic , strong) IPAssetManager *defaultAssetManager;

//@property (nonatomic, strong)UIImageView *img2;
@end

@implementation AddPostsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.messageTextView setInputAccessoryView:self.selectView];
//    _img2 = [[UIImageView alloc]initWithFrame:CGRectMake(130, 50, 100, 100)];
//    [self.view addSubview:_img2];
    
    
}
-(SelectView *)selectView{
    if (!_selectView) {
        _selectView = [[NSBundle mainBundle] loadNibNamed:@"SelectView" owner:self options:nil
                       ].firstObject;
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addSpeck:)];
        //设置长按时间
        longPressGesture.minimumPressDuration = 0.5;
        [_selectView.btnAddImage addTarget:self action:@selector(addImageAction) forControlEvents:UIControlEventTouchUpInside];
        [_selectView addGestureRecognizer:longPressGesture];
    }
    return _selectView;
}

/**
 添加语音

 @param gesture <#gesture description#>
 */
-(void)addSpeck:(UILongPressGestureRecognizer*)gesture{
    UIGestureRecognizerState state = gesture.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            MyLog(@"开始");
            break;
        case UIGestureRecognizerStateEnded:
            MyLog(@"结束");
            self.speckView.hidden = NO;
            break;
        default:
            break;
    }
    MyLog(@"添加语音");
    
    
}
///删除语音
- (IBAction)closeSpeck:(id)sender {
    MyLog(@"删除语音");
    self.speckView.hidden = YES;
}
///取消
- (IBAction)dismisViewControl:(id)sender {
    MyLog(@"取消");
    [self.messageTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}
///发布
- (IBAction)relaeseAction:(id)sender {
    
    if ([self.messageTextView.text isEqualToString:@""]&&self.speckView.hidden && _imageNum == 0) {
        
        [[Toast shareToast]showContent:@"请输入当前心情或语音" adTime:2];
        return;
    }
    MyLog(@"发布");
}
/**
  跳往定位
 */
- (IBAction)localTion:(id)sender {
}

/**
 观看权限
 */
- (IBAction)ViewPermissions:(id)sender {
}

-(IPickerViewController *)imagePickerController{
    if (!_imagePickerController) {
        _imagePickerController = [IPickerViewController instanceWithDisplayStyle:IPickerViewControllerDisplayStyleImage];
        _imagePickerController.delegate = self;
//        _imagePickerController.maxCount = 6;
        _imagePickerController.popStyle = IPickerViewControllerPopStylePush;
    }
    return _imagePickerController;
   
}
-(void)addImageAction{
    for (UIView *view in self.picImageView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    _imageNum = 0;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

/**
 上传照片

 @param datas <#datas description#>
 */
- (void)didClickCompleteBtn:(NSArray *)datas{
    [datas enumerateObjectsUsingBlock:^(IPAssetModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MyLog(@"%@--%@",obj.localIdentiy,obj.assetUrl.absoluteString);
        
        if (idx <=6) {
            [[IPAssetManager defaultAssetManager] getAspectThumbailWithModel:obj completion:^(UIImage *photo, NSDictionary *info) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _imageNum ++;
                    int imageW = UISCREW / 3 - 10;
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((imageW + 10 )* idx , 0, imageW, imageW)];
                    if (_imageNum > 3) {
                        NSInteger index = _imageNum - 4;
                        imageView.frame = CGRectMake((imageW + 10 )* index , imageW + 10, imageW, imageW);
                    }
                    imageView.image = photo;
                    [self.picImageView addSubview:imageView];
                    [self.tableView reloadData];
                });
            }];
            
        }else{
            [[Toast shareToast]showContent:@"请上传过少于6张照片" adTime:2];
            return;
        }
        
        
    }];
    
}

- (void)imgPicker:(IPickerViewController *)ipVc didFinishCaptureVideoItem:(AVPlayerItem *)playerItem Videourl:(NSURL *)videoUrl videoDuration:(float)duration thumbailImage:(UIImage *)thumbail{
//    ipVc getth
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.messageTextView becomeFirstResponder];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
