//
//  EPUBUtils.h
//  E-Publishing
//
//  Created by tangsl on 15/7/9.
//
//

#import <UIKit/UIKit.h>
#import "EpubStaticDefine.h"

@interface EPUBUtils : NSObject


//! 把rgb color 变为uicolor
+(UIColor*) colorWithRGBHexString:(NSString*)rgbColor;

//! 布局相关
+ (void)constrainSubview:(UIView *)subview toMatchWithSuperview:(UIView *)superview withHpading:(NSInteger)hpading vpading:(NSInteger)vpading;

//! 布局相关
+ (void)constrainSubview:(UIView *)subview toMatchWithSuperview:(UIView *)superview withHpading:(NSInteger)hpading vpading:(NSInteger)vpading width:(NSInteger)width height:(NSInteger)height;

//! 创建一个纯色的image
+ (UIImage*) createImageWithColor: (UIColor*) color withSize:(CGSize)size isCircle:(BOOL)isCircle;

+(NSString *)webviewBgColor:(EPUP_BG_COLOR)mode;
+(NSInteger)changeFloatPagenumToInt:(float)pagenum;
@end
