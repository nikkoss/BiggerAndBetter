//
//  BBAddItemViewController.h
//  BiggerAndBetter
//
//  Created by Nik Osipov on 5/7/14.
//  Copyright (c) 2014 SafeChats Pte. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBAddItemViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UITextField *itemTitle;
@property (weak, nonatomic) IBOutlet UITextField *itemLocation;
@property (weak, nonatomic) IBOutlet UITextField *itemDescription;
- (IBAction)addItem:(id)sender;
- (IBAction)selectImage:(id)sender;

@end
