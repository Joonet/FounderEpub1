//
//  EpubNoteListObject.m
//  E-Publishing
//
//  Created by tangsl on 15/7/9.
//
//

#import "EpubNoteListObject.h"


@implementation EpubNoteListObject
@synthesize noteIndex;
@synthesize startWordIndex;
@synthesize highlightText;
@synthesize partText;
@synthesize postion;
@synthesize noteContent;
@synthesize date;
@synthesize pageNum;
@synthesize noteColor;
@synthesize modifyNoteType;
@synthesize noteSize;
@synthesize positionDic;
@synthesize chapterIndex;
-(id)init{
    if(self = [super init])
    {
        positionDic = [[NSMutableDictionary alloc]init];
    }
    
    return self;
}

- (NSComparisonResult)compare: (EpubNoteListObject *)otherRecord
{
    NSNumber *number1 = [NSNumber numberWithInteger:self.noteIndex];
    NSNumber *number2 = [NSNumber numberWithInteger:otherRecord.noteIndex];
    
    NSComparisonResult result = [number1 compare:number2];
    
    return result == NSOrderedDescending; // 升序
    //    return result == NSOrderedAscending;  // 降序
}
-(NSDictionary *)serializeToDic
{
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    [returnDic setObject:[NSNumber numberWithInteger:noteIndex] forKey:@"noteIndex"];
    [returnDic setObject:[NSNumber numberWithInteger:startWordIndex] forKey:@"startWordIndex"];
    [returnDic setObject:highlightText forKey:@"highlightText"];
    [returnDic setObject:partText forKey:@"partText"];
    [returnDic setObject:positionDic forKey:@"positionDic"];
    if(noteContent)
    [returnDic setObject:noteContent forKey:@"noteContent"];
    [returnDic setObject:[NSNumber numberWithDouble:[date timeIntervalSince1970]] forKey:@"date"];
    [returnDic setObject:[NSNumber numberWithInteger:startWordIndex] forKey:@"pageNum"];
    [returnDic setObject:[self getDicWithColor:noteColor] forKey:@"noteColor"];
    if(modifyNoteType)
    [returnDic setObject:modifyNoteType forKey:@"modifyNoteType"];
    [returnDic setObject:@{@"left":@(postion.x),@"top":@(postion.y)} forKey:@"postion"];
    [returnDic setObject:@{@"width":@(noteSize.width),@"height":@(noteSize.height)} forKey:@"noteSize"];
    
    return returnDic;
}
-(NSDictionary *)getDicWithColor:(UIColor *)color
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return @{@"red":@(red),@"green":@(green),@"blue":@(blue),@"alpha":@(alpha)};
}


-(void)setNoteWithDic:(NSDictionary *)dic
{
    self.noteIndex = [[dic objectForKey:@"noteIndex"] integerValue];
    self.startWordIndex = [[dic objectForKey:@"startWordIndex"] integerValue];
    self.highlightText = [dic objectForKey:@"highlightText"];
    self.partText = [dic objectForKey:@"partText"];
    self.positionDic = [[dic objectForKey:@"positionDic"]mutableCopy];
    self.noteContent = [dic objectForKey:@"noteContent"];
    self.date = [[NSDate alloc]initWithTimeIntervalSince1970:[[dic objectForKey:@"date"] doubleValue]];
    self.pageNum = [[dic objectForKey:@"pageNum"] integerValue];
    self.noteColor = [UIColor colorWithRed:[dic[@"noteColor"][@"red"] floatValue] green:[dic[@"noteColor"][@"green"] floatValue] blue:[dic[@"blue"][@"red"] floatValue] alpha:[dic[@"noteColor"][@"alpha"] floatValue]];
    self.modifyNoteType = [dic objectForKey:@"modifyNoteType"];
    self.postion = CGPointMake([dic[@"postion"][@"left"] floatValue],[dic[@"postion"][@"top"] floatValue]);
    self.noteSize = CGSizeMake([dic[@"noteSize"][@"width"] floatValue], [dic[@"noteSize"][@"height"] floatValue]);
}


@end

