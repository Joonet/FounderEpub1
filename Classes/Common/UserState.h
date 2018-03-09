//
//  UserState.h
//  EPUB
//
//  Created by YongjiSun on 2018/1/31.
//  Copyright © 2018年 yongjisun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserState : NSObject
@property(nonatomic, assign) NSInteger pageNum;  //教材页号
@property(nonatomic, strong) NSString *courseID;
@property(nonatomic, strong) NSString *textbookID;
@end
