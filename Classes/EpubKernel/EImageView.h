//
//  EImageView.h
//  E-Publishing
//
//  Created by 李 雷川 on 15/3/6.
//
//

#import <UIKit/UIKit.h>

@interface EImageView : UIScrollView<UIScrollViewDelegate>

@property(nonatomic, retain)UIImageView *imageView;
@property(nonatomic, copy)dispatch_block_t exitBlock;

-(void)reloadConstraints;
@end
