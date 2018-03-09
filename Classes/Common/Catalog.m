//
//  Catalog.m
//  EPUB
//
//  Created by YongjiSun on 2018/1/23.
//  Copyright © 2018年 yongjisun. All rights reserved.
//

#import "Catalog.h"
#import "UserInfo.h"

@implementation Catalog
extern UserInfo *userInfo;

+(BOOL)saveReadingInfo:(NSDictionary *)info withKey:(NSString *)key{
    NSString *filePath = [[self class]readingInfoFilePath];
    NSMutableDictionary *dic ;
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    }
    else{
        dic = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    [dic setObject:info forKey:key];
    BOOL success = [dic writeToFile:filePath atomically:YES];
    return success;
}

+(BOOL)deleteReadingInfoWithKey:(NSString *)key{
    NSString *filePath = [[self class]readingInfoFilePath];
    NSMutableDictionary *dic ;
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    }
    else{
        dic = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    [dic removeObjectForKey:key];
    BOOL success = [dic writeToFile:filePath atomically:YES];
    return success;
}

+(NSString *)readingInfoFilePath{
    if (![[NSFileManager defaultManager]fileExistsAtPath:DATA_FOLDER]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:DATA_FOLDER withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *readingInfo= [DATA_FOLDER
                            stringByAppendingPathComponent:@"readingInfo.plist"];
    return readingInfo;
}

+(NSDictionary *)getReadingInfo{
    NSDictionary *dic = nil;
    NSString *filePath = [[self class]readingInfoFilePath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    return dic;
}
+(BOOL)deleteReadingInfo
{
    NSString *filePath = [[self class]readingInfoFilePath];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        return [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
    }
    
    return NO;
}
+(NSString *)epubSettingFilePath{
    if (![[NSFileManager defaultManager]fileExistsAtPath:DATA_FOLDER]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:DATA_FOLDER withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *readingInfo= [DATA_FOLDER
                            stringByAppendingPathComponent:@"epubSetting.plist"];
    return readingInfo;
}

//epub相关设置:字体0.6-1.4,默认为5;背景色；行间距
+(BOOL)saveEpubSetting:(NSDictionary *)info{
    NSString *filePath = [[self class]epubSettingFilePath];
    BOOL success = [info writeToFile:filePath atomically:YES];
    return success;
}
+(NSDictionary *)getEpubSetting{
    NSDictionary *dic = nil;
    NSString *filePath = [[self class]epubSettingFilePath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    else{
        dic = @{@"kEpubFont":@(1.0),@"kEpubBgColor":@(0),@"kEpubMargin":@(0),@"kEPubFlipType":@(0)};
        //        if (isPad ) {
        //             dic = @{@"kEpubFont":@(1.0),@"kEpubBgColor":@(0),@"kEpubMargin":@(0),@"kEPubFlipType":@(0)};
        //        }
        //        else{
        //            dic = @{@"kEpubFont":@(1.1),@"kEpubBgColor":@(0),@"kEpubMargin":@(3),@"kEPubFlipType":@(0)};
        //        }
        [dic writeToFile:filePath atomically:YES];
    }
    return dic;
}


//获得学习记录所产生的数据存储的文件夹
+(NSString *)getTeaRecordDirecotry{
    NSString *recorderLibraryDirectory= [DATA_FOLDER
                                         stringByAppendingPathComponent:@"TeaRecord"];
    if (userInfo && userInfo.userID) {
        recorderLibraryDirectory = [recorderLibraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",userInfo.userID]];
        if (![[NSFileManager defaultManager]fileExistsAtPath:recorderLibraryDirectory]) {
            [[NSFileManager defaultManager]createDirectoryAtPath:recorderLibraryDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    else{
        recorderLibraryDirectory = [recorderLibraryDirectory stringByAppendingPathComponent:@"DefaultUser"];
        if (![[NSFileManager defaultManager]fileExistsAtPath:recorderLibraryDirectory]) {
            [[NSFileManager defaultManager]createDirectoryAtPath:recorderLibraryDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    return recorderLibraryDirectory;
}

+(NSString *)stringWithUUID:(NSInteger)dataType{
    
    CFUUIDRef uuidObj = CFUUIDCreate(nil);   //create a new UUID
    NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    if (dataType != -1) {
        return  [NSString stringWithFormat:@"%ld%@",dataType,uuidString];
    }
    
    return uuidString ;
}

@end
