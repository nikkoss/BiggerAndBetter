//
//  BBShowOthersItemViewController.h
//  BiggerAndBetter
//
//  Created by Nik Osipov on 6/7/14.
//  Copyright (c) 2014 SafeChats Pte. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface BBShowOthersItemViewController : UIViewController
@property (nonatomic, strong) PFObject *item;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *itemDescription;
@property (weak, nonatomic) IBOutlet UINavigationItem *itemTitle;
- (IBAction)contactAction:(id)sender;

@end
