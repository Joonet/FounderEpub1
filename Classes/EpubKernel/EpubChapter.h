//
//  EpubChapter.h
//  E-Publishing
//
//  Created by miaopu on 14/12/26.
//
//

#import <Foundation/Foundation.h>
#import "EpubWebView.h"
#import "EpubProtocal.h"

@interface EpubChapter : NSObject <UIWebViewDelegate,EPUBWebviewProtocal,NSCopying>
{
    //私有变量
    float viewWidth;
    float viewHeight;
    NSString *searchKey;
}

//!视图上边相当于EPUB总高度的位移
@property (nonatomic,assign)CGPoint offset;
//!网页视图的scrollview的contentsize
@property (nonatomic,assign)CGSize contentSize;
//!对应html的总页码
@property (nonatomic,assign)NSInteger pageCount;
//!html对应的title
@property (nonatomic,retain)NSString *title;
//!网页视图字体大小
@property (nonatomic,assign)NSInteger fontSize;
//!该章节对应的URL
@property (nonatomic,retain)NSURL *chapterUrl;
//!该章节对应的文件名
@property (nonatomic,retain)NSString *chapterFileName;
//!该章节的id
@property (nonatomic,assign) NSInteger chapterIndex;
//!主控制器的代理啊
@property (nonatomic,weak) id <EpubChapterProtocol>epubDelegate;
//!如果计算页码 标识是更新笔记和书签 还是更新页码
@property (nonatomic,assign) BOOL isUpdateNoteAndMark;
@property (nonatomic,retain) NSString *searchKey;

- (void) loadChapterWithWindowSize:(CGSize)theWindowSize;
- (void)searchChapterWithWindowSize:(CGSize)theWindowSize Key:(NSString *)key;
@end







