//
//  FileViewController.h
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/18.
//  Copyright © 2019 Gary. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
