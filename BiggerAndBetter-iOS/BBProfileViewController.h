//
//  BBProfileViewController.h
//  BiggerAndBetter
//
//  Created by Nik Osipov on 5/7/14.
//  Copyright (c) 2014 SafeChats Pte. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBProfileViewController : UIViewController
- (IBAction)update:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *image;
- (IBAction)logout:(id)sender;

@end
