# FounderEpub

FounderEpub是一款基于原有的橙立方中的EPub中的库独立出来的EPub阅读器,方便集成与使用.

### 主要特点

	1.阅读epub格式的文件
	2.独立的便签,高亮,书签等记录,再次进入后自动保留
	3.支持文件内容的搜索
	
### 使用

	使用cocoapod方便集成,在podfile中添加
	pod ‘FounderEpub’

在您需要使用的地方引入头文件 

	#import <EPUB.h>

在需要调用的地方创建对象并调用

```
EPUB *epub = [EPUB shareEpub];
//注意,这个地方传入的path为epub解压后的主文件目录,需要在沙盒中,bundle目录中是不行的
EPubMainViewController *mainController = [epub epubMainViewControllerWithFilePath:path]; 
[self.navigationController pushViewController:mainController animated:YES];
self.navigationController.navigationBarHidden = YES;
```

需要为成epub对象的代理,并实现代理方法

```	
epub.delegate = self;

-(void)backToShelf {
    [self.navigationController popViewControllerAnimated:YES];
}
```

注意: 目前为第一个版本,还有几个问题尚未解决

* 图片文件和epub内核中需要的js库还未添加到库中,会在下一个版本中完善
* 在是用模拟器运行时,因为每次运行,模拟器的目录是在变化的,所以导致便签书签等的记录有问题(建议优先使用真机测试)

