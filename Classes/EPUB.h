//
//  EPUB.h
//  EPUB
//
//  Created by YongjiSun on 2018/3/2.
//  Copyright © 2018年 yongjisun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  EPUB, EPubMainViewController;
@protocol EPUBDelegate<NSObject>

-(void)backToShelf;

@end


@interface EPUB : NSObject
@property(nonatomic, weak)id<EPUBDelegate>delegate;

+ (instancetype)shareEpub;

- (EPubMainViewController *)epubMainViewControllerWithFilePath:(NSString *)filePath;

- (void)clearAllNote;



@end
