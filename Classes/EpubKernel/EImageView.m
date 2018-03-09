//
//  EImageView.m
//  E-Publishing
//
//  Created by 李 雷川 on 15/3/6.
//
//

#import "EImageView.h"

@implementation EImageView
@synthesize imageView,exitBlock;
- (void )constrainSubview:(UIView *)subview toMatchWithSuperview:(UIView *)superview
{
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-20]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-20]];
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
}

- (void )updateFullConstrainSubview:(UIView *)subview toMatchWithSuperview:(UIView *)superview
{
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
}

-(id)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        
        
    }
    return self;
}
-(id)init
{
    if([super init])
    {
        self.backgroundColor =[UIColor clearColor];
        imageView = [[UIImageView alloc]init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        [self constrainSubview:imageView toMatchWithSuperview:self];
        
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 4.0;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.directionalLockEnabled = YES;
        self.delegate = self;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exit:)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
    
}

// 单击退出
-(void)exit: (UITapGestureRecognizer*)tap{
    if (self.exitBlock) {
        self.exitBlock();
    }
}

-(void)reloadConstraints{
    [self removeConstraints:self.constraints];
    [self updateFullConstrainSubview:imageView toMatchWithSuperview:self];
    [self layoutIfNeeded];
    
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}


@end
