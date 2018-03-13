//
//  ChapterListViewController.m
//  testPubb
//
//  Created by tang shoulin on 3/20/14.
//
//

#import "EPUBChapterListViewController.h"
#import "EpubStaticDefine.h"
#import "TeaRecord.h"
#import "StatisticsManager.h"
#import "JSON.h"
#import "EPUBUtils.h"
#import "EpubListObject.h"
#import "EpubNoteListObject.h"
#import "EpubMarkObject.h"
#import "HYToast.h"

static NSString *CellIdentifier = @"EpubCell";

@interface EPUBChapterListViewController ()

@end

@implementation EPUBChapterListViewController
@synthesize chaperArray;
@synthesize listTableView;

@synthesize bookMarkArray;
@synthesize noteListArray;


#pragma mark ---------------superclass method-------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        tableFlag = EPUB_DIRECTORY_FLAG;
        chaperArray = nil;
        bookMarkArray = nil;
//        alreadyHighlightChapter = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}
#endif


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}











#pragma mark ---------------business method-------------------
/**
 *	@brief	exit chapter list view
 *

 */
-(void)exit
{
    [self.delegate removeChapterListView];
}

/**
 *	@brief	segment click method
 *
 *	@param 	Seg 	sender
 *
 */
-(void)optionSegmentAction:(UISegmentedControl *)Seg

{
    NSInteger Index = Seg.selectedSegmentIndex;
    
    switch (Index) {
        case 0:
//            alreadyHighlightChapter = NO;
            listTableView.hidden = NO;
            tableFlag = EPUB_DIRECTORY_FLAG;
            self.chaperArray = [self.delegate getChapterListArray];
            if(chaperArray.count > 0)
            {
                [listTableView reloadData];
            }
            else
            {
                listTableView.hidden = YES;
				[HYToast showHUDTo:self.view title:@"暂无目录数据" style:HYToastHUDStyleTips delay:1];
            }
            
            break;
        case 1:
            listTableView.hidden = NO;
            tableFlag = EPUB_BOOKMARK_FLAG;
            self.bookMarkArray = [[self.delegate getBookMarkArray] sortedArrayUsingSelector:@selector(compare:)];
            if(bookMarkArray.count > 0)
            {
                [listTableView reloadData];
                
            }
            else
            {
                listTableView.hidden = YES;
				[HYToast showHUDTo:self.view title:@"暂无书签数据" style:HYToastHUDStyleTips delay:1];
            }
            break;
        case 2:
            listTableView.hidden = NO;
            tableFlag = EPUB_NOTE_FLAG;
            self.noteListArray = [self.delegate getNoteListArray];
            if(noteListArray.count > 0)
            {
                [listTableView reloadData];
            }
            else
            {
                listTableView.hidden = YES;
				[HYToast showHUDTo:self.view title:@"暂无笔记数据" style:HYToastHUDStyleTips delay:1];
            }
            
            break;
        default:
            break;
    }
}


/**
 *	@brief	init subviews and add to view
 *
 *	@return	void
 */
-(void)setAllSubView

