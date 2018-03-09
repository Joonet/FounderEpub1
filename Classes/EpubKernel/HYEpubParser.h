//  HYEpubParser.h
//  E-Publishing
//
//  Created by tangsl on 14-7-31.
//
//ECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "HYEpubConstants.h"
#import "DDXMLDocument.h"

@class HYEpubParser;


@interface HYEpubParser : NSObject

//得到toc目录路径
- (NSURL *)tocFileForBaseURL:(NSURL *)baseURL;
//得到书本的章节数组
- (NSArray *)getBookChapterListDic:(DDXMLDocument *)document;

- (HYEpubKitBookType)bookTypeForBaseURL:(NSURL *)baseURL;

- (HYEpubKitBookEncryption)contentEncryptionForBaseURL:(NSURL *)baseURL;

- (NSURL *)rootFileForBaseURL:(NSURL *)baseURL;

- (NSString *)coverPathComponentFromDocument:(DDXMLDocument *)document;

- (NSDictionary *)metaDataFromDocument:(DDXMLDocument *)document;

- (NSArray *)spineFromDocument:(DDXMLDocument *)document;

- (NSDictionary *)manifestFromDocument:(DDXMLDocument *)document;

- (NSArray *)guideFromDocument:(DDXMLDocument *)document;


@end
