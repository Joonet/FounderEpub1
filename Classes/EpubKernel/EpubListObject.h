//
//  EpubListObject.h
//  E-Publishing
//
//  Created by tangsl on 15/7/9.
//
//

#import <Foundation/Foundation.h>

@interface EpubListObject : NSObject

//!标识第几层html
@property (nonatomic,assign) NSInteger layer;
//!该章节的js标签
@property (nonatomic,retain) NSString *listMark;
//!该列表项的名称
@property (nonatomic,retain) NSString *listName;
//!该列表项对应的chapterIndex（chapterarray 中的第几项）
@property (nonatomic,assign) NSInteger chapterIndex;


@end
