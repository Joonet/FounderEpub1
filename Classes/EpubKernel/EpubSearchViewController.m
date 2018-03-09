//
//  EpubSearchViewController.m
//  E-Publishing
//
//  Created by tangsl on 15/2/11.
//
//

#import "EpubSearchViewController.h"
#import "EpubChapter.h"
#import "EPUBUtils.h"
#import "SearchResultObject.h"

@interface EpubSearchViewController ()

@end
static NSString *CellIdentifier = @"EpubSeachCell";

@implementation EpubSearchViewController

@synthesize resultsArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    resultsArray = [[NSMutableArray alloc]init];
    
    // Do any additional setup after loading the view.
    [self addSubviews];
    [self setPreferredContentSize:CGSizeMake(320, 1)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


- (BOOL)shouldAutorotate
{
    return NO;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)addSubviews
{
    UIView *searchView = [[EpubNavigationBarSearchBar alloc]init];
    if (isPad == NO) {
        searchView.frame = CGRectMake(0, 0,CGRectGetWidth(self.view.frame) - 84, 64);
        //        UINavigationBar *bar = [self.navigationController navigationBar];
        //        CGRect frame = bar.frame;
        //        frame.size.height = 64;;
        //        bar.frame = frame;
        UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
        self.navigationItem.rightBarButtonItem = cancelButtonItem;
//        PDF_RELEASE(cancelButtonItem);
        UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc]initWithCustomView:searchView];
        self.navigationItem.leftBarButtonItem = searchButtonItem;
//        PDF_RELEASE(searchButtonItem);
        
    }
    else{
        searchView.frame = CGRectMake(0, 0,CGRectGetWidth(self.view.frame), 44);
        self.navigationItem.titleView = searchView;
    }
    
    
    searchBar = [[UISearchBar alloc]initWithFrame:searchView.bounds];
    [searchBar setPlaceholder:@"请输入检索词"];
    searchBar.delegate = self;
    //searchBar.showsScopeBar= NO;
    searchBar.translucent = YES;
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    //searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"本页",@"全文", nil];
    searchBar.selectedScopeButtonIndex = 1;
    [searchBar sizeToFit];
    [searchView addSubview:searchBar];
    
    
    
    
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(searchBar);
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"V:|[searchBar]|"
                            options:0
                            metrics:nil
                            views:viewsDictionary];
    
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                                              constraintsWithVisualFormat:@"H:|[searchBar]|"
                                                              options:0
                                                              metrics:nil
                                                              views:viewsDictionary]];
    
    [searchView addConstraints:constraints];
    
    resultTableView = [[UITableView alloc]init];
    resultTableView.dataSource = self;
    resultTableView.delegate = self;
    [self.view addSubview:resultTableView];
    
    NSDictionary *viewsDictionary1 = NSDictionaryOfVariableBindings(resultTableView);
    NSDictionary *metrics1 = @{@"vheight":@44};
    resultTableView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *constraints1 = [NSLayoutConstraint
                             constraintsWithVisualFormat:@"H:|[resultTableView]|"
                             options:0
                             metrics:metrics1
                             views:viewsDictionary1];
    constraints1 = [constraints1 arrayByAddingObjectsFromArray:
                    [NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:|[resultTableView]|"
                     options:0
                     metrics:metrics1
                     views:viewsDictionary1]];
    [self.view addConstraints:constraints1];
}

- (void)cancelAction:(id)sender
{
    [searchBar resignFirstResponder];
    if (isPad == NO) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return resultsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //这里做一些cell属性变换，如：
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews)
    {
        [subview removeFromSuperview];
    }
    
    
    SearchResultObject *object = [resultsArray objectAtIndex:indexPath.row];
    
    UILabel *titleLable = [[UILabel alloc]init];
    
    titleLable.font =  [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:titleLable];
    titleLable.numberOfLines = 2;
    titleLable.textAlignment = NSTextAlignmentJustified;
    
    
    
    if (object.startIndex > 30) {
        NSRange range = [object.text rangeOfComposedCharacterSequencesForRange:NSMakeRange(object.startIndex-20, object.text.length-object.startIndex+20)];
        object.text = [object.text substringWithRange:range];
        object.startIndex =object.startIndex - range.location;
        //暂时屏幕删除转义符逻辑
        //        NSMutableString *partString = [object.text mutableCopy];
        //        [partString replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, partString.length)];
        //        [partString replaceOccurrencesOfString:@"\t" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, partString.length)];
        //        [partString replaceOccurrencesOfString:@"\r" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, partString.length)];
        //        NSRange keyRange;
        //        keyRange = [partString rangeOfString:searchKey];
        //        if (keyRange.location != NSNotFound) {
        //
        //        }else{
        //
        //        }
        
    }
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:object.text];
    if (attributeString.length > object.startIndex + searchKey.length)
        [attributeString addAttribute:NSBackgroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(object.startIndex, searchKey.length)];
    
    titleLable.attributedText = attributeString;
    
    
    [EPUBUtils constrainSubview:titleLable toMatchWithSuperview:cell.contentView withHpading:10 vpading:5 width:self.view.frame.size.width-60 height:60];
    
    
    UILabel *pageLable = [[UILabel alloc]init];
    pageLable.text = [NSString stringWithFormat:@"%ld",(long)object.pageNum];
    pageLable.font =  [UIFont systemFontOfSize:18];
    pageLable.textAlignment  = NSTextAlignmentCenter;
    pageLable.textColor = [UIColor colorWithRed:159/255 green:159/255 blue:159/255 alpha:0.62];
    [cell.contentView addSubview:pageLable];
    
    [EPUBUtils constrainSubview:pageLable toMatchWithSuperview:cell.contentView withHpading:self.view.frame.size.width - 50 vpading:5 width:50 height:50];
    
    
    return cell;
    
}


-(BOOL)addResultsObject:(NSArray*)array key:(NSString *)sKey;
{
    
    if(![sKey isEqualToString:searchKey])
    {
        return NO;
    }
    
    [resultsArray addObjectsFromArray:array];
    [self resetPreferredSize];
    
    [resultTableView reloadData];
    
    return YES;
    
}

-(void)resetPreferredSize
{
    if(resultsArray.count == 0)
        return;
    NSInteger contentHeight;
    if(resultsArray.count * 70 > 1200)
    {
        contentHeight = 1024;
    }
    else
    {
        contentHeight = resultsArray.count * 70;
    }
    self.preferredContentSize = CGSizeMake(self.view.frame.size.width,contentHeight);
}

//当用户点击搜索时候调用的方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [searchBar resignFirstResponder];
    [resultsArray removeAllObjects];
    [resultTableView reloadData];
    self.preferredContentSize = CGSizeMake(self.view.frame.size.width,0);
    searchKey=[searchBar.text mutableCopy];
    [self.epubControlerDelegate searchEpubWithKey:searchKey];
}


- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0) {
        [searchBar resignFirstResponder];
        [resultsArray removeAllObjects];
        [resultTableView reloadData];
        
    }
    
}

/****************************************
 编写人：汤寿麟
 功能： 点击某个cell时候跳转到对应的页面
 时间：2014年8月20日
 ***************************************/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchResultObject *object = [resultsArray objectAtIndex:indexPath.row];
    [self.epubControlerDelegate showSearchWithTotalPage:((SearchResultObject*)[resultsArray objectAtIndex:indexPath.row]).pageNum key:searchKey position:CGPointMake(object.left, object.top)];
}
@end
