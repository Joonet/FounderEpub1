//
//  EPUB.m
//  EPUB
//
//  Created by YongjiSun on 2018/3/2.
//  Copyright © 2018年 yongjisun. All rights reserved.
//

#import "EPUB.h"
#import "EPubMainViewController.h"
#import "SqliteInterface.h"
#import "UserInfo.h"
#import "UserState.h"
#import <CommonCrypto/CommonDigest.h>
#import "TeaRecordDAO.h"

@interface EPUB()
@property(nonatomic, strong)EPubMainViewController *epubMainViewController;
@end

@implementation EPUB
#define DB_NAME @"Interactive.db"
static NSString *encryptionKey = @"nha735n197nxn(N′568GGS%d~~9naei';45vhhafdjkv]32rpks;lg,];:vjo(&**&^)";
UserInfo *userInfo = nil;

+(instancetype)shareEpub {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    
    return instance;
}


-(EPubMainViewController *)epubMainViewControllerWithFilePath:(NSString *)filePath {
    
    if (filePath != nil) {
        [self setUpEpubWithFilePath:filePath];
        EPubMainViewController *mainViewController = [[EPubMainViewController alloc]initWithDirPath:filePath];
        mainViewController.exitEpubBlock = ^(){
            if ([self.delegate respondsToSelector:@selector(backToShelf)]) {
                [self.delegate backToShelf];
            }
        };
        return mainViewController;
    }else {
        return nil;
    }
    
}

- (void)setUpEpubWithFilePath: (NSString *)path{
    [[SqliteInterface sharedSqliteInterface] connectDB];
    
    userInfo = [[UserInfo alloc]init];
    userInfo.name = @"sun";
    userInfo.userID = @"sun";
    UserState *userState = [[UserState alloc]init];
    userInfo.userState = userState;
    userState.textbookID = [[self class] md5EncryptWithString:path];

}

//删除了所有的记录
- (void)clearAllNote {
    [[[TeaRecordDAO alloc]init]clearTeaRecord];
}

+ (NSString *)md5EncryptWithString:(NSString *)string{
    return [self md5:[NSString stringWithFormat:@"%@%@", encryptionKey, string]];
}

+ (NSString *)md5:(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    return result;
}

@end
