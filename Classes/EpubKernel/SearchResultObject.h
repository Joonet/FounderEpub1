//
//  SearchResultObject.h
//  E-Publishing
//
//  Created by tangsl on 15/7/9.
//
//

#import <Foundation/Foundation.h>

@interface SearchResultObject : NSObject
//!上下文内容
@property (nonatomic,retain) NSString *text;
//!x坐标
@property (nonatomic,assign) float left;
//!y坐标
@property (nonatomic,assign) float top;
//!起始的字符位置
@property (nonatomic,assign) NSInteger startIndex;
//!章节的id
@property (nonatomic,assign) NSInteger chapterIndex;
//!页码
@property (nonatomic,assign) NSInteger pageNum;

@end