{
    UINavigationBar *naviBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,DIRECTORY_WHOLE_HEIGHT)];
    [self.view addSubview:naviBar];
    naviBar.barTintColor = self.view.backgroundColor;
    
    //创建一个导航栏集合
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@""];
    
    
    NSArray *navigateArray = [[NSArray alloc]initWithObjects:@"目录",@"书签",@"笔记",nil];
    
    //初始化UISegmentedControl
    segMentControl = [[UISegmentedControl alloc]initWithItems:navigateArray];
    
    segMentControl.tintColor = [UIColor colorWithRed:23/255.0 green:170/255.0 blue:230/255.0 alpha:1];

    segMentControl.selectedSegmentIndex = 0;//设置默认选择项索引
    //segmentedControl.tintColor = [UIColor redColor];
    [naviBar addSubview:segMentControl];
    
    [segMentControl addTarget:self action:@selector(optionSegmentAction:)forControlEvents:UIControlEventValueChanged];
    
    
    int segMentControlWidth;
    if(isPad)
    {
        segMentControlWidth = 103;
    }
    else
    {
        segMentControlWidth = 80;
    }
    
    [segMentControl setFrame:CGRectMake(self.view.frame.size.width/2-segMentControlWidth*1.5, (DIRECTORY_WHOLE_HEIGHT - DIRECTORY_BTN_HEIGHT)/2, segMentControlWidth*3, DIRECTORY_BTN_HEIGHT)];
    
    
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(exit)];
    [doneButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    navigationItem.leftBarButtonItem = doneButtonItem;
    
    
    
    [naviBar pushNavigationItem:navigationItem animated:NO];
    
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(naviBar);
    NSDictionary *metrics = @{@"vheight":@80};
    naviBar.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"H:|[naviBar]|"
                            options:0
                            metrics:metrics
                            views:viewsDictionary];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:|[naviBar(vheight)]"
                    options:0
                    metrics:metrics
                    views:viewsDictionary]];
    [self.view addConstraints:constraints];
    
    
    //章节列表的tableview
    listTableView = [[UITableView alloc]init];
    //下面的这个方法如果使用之前的调用方法dequeueReusableCellWithIdentifier:forIndexPath: 则不用写
    listTableView.dataSource = self;
    listTableView.delegate = self;
    [self.view addSubview:listTableView];
    
    listTableView.backgroundColor = [UIColor clearColor];
    if(chaperArray.count == 0)
    {
        listTableView.hidden = YES;
    }
    
    NSDictionary *viewsDictionary2 = NSDictionaryOfVariableBindings(listTableView);
    NSDictionary *metrics2 = @{@"nMargin2":@(44),@"hMargin":@(DIRECTORY_SEGMENT_WIDTH),@"nMargin":@(DIRECTORY_WHOLE_HEIGHT)};
    listTableView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *constraints2 = [NSLayoutConstraint
                             constraintsWithVisualFormat:@"H:|[listTableView]-hMargin-|"
                             options:0
                             metrics:metrics2
                             views:viewsDictionary2];
    constraints2 = [constraints2 arrayByAddingObjectsFromArray:
                    [NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:|-nMargin-[listTableView]-nMargin2-|"
                     options:0
                     metrics:metrics2
                     views:viewsDictionary2]];
    [self.view addConstraints:constraints2];
    
    
    
    
    UIToolbar* bottomBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height-44, self.view.frame.size.width, 44)];
    [self.view addSubview:bottomBar];
    bottomBar.barTintColor = self.view.backgroundColor;
    
    NSDictionary *viewsDictionary1 = NSDictionaryOfVariableBindings(bottomBar);
    NSDictionary *metrics1 = @{@"vheight":@44};
    bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *constraints1 = [NSLayoutConstraint
                             constraintsWithVisualFormat:@"H:|[bottomBar]|"
                             options:0
                             metrics:metrics1
                             views:viewsDictionary1];
    constraints1 = [constraints1 arrayByAddingObjectsFromArray:
                    [NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:[bottomBar(vheight)]|"
                     options:0
                     metrics:metrics1
                     views:viewsDictionary1]];
    [self.view addConstraints:constraints1];
    
}

/**
 *	@brief	generate source again and reload data
 *
 *	@return	void
 */
-(void)resetContent

{
    int segMentControlWidth;
    if(isPad)
    {
        segMentControlWidth = 103;
    }
    else
    {
        segMentControlWidth = 90;
    }
    
    
    [segMentControl setFrame:CGRectMake(self.view.frame.size.width/2-segMentControlWidth*1.5, (DIRECTORY_WHOLE_HEIGHT - DIRECTORY_BTN_HEIGHT)/2, segMentControlWidth*3, DIRECTORY_BTN_HEIGHT)];
    [self optionSegmentAction:segMentControl];
}

#pragma mark ----------tableview delegatemethod---------------


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableFlag == EPUB_BOOKMARK_FLAG)
    {
        EpubMarkObject *markObject = [bookMarkArray objectAtIndex:indexPath.row];
        [self.delegate showPageWithChapter:markObject.chapterIndex page:markObject.pageNum jsMark:nil];
    }
    else if (tableFlag == EPUB_DIRECTORY_FLAG)
    {
        [self.delegate showPageWithChapter:((EpubListObject*)[chaperArray objectAtIndex:indexPath.row]).chapterIndex page:1 jsMark:((EpubListObject*)[chaperArray objectAtIndex:indexPath.row]).listMark];
    }
    else if (tableFlag == EPUB_NOTE_FLAG)
    {
        [self.delegate showTotalPage:((EpubNoteListObject*)[noteListArray objectAtIndex:indexPath.row]).pageNum];
    }
}

