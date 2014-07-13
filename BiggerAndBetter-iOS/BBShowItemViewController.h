//
//  BBShowItemViewController.h
//  BiggerAndBetter
//
//  Created by Nik Osipov on 5/7/14.
//  Copyright (c) 2014 SafeChats Pte. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface BBShowItemViewController : UIViewController
@property (nonatomic, strong) PFObject *item;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *itemDescription;
- (IBAction)delete:(id)sender;


@end
