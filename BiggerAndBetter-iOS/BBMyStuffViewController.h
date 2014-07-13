//
//  BBMyStuffViewController.h
//  BiggerAndBetter
//
//  Created by Nik Osipov on 5/7/14.
//  Copyright (c) 2014 SafeChats Pte. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface BBMyStuffViewController : UITableViewController
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) PFObject *selectedItem;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end
