//
//  EpubSearchViewController.h
//  E-Publishing
//
//  Created by tangsl on 15/2/11.
//
//

#import <UIKit/UIKit.h>
#import "EpubProtocal.h"
#import "EpubNavigationBarSearchBar.h"
@interface EpubSearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    UITableView *resultTableView;
    NSMutableArray *resultsArray;
    
    NSString *searchKey;
    UISearchBar *searchBar;
    
    
}
@property (nonatomic,weak) id<EpubSearchProtocal> epubControlerDelegate;
@property (nonatomic,retain) NSMutableArray *resultsArray;


-(BOOL)addResultsObject:(NSArray*)array key:(NSString *)sKey;
-(void)resetPreferredSize;

@end
