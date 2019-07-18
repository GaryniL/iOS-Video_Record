//
//  FileViewController.m
//  VideoRecordAPP
//
//  Created by Gary on 2019/7/18.
//  Copyright © 2019 Gary. All rights reserved.
//

#import "FileViewController.h"
#import "VideoPreviewController.h"

@interface FileViewController ()

@end

@implementation FileViewController{
    NSMutableArray *mp3Files;
    NSString *documentsDirectoryPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getMP4Files];
    [self setupUI];
}

- (void)setupUI{
    // UINavigation related
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"關閉" style:UIBarButtonItemStyleDone target:self action:@selector(dismissVC)];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    
    [self setupContraints];
}

- (void)setupContraints{
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
}

- (void)getMP4Files{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectoryPath = [paths objectAtIndex:0];
    
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    mp3Files = [[NSMutableArray alloc] init];
    
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];
        if ([extension isEqualToString:@"mp4"]) {
            [self->mp3Files addObject:filename];
        }
    }];
    
    NSLog(@"%@",mp3Files);
}

- (void)dismissVC{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Delegate <UITableView>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mp3Files.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = mp3Files[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *thisURL = [NSString stringWithFormat:@"file:///%@/%@",documentsDirectoryPath,mp3Files[indexPath.row]];
    NSLog(@"%@",thisURL);
    
    VideoPreviewController *previewController = [[VideoPreviewController alloc] init];
    previewController.videoURL = [NSURL URLWithString:thisURL];
    [self.navigationController pushViewController:previewController animated:YES];
}


@end
