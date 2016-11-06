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
        _imagePickerController.maxCount = 9;
        _imagePickerController.popStyle = IPickerViewControllerPopStylePush;
    }
    return _imagePickerController;
   
}
-(void)addImageAction{
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)didClickCompleteBtn:(NSArray *)datas{
    [datas enumerateObjectsUsingBlock:^(IPAssetModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MyLog(@"%@--%@",obj.localIdentiy,obj.assetUrl.absoluteString);
        if (idx >6) {
            [[Toast shareToast]showContent:@"请上传过少于6张照片" adTime:2];
            return;
        }
        [[IPAssetManager defaultAssetManager] getAspectThumbailWithModel:obj completion:^(UIImage *photo, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(70 * idx , 0, 60, 60)];
                imageView.image = photo;
                [self.picImageView addSubview:imageView];
                [self.tableView reloadData];
            });
        }];
        
    }];
    
}

- (void)imgPicker:(IPickerViewController *)ipVc didFinishCaptureVideoItem:(AVPlayerItem *)playerItem Videourl:(NSURL *)videoUrl videoDuration:(float)duration thumbailImage:(UIImage *)thumbail{
//    ipVc getth
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
-(void)viewDidAppear:(BOOL)animated{
    [self.messageTextView becomeFirstResponder];
}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSString *cellId=@"cellId";
//    UITableViewCell *myCell=[tableView dequeueReusableCellWithIdentifier:cellId];
//    
//    return myCell;
//}
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 3;
//}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
