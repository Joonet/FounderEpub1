//
//  UIImage+UIImage_LoadCocoaPodImage.h
//  EpubCocoapod
//
//  Created by YongjiSun on 2018/3/12.
//  Copyright © 2018年 yongjisun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImage_LoadCocoaPodImage)
+ (UIImage *)loadImageClass:(Class)className ImageName:(NSString *)imageName;
@end
