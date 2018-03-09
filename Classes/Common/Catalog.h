//
//  Catalog.h
//  EPUB
//
//  Created by YongjiSun on 2018/1/23.
//  Copyright © 2018年 yongjisun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Catalog : NSObject



//阅读记录内容存储
+(BOOL)saveReadingInfo:(NSDictionary *)info withKey:(NSString *)key;

+(BOOL)deleteReadingInfoWithKey:(NSString *)key;

+(NSDictionary *)getReadingInfo;

+(BOOL)deleteReadingInfo;

//epub相关设置:字体0.6-1.4,默认为5;背景色；行间距
+(BOOL)saveEpubSetting:(NSDictionary *)info;
+(NSDictionary *)getEpubSetting;
+(NSString *)getTeaRecordDirecotry;
+(NSString *)stringWithUUID:(NSInteger)dataType;
@end
