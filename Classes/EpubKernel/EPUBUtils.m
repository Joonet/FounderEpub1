//
//  EPUBUtils.m
//  E-Publishing
//
//  Created by tangsl on 15/7/9.
//
//

#import "EPUBUtils.h"

@implementation EPUBUtils


//! 把rgb color 变为uicolor
+(UIColor*) colorWithRGBHexString:(NSString*)rgbColor{
    
    NSString *cString = rgbColor;
    //去除空格并大写
    cString = [[cString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6) {
        //返回默认颜色
        return [UIColor redColor];
    }
    if ([cString hasPrefix:@"0x"]) {
        cString = [cString substringFromIndex:2];
    }
    else if ([cString hasPrefix:@"#"]){
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6) {
        //返回默认颜色
        return [UIColor redColor];
    }
    NSRange range;
    range.length = 2;
    range.location = 0;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r,g,b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:1.0f];
}

//! 布局相关
+ (void)constrainSubview:(UIView *)subview toMatchWithSuperview:(UIView *)superview withHpading:(NSInteger)hpading vpading:(NSInteger)vpading
{
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(subview);
    
    NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:hpading],@"hpading",[NSNumber numberWithInteger:vpading], @"vpading",nil];
    
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"H:|-hpading-[subview]"
                            options:0
                            metrics:metrics
                            views:viewsDictionary];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:|-vpading-[subview]"
                    options:0
                    metrics:metrics
                    views:viewsDictionary]];
    
    [superview addConstraints:constraints];
}

//! 布局相关
+ (void)constrainSubview:(UIView *)subview toMatchWithSuperview:(UIView *)superview withHpading:(NSInteger)hpading vpading:(NSInteger)vpading width:(NSInteger)width height:(NSInteger)height
{
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(subview);
    
    NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:hpading],@"hpading",[NSNumber numberWithInteger:vpading], @"vpading",[NSNumber numberWithInteger:width],@"width",[NSNumber numberWithInteger:height],@"height",nil];
    
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"H:|-hpading-[subview(width)]"
                            options:0
                            metrics:metrics
                            views:viewsDictionary];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:|-vpading-[subview(height)]"
                    options:0
                    metrics:metrics
                    views:viewsDictionary]];
    
    [superview addConstraints:constraints];
}

//创建一个纯色的image
+ (UIImage*) createImageWithColor: (UIColor*) color withSize:(CGSize)size isCircle:(BOOL)isCircle
{
    CGRect rect=CGRectMake(0.0f, 0.0f,size.width,size.height);
    UIGraphicsBeginImageContextWithOptions(size,NO,0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    if (isCircle) {
        CGContextFillEllipseInRect(context,rect);
    }
    else{
        CGContextFillRect(context, rect);
    }
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+(NSString *)webviewBgColor:(EPUP_BG_COLOR)mode{
    NSString *color = @"black";
    switch (mode) {
        case epub_black:
        color = @"#333333";
        break;
        case epub_gray:
        color = @"#69696B";
        break;
        case epub_orange:
        color = @"#FAF9DE";
        break;
        case epub_blue:
        color = @"#B6D1D3";
        break;
        case epub_green:
        color = @"#E3EDCD";
        break;
        case epub_brown:
        color = @"#FFF2E2";
        break;
        case epub_lightgray:
        color = @"#EAEAEF";
        break;
        case epub_white:
        color = @"#FFFFFF";
        break;
        default:
        break;
    }
    return color;
}
+(NSInteger)changeFloatPagenumToInt:(float)pagenum
{
    NSInteger returnPageNum = pagenum;
    if(pagenum > returnPageNum + 0.5)
    {
        returnPageNum++;
    }
    if(returnPageNum<=0)
    {
        returnPageNum = 1;
    }
    return returnPageNum;
}
@end
