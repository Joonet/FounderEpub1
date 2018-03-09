//
//  HYToast.h
//  E-Publishing
//
//  Created by zhuxuhong on 2017/8/1.
//
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>


typedef enum : NSUInteger {
	HYToastStyleAlert,
	HYToastStyleHUD
} HYToastStyle;

typedef enum : NSUInteger {
	HYToastHUDStyleLoading,
	HYToastHUDStyleTips
} HYToastHUDStyle;


@class HYToastAction;

typedef void(^HYToastActionCallback)();

typedef HYToastAction* (^HYToastActionConfigure)();



@interface HYToastAction : NSObject

@property(nonatomic)UIAlertActionStyle style;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)HYToastActionCallback callback;

+(instancetype)actionWithTitle: (NSString*)title 
						 style: (UIAlertActionStyle)style 
					  callback: (HYToastActionCallback)callback;

@end


@interface HYToast : NSObject

+(void)showAlertTo: (UIViewController*)controller
			 title: (NSString*)title 
		   message: (NSString*)message 
		   action1: (HYToastActionConfigure)action1 
		   action2: (HYToastActionConfigure)action2;

+(void)showHUDTo:(UIView *)view 
		   title:(NSString *)title 
		   style:(HYToastHUDStyle)style 
		   delay:(NSTimeInterval)delay;

+(void)dismissHUDFrom: (UIView*)view;

@end
