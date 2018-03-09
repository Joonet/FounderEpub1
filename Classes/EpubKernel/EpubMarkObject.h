//
//  EpubMarkObject.h
//  E-Publishing
//
//  Created by tangsl on 15/7/9.
//
//

#import <Foundation/Foundation.h>

@interface EpubMarkObject : NSObject

//!js内部存储的信息
@property (nonatomic,retain) NSString* markJsIndex;
//!书签对应的章节名称
@property (nonatomic,assign) NSInteger chapterIndex;
//!书签对应的文字内容
@property (nonatomic,retain) NSString* content;
//!添加书签的时间
@property (nonatomic,retain) NSDate *date;
//!横屏竖屏 横翻竖翻对应的pageNum
@property (nonatomic,retain) NSMutableDictionary *pageNumDic;
//!这个mark对应的id
@property (nonatomic,retain) NSString *markId;
//!title
@property (nonatomic,retain) NSString *title;
//!目前展示所对应的pageNum
@property (nonatomic,assign) NSInteger pageNum;
//!相对于全书的页码
@property (nonatomic,assign) NSInteger bookPageNum;


@end
