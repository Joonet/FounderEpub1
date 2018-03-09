//
//  HYToast.m
//  E-Publishing
//
//  Created by zhuxuhong on 2017/8/1.
//
//

#import "HYToast.h"

@implementation HYToastAction

+(instancetype)actionWithTitle: (NSString*)title 
						 style: (UIAlertActionStyle)style 
					  callback: (HYToastActionCallback)callback{
	
	HYToastAction *action = [self new];
	action.title = title;
	action.style = style;
	action.callback = callback;
	
	return action;
}

@end


@implementation HYToast

+(void)showHUDTo:(UIView *)view 
		   title:(NSString *)title 
		   style:(HYToastHUDStyle)style 
		   delay:(NSTimeInterval)delay{
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[MBProgressHUD hideHUDForView:view animated:false];
		
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:true];
		hud.animationType = MBProgressHUDAnimationFade;
		hud.mode = style == HYToastHUDStyleLoading ? MBProgressHUDModeIndeterminate : MBProgressHUDModeText;
		if (style != HYToastHUDStyleLoading) {
			[hud hideAnimated:true afterDelay:delay];
		}
		hud.label.text = title;
	});
}

+(void)configureHUD: (MBProgressHUD*)hud{
	hud.label.textColor = [UIColor whiteColor];
	
	hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
	hud.bezelView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
	[UIActivityIndicatorView appearanceWhenContainedIn:[MBProgressHUD class], nil].activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
}

+(void)showAlertTo:(UIViewController *)controller 
			 title:(NSString *)title 
		   message:(NSString *)message 
		   action1:(HYToastActionConfigure)action1 
		   action2:(HYToastActionConfigure)action2{

	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	
	if (action1) {
		[alert addAction:[UIAlertAction actionWithTitle:action1().title style:action1().style handler:^(UIAlertAction * _Nonnull action) {
			action1().callback ? action1().callback() : nil;
		}]]; 
	}
	
	if (action2) {
		[alert addAction:[UIAlertAction actionWithTitle:action2().title style:action2().style handler:^(UIAlertAction * _Nonnull action) {
			action2().callback ? action2().callback() : nil;
		}]];
	}
	
	[controller presentViewController:alert animated:true completion:nil];
}

+(void)dismissHUDFrom: (UIView*)view{
	[MBProgressHUD hideHUDForView:view animated:true];
}

@end
