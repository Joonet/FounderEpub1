//
//  PaperImageBrowserController.m
//  DoingPaper_LS
//
//  Created by zhuxuhong on 2016/12/8.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "PaperImageBrowserController.h"

@interface PaperImageBrowserController ()<UIScrollViewDelegate>

@property(nonatomic,copy)UIScrollView *scrollView;
@property(nonatomic,copy)UIImageView *imageView;
@property(nonatomic)CGRect fromFrame;
@property(nonatomic)CGRect toFrame;

@end

@implementation PaperImageBrowserController
{
    UIImageView *_placeImageView;
    UIImage *_image;
    PaperImageBrowserCompletion _showCompletion;
    PaperImageBrowserCompletion _dismissCompletion;
}

-(instancetype)initWithPlaceImageView: (UIImageView *)imageView
                       showCompletion: (PaperImageBrowserCompletion)show
                    dismissCompletion: (PaperImageBrowserCompletion)dismiss{
    self = [[PaperImageBrowserController alloc] initWithPlaceImageView:imageView];
    _showCompletion = show;
    _dismissCompletion = dismiss;
    return self;
}

-(instancetype)initWithPlaceImageView:(UIImageView *)imageView{
    if (self = [super init]) {
        _placeImageView = imageView;
        _image = imageView.image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.scrollView];
}

-(void)showWithAnimation{
    [_placeImageView removeFromSuperview];
    _imageView.hidden = false;
    _imageView.frame = self.fromFrame;

    [UIView animateWithDuration:0.5 animations:^{
        _imageView.frame = self.toFrame;
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    } completion:^(BOOL finished) {
        _showCompletion ? _showCompletion() : nil;
//        if (_toFrame.size.height > self.view.bounds.size.height) {
//            _scrollView.zoomScale = 0.5;
//        }
    }];
}

-(void)closeWithAnimation{
    _scrollView.contentOffset = CGPointZero;
    _imageView.center = self.view.center;
    
    [UIView animateWithDuration:0.5 animations:^{
        _imageView.frame = self.fromFrame;
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:false completion:^{
            _dismissCompletion ? _dismissCompletion() : nil;
        }];
    }];
}

#pragma mark - getters & setters
-(UIScrollView *)scrollView{
    if (!_scrollView) {
        UIScrollView *sc = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        sc.minimumZoomScale = 0.05;
        sc.maximumZoomScale = 4.0;
        sc.delegate = self;
        sc.showsVerticalScrollIndicator = false;
        sc.showsHorizontalScrollIndicator = false;
        [sc addSubview:self.imageView];
        
        _scrollView = sc;
    }
    return _scrollView;
}

-(UIImageView *)imageView{
    if (!_imageView) {
        UIImageView *iv = [[UIImageView alloc] initWithImage:_placeImageView.image];
        iv.hidden = true;
        iv.userInteractionEnabled = true;

        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        tap.numberOfTapsRequired = 1;//单击
        tap.numberOfTouchesRequired = 1;//单点触碰
        [iv addGestureRecognizer:tap];
        [self.view addGestureRecognizer:tap];
        
        _imageView = iv;
    }
    return _imageView;
}

-(CGRect)fromFrame{
    if (_fromFrame.size.width == 0) {
        // 坐标转换
        CGPoint org = [self.view convertPoint:_placeImageView.frame.origin fromView:_placeImageView.superview];
        _fromFrame = CGRectMake(org.x, org.y, _placeImageView.frame.size.width, _placeImageView.frame.size.height);
    }
    return _fromFrame;
}

-(CGRect)toFrame{
    if (_toFrame.size.width == 0)
    {
        CGFloat ratio = _image.size.height / _image.size.width;
        CGFloat h = ratio * [self screenW];
        _toFrame = CGRectMake(0, 0, [self screenW], h);
        
        // 居中显示
        if (h > [self screenH]) {
            _scrollView.contentSize = _imageView.bounds.size;
        }
        else{
            CGFloat y = ([self screenH] - h) * 0.5;
            _scrollView.contentInset = UIEdgeInsetsMake(y, 0, 0, y);
        }
    }
    return _toFrame;
}

-(CGFloat)screenW{
    return CGRectGetWidth([UIScreen mainScreen].bounds);
}

-(CGFloat)screenH{
    return CGRectGetHeight([UIScreen mainScreen].bounds); // 状态栏
}
                           
#pragma mark - UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    // 注意: scrollview缩放内部的实现原理其实是利用transform实现的,
    // 如果是利用transform缩放控件, 那么bounds不会改变, 只有frame会改变
    
    // 重新调整图片的位置
    CGFloat offsetY = ([self screenH] - _imageView.frame.size.height) * 0.5;
    
    // 注意: 如果offsetY是负数, 会导致高度显示不完整
    offsetY = offsetY < 0 ? 0 : offsetY;
    
    CGFloat offsetX = ([self screenW] - _imageView.frame.size.width) * 0.5;
    
    // 注意: 如果offsetX负数, 会导致高度显示不完整
    offsetX = offsetX < 0 ? 0 : offsetX;
    
    scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, offsetY, offsetX);
}

-(void)tap: (UITapGestureRecognizer*)gesture{
    [self closeWithAnimation];
}

-(void)doubleTap: (UITapGestureRecognizer*)tap{
    if (_scrollView.zoomScale < _scrollView.maximumZoomScale) {
        [UIView animateWithDuration:0.5 animations:^{
            _scrollView.zoomScale = _scrollView.maximumZoomScale;
        }];
    }
    else{
        [UIView animateWithDuration:0.5 animations:^{
            _scrollView.zoomScale = 1.0;
        }];
    }
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _imageView.hidden = true;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    _imageView.hidden = false;
    
    _scrollView.frame = self.view.bounds;
    
    _toFrame = CGRectZero;
    [self showWithAnimation];
    
    
}

-(BOOL)prefersStatusBarHidden{
    return false;
}

@end
