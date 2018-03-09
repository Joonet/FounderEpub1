//
//  ENoteRefViewController.m
//  E-Publishing
//
//  Created by 李 雷川 on 15/3/5.
//
//

#import "ENoteRefViewController.h"

@interface ENoteRefViewController ()<UIWebViewDelegate>
@property(nonatomic, retain)UIWebView *noteWebView;
@property(nonatomic, retain)NSString *htmlString;
@end

@implementation ENoteRefViewController
@synthesize noteWebView,htmlString;
- (NSArray *)constrainSubview:(UIView *)subview toMatchWithSuperview:(UIView *)superview
{
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(subview);
    
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"H:|[subview]|"
                            options:0
                            metrics:nil
                            views:viewsDictionary];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:|[subview]|"
                    options:0
                    metrics:nil
                    views:viewsDictionary]];
    [superview addConstraints:constraints];
    
    return constraints;
}

-(id)initWithHtmlString:(NSString *)html{
    if ([super init]) {
        if (html) {
            self.htmlString = html;
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    noteWebView = [[UIWebView alloc]init];
    noteWebView.scalesPageToFit = NO;
    noteWebView.backgroundColor = [UIColor clearColor];
    noteWebView.opaque = NO;
    [noteWebView setDelegate:self];
    noteWebView.allowsInlineMediaPlayback = YES;
    noteWebView.mediaPlaybackRequiresUserAction = NO;
    [self.view addSubview:noteWebView];
    [self constrainSubview:noteWebView toMatchWithSuperview:self.view];
    if (htmlString) {
        [noteWebView loadHTMLString:htmlString baseURL:nil];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *exitItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(exit:)];
        self.navigationItem.rightBarButtonItem = exitItem;
        
    }
    else {
        self.preferredContentSize = CGSizeMake(320,240);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)webViewDidFinishLoad:(UIWebView *)webView{
    float width = webView.scrollView.contentSize.width;
    float height = webView.scrollView.contentSize.height;
    if (height > 480) {
        height = 480;
    }
    NSLog(@"webview width and height is:%f,%f",webView.scrollView.contentSize.width,webView.scrollView.contentSize.height);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.preferredContentSize = CGSizeMake(width, height);
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)exit:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