#pragma mark ----------tableview datasourcemethod---------------
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    
    cell.backgroundColor = [UIColor clearColor];
    if(tableFlag == EPUB_DIRECTORY_FLAG)
    {
        
        EpubListObject *listObject = [chaperArray objectAtIndex:indexPath.row];
        

        
        //主标题图标view
        UIImageView *mainTitleIconImageView = [[UIImageView alloc]init];
        [mainTitleIconImageView setImage:[UIImage loadImageClass:[self class] ImageName:@"EPUB_MainTitle_Icon"]];
        [cell.contentView addSubview:mainTitleIconImageView];
        
        
        UILabel*mainTIleLab = [[UILabel alloc]init];
        mainTIleLab.text =listObject.listName;
        [cell.contentView addSubview:mainTIleLab];
        
        
        if(listObject.chapterIndex == [self.delegate getNowChapterIndex]){
            mainTIleLab.textColor = [UIColor colorWithRed:23/255.0 green:170/255.0 blue:230/255.0 alpha:1];
//            alreadyHighlightChapter = YES;
        }
        else
        {
            mainTIleLab.textColor = [UIColor blackColor];
        }
        
        [EPUBUtils constrainSubview:mainTitleIconImageView toMatchWithSuperview:cell.contentView withHpading:DIRECTORY_TITLE_MARGIN_LEFT+20*(listObject.layer-1) vpading:(DIRECTORY_TITLE_HEIGHT-DIRECTORY_TITLE_ICON_WIDTH)/2 width:DIRECTORY_TITLE_ICON_WIDTH height:DIRECTORY_TITLE_ICON_WIDTH];
        [EPUBUtils constrainSubview:mainTIleLab toMatchWithSuperview:cell.contentView withHpading:DIRECTORY_WORD_MARGIN_LEGT+20*(listObject.layer-1) vpading:0 width:listTableView.frame.size.width-DIRECTORY_WORD_MARGIN_LEGT-40 height:DIRECTORY_TITLE_HEIGHT];
    }
    else if(tableFlag == EPUB_BOOKMARK_FLAG)
    {
        if (bookMarkArray.count < indexPath.row) {
            return nil;
        }
        EpubMarkObject *markObject = [bookMarkArray objectAtIndex:indexPath.row];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strDate = [dateFormatter stringFromDate:markObject.date];
        NSLog(@"%@", strDate);
        
        
        NSString *bookMarkName = nil;
        if(markObject.title)
        {
            if(markObject.title.length > 39)
            {
                bookMarkName = [markObject.title substringToIndex:38];
            }
            else
            {
                bookMarkName = markObject.title;
            }
        }
        
        UILabel *titleLable = [[UILabel alloc]init];
        titleLable.text = bookMarkName;
        
        titleLable.font =  [UIFont systemFontOfSize:22];
        [cell.contentView addSubview:titleLable];
        
        [EPUBUtils constrainSubview:titleLable toMatchWithSuperview:cell.contentView withHpading:30 vpading:0 width:listTableView.frame.size.width-90 height:40];
        
        
        UILabel *timeLable = [[UILabel alloc]init];
        timeLable.text = strDate;
        timeLable.textColor = [UIColor colorWithRed:159/255 green:159/255 blue:159/255 alpha:0.62];
        [cell.contentView addSubview:timeLable];
        
        [EPUBUtils constrainSubview:timeLable toMatchWithSuperview:cell.contentView withHpading:55 vpading:40 width:listTableView.frame.size.width-150 height:20];
        
        UIImageView *imageView =[[UIImageView alloc]init];
        [imageView setImage:[UIImage loadImageClass:[self class] ImageName:@"EPUB_ChapterNote_icon"]];
        [cell.contentView addSubview:imageView];
        
        [EPUBUtils constrainSubview:imageView toMatchWithSuperview:cell.contentView withHpading:30 vpading:40 width:8 height:16];
        
        UILabel *pageLable = [[UILabel alloc]init];
        pageLable.text = [NSString stringWithFormat:@"%ld",(long)markObject.bookPageNum];
        pageLable.font =  [UIFont systemFontOfSize:30];
        pageLable.textAlignment = NSTextAlignmentRight;
        pageLable.textColor = [UIColor colorWithRed:159/255 green:159/255 blue:159/255 alpha:0.62];
        [cell.contentView addSubview:pageLable];
        
        [EPUBUtils constrainSubview:pageLable toMatchWithSuperview:cell.contentView withHpading:listTableView.frame.size.width - 73 vpading:0 width:70 height:50];
    }
    else if(tableFlag == EPUB_NOTE_FLAG)
    {
        if (noteListArray.count < indexPath.row) {
            return nil;
        }
        EpubNoteListObject*noteObject = [noteListArray objectAtIndex:indexPath.row];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strDate = [dateFormatter stringFromDate:noteObject.date];
        NSLog(@"%@", strDate);
        
        
        UILabel *titleLable = [[UILabel alloc]init];
        //        titleLable.text = noteObject.partText;
        
        titleLable.font =  [UIFont systemFontOfSize:22];
        [cell.contentView addSubview:titleLable];
        titleLable.numberOfLines = 2;
        titleLable.textAlignment = NSTextAlignmentJustified;
        
        if(isPad)
        {
            if (noteObject.startWordIndex > 60) {
                
                NSRange range = [noteObject.partText rangeOfComposedCharacterSequencesForRange:NSMakeRange(noteObject.startWordIndex-30, noteObject.partText.length-noteObject.startWordIndex+30)];
                noteObject.partText = [noteObject.partText substringWithRange:range];
                noteObject.startWordIndex =noteObject.startWordIndex - range.location;
                
                
            }
        }
        else
        {
            if (noteObject.startWordIndex > 40) {
                NSRange range = [noteObject.partText rangeOfComposedCharacterSequencesForRange:NSMakeRange(noteObject.startWordIndex-20, noteObject.partText.length-noteObject.startWordIndex+20)];
                noteObject.partText = [noteObject.partText substringWithRange:range];
                noteObject.startWordIndex =noteObject.startWordIndex - range.location;
            }
        }
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:noteObject.partText];
        if (attributeString.length > noteObject.startWordIndex + noteObject.highlightText.length)
            [attributeString addAttribute:NSBackgroundColorAttributeName value:noteObject.noteColor range:NSMakeRange(noteObject.startWordIndex, noteObject.highlightText.length)];
        else if(noteObject.startWordIndex < attributeString.length)
            [attributeString addAttribute:NSBackgroundColorAttributeName value:noteObject.noteColor range:NSMakeRange(noteObject.startWordIndex,attributeString.length-noteObject.startWordIndex-1)];
        
        titleLable.attributedText = attributeString;
        
        [EPUBUtils constrainSubview:titleLable toMatchWithSuperview:cell.contentView withHpading:30 vpading:0 width:listTableView.frame.size.width-100 height:80];
        
        UILabel *contentLable = [[UILabel alloc]init];
        contentLable.text = noteObject.noteContent;
        
        contentLable.font =  [UIFont systemFontOfSize:22];
        [cell.contentView addSubview:contentLable];
        contentLable.textColor = [UIColor colorWithRed:159/255 green:159/255 blue:159/255 alpha:0.62];
        
        [EPUBUtils constrainSubview:contentLable toMatchWithSuperview:cell.contentView withHpading:30 vpading:60 width:listTableView.frame.size.width-200 height:40];
        
        UILabel *timeLable = [[UILabel alloc]init];
        timeLable.text = strDate;
        timeLable.textColor = [UIColor colorWithRed:159/255 green:159/255 blue:159/255 alpha:0.62];
        [cell.contentView addSubview:timeLable];
        
        [EPUBUtils constrainSubview:timeLable toMatchWithSuperview:cell.contentView withHpading:listTableView.frame.size.width - 170 vpading:73 width:170 height:20];
        
        
        UILabel *pageLable = [[UILabel alloc]initWithFrame:CGRectMake(listTableView.frame.size.width - 40, 0, 100, 50)];
        pageLable.text = [NSString stringWithFormat:@"%zd",noteObject.pageNum];
        pageLable.font =  [UIFont systemFontOfSize:22];
        pageLable.textColor = [UIColor colorWithRed:159/255 green:159/255 blue:159/255 alpha:0.62];
        [cell.contentView addSubview:pageLable];
        
        [EPUBUtils constrainSubview:pageLable toMatchWithSuperview:cell.contentView withHpading:listTableView.frame.size.width - 50 vpading:5 width:100 height:40];
    }
    
    
    return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    return [[chaperArray objectAtIndex:section] count]-1;
    if(tableFlag == EPUB_DIRECTORY_FLAG)
        return chaperArray.count;
    else if(tableFlag == EPUB_BOOKMARK_FLAG)
        return bookMarkArray.count;
    else
        return noteListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0;
    if(tableFlag == EPUB_DIRECTORY_FLAG)
    {
        cellHeight = DIRECTORY_TITLE_HEIGHT;
    }
    else if(tableFlag == EPUB_BOOKMARK_FLAG)
    {
        cellHeight = 70;
    }
    else if(tableFlag == EPUB_NOTE_FLAG)
    {
        cellHeight = 100;
    }
    
    return cellHeight;
}
@end
