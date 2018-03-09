//
//  UserInfo.h
//  EPUB
//
//  Created by YongjiSun on 2018/1/31.
//  Copyright © 2018年 yongjisun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class  UserState;
@interface UserInfo : NSObject
@property(nonatomic, strong)UserState *userState;
@property(nonatomic, strong)NSString *userID;
@property(nonatomic, strong)NSString *name;
@end
