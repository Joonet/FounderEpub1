//
//  UIImage+UIImage_LoadCocoaPodImage.m
//  EpubCocoapod
//
//  Created by YongjiSun on 2018/3/12.
//  Copyright © 2018年 yongjisun. All rights reserved.
//

#import "UIImage+UIImage_LoadCocoaPodImage.h"
#import <objc/runtime.h>
//#import <EPUB.h>
@implementation UIImage (UIImage_LoadCocoaPodImage)
static NSBundle *resource_bundle;

+ (UIImage *)loadImageClass:(Class)className ImageName:(NSString *)imageName{
    NSString *bundlePath = [[NSBundle bundleForClass:className].resourcePath
                            stringByAppendingPathComponent:@"EpubImage.bundle"];
    resource_bundle  = [NSBundle bundleWithPath:bundlePath];
    return [UIImage imageNamed:imageName
                      inBundle:resource_bundle
 compatibleWithTraitCollection:nil];
    
}





@end
