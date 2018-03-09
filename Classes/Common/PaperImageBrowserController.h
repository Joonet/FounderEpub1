//
//  PaperImageBrowserController.h
//  DoingPaper_LS
//
//  Created by zhuxuhong on 2016/12/8.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PaperImageBrowserCompletion)();

@interface PaperImageBrowserController : UIViewController

-(instancetype)initWithPlaceImageView: (UIImageView*)imageView;

// 占位图
-(instancetype)initWithPlaceImageView: (UIImageView*)imageView
                       showCompletion: (PaperImageBrowserCompletion)show
                    dismissCompletion: (PaperImageBrowserCompletion)dismiss;
// 显示
-(void)showWithAnimation;

@end
