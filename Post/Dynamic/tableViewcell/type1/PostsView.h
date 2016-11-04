//
//  PostsView.h
//  Post
//
//  Created by admin on 2016/11/4.
//  Copyright © 2016年 Post. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostsView : UIView

@property (nonatomic , weak) IBOutlet UIImageView *headerImage;
@property (nonatomic , weak) IBOutlet UILabel *lbName;
@property (nonatomic , weak) IBOutlet UILabel *lbTime;
@property (nonatomic , weak) IBOutlet UIButton *btnVoice;
@property (nonatomic , weak) IBOutlet UILabel *lbVoiceTime;
@property (nonatomic , weak) IBOutlet UIImageView *pictureImage;
@property (nonatomic , weak) IBOutlet UIButton *btnInfo;
@property (nonatomic , weak) IBOutlet UIButton *btnMore;



@end
