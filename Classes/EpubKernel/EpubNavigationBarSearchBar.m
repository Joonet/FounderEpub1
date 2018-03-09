//
//  EpubNavigationBarSearchBar.m
//  FounderReader
//
//  Created by ruwin_God on 2018/1/24.
//

#import "EpubNavigationBarSearchBar.h"

@implementation EpubNavigationBarSearchBar
/*解决目的: 为了适配 iOS 11下 navigationBar 上的 SearchBar 消失不见的问题
 *问题原因: titleView支持autolayout，这要求titleView必须是能够自撑开的或实现了- intrinsicContentSize 来撑开 titleView
 *解决时间: 2018.1.23
 *解决人:  郝瑞文
 */
-(CGSize)intrinsicContentSize
{
    return UILayoutFittingExpandedSize;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
