//
//  NotePoperViewController.m
//  E-Publishing
//
//  Created by tangsl on 15/4/8.
//
//

#import "EpubNotePoperViewController.h"
#import "EpubChapter.h"
#import "JSON.h"
#import "EpubNoteListObject.h"
//#import "IQKeyboardManager.h"

@interface EpubNotePoperViewController ()

@end

@implementation EpubNotePoperViewController
@synthesize textView,timeLabel,titleLabel;
@synthesize noteListObject;
@synthesize saveNoteString,exitBlock;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    textView = [[UITextView alloc]init];
    textView.editable = YES;
    textView.font = [UIFont systemFontOfSize:17];
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor colorWithRed:159/255 green:159/255 blue:159/255 alpha:0.62];
    UIView *inputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    UIButton *doneButton = [[UIButton alloc]init];
    doneButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 0, 50, 40);
    [doneButton setImage:[UIImage loadImageClass:[self class] ImageName:@"down"] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(didClickDone) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:doneButton];
    
    textView.inputAccessoryView = inputView;
    [textView resignFirstResponder];
    [self.view addSubview:textView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if(isPad)
    {
        [textView setFrame:CGRectMake(15, 15, 250, 170)];
        self.view.backgroundColor = [UIColor clearColor];
    }
    else
    {
        self.view.backgroundColor = [UIColor whiteColor];
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(exit)];
        self.navigationItem.rightBarButtonItem = doneButtonItem;
        
        
        titleLabel = [[UILabel alloc]init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font =  [UIFont systemFontOfSize:16];
        titleLabel.numberOfLines = 2;
        //titleLabel.textAlignment = NSTextAlignmentJustified;
        [self.view addSubview:titleLabel];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(titleLabel,textView);
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        textView.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *constraints = [NSLayoutConstraint
                                constraintsWithVisualFormat:@"H:|[textView]|"
                                options:0
                                metrics:nil
                                views:viewsDictionary];
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint
                        constraintsWithVisualFormat:@"H:|[titleLabel]|"
                        options:0
                        metrics:nil
                        views:viewsDictionary]];
        
        constraints = [constraints arrayByAddingObjectsFromArray:
                       [NSLayoutConstraint
                        constraintsWithVisualFormat:@"V:|-64-[titleLabel]-[textView]-100-|"
                        options:0
                        metrics:nil
                        views:viewsDictionary]];
        [self.view addConstraints:constraints];
        
    }
    if (noteListObject) {
        [self showContent];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}


-(void)didClickDone{
    [self.view endEditing:YES];
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

- (BOOL)shouldAutorotate
{
    return NO;
}

-(void)viewWillAppear:(BOOL)animated{
    
//    [IQKeyboardManager sharedManager].enable = NO;
    if(textView.text.length == 0 && ![noteListObject.modifyNoteType isEqualToString:@"append"])
    {
        //获得焦点
        [textView becomeFirstResponder];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [self sendSaveMethod];
//    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)showContent{
    if (titleLabel) {
        if(noteListObject.partText)
        {
            if (noteListObject.startWordIndex > 50) {
                NSRange range = [noteListObject.partText rangeOfComposedCharacterSequencesForRange:NSMakeRange(noteListObject.startWordIndex-20, noteListObject.partText.length-noteListObject.startWordIndex+20)];
                noteListObject.partText = [noteListObject.partText substringWithRange:range];
                noteListObject.startWordIndex =noteListObject.startWordIndex - range.location;
            }
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:noteListObject.partText];
            if (attributeString.length > noteListObject.startWordIndex + noteListObject.highlightText.length)
                [attributeString addAttribute:NSBackgroundColorAttributeName value:noteListObject.noteColor range:NSMakeRange(noteListObject.startWordIndex, noteListObject.highlightText.length)];
            else if(noteListObject.startWordIndex < attributeString.length)
                [attributeString addAttribute:NSBackgroundColorAttributeName value:noteListObject.noteColor range:NSMakeRange(noteListObject.startWordIndex,attributeString.length-noteListObject.startWordIndex-1)];
            titleLabel.attributedText = attributeString;
            
        }
    }
    textView.text = noteListObject.noteContent;
}

-(void)setNoteWithNoteObject:(EpubNoteListObject *)noteObject;
{
    self.noteListObject = noteObject;
    [self showContent];
}
-(void)exit
{
    
    [textView resignFirstResponder];
    if (self.exitBlock) {
        self.exitBlock();
    }
}

-(void)sendSaveMethod
{
    NSDictionary *dic = nil;
    if(textView.text.length == 0)
    {
        dic =@{@"modifyNoteType":noteListObject.modifyNoteType};
    }
    else
    {
        dic =@{@"content":textView.text,@"modifyNoteType":noteListObject.modifyNoteType};
    }
    if (dic) {
        SBJSON *jsonPara = [[SBJSON alloc]init];
        if(self.saveNoteString) {
            self.saveNoteString([jsonPara stringWithObject:dic]);
        }
        
        
    }
}

@end
