//
//  BBAddItemViewController.m
//  BiggerAndBetter
//
//  Created by Nik Osipov on 5/7/14.
//  Copyright (c) 2014 SafeChats Pte. Ltd. All rights reserved.
//

#import "BBAddItemViewController.h"
#import <Parse/Parse.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface BBAddItemViewController ()

@end

@implementation BBAddItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.itemTitle.delegate = self;
    self.itemLocation.delegate = self;
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [tempImageView setFrame:self.view.frame];
    
    [self.view insertSubview:tempImageView atIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)addItem:(id)sender {
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    
    if( self.picture != nil )
    {
        UIImage *newImage = [self resizeImage:self.picture.image toWidth:320.0f andHeight:480.0f];
        fileData = UIImagePNGRepresentation(newImage);
        fileName = @"image.png";
        fileType = @"image";
    } else {
/*        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = @"video.mov";
        fileType = @"video";
*/
    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if( error ) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred" message:@"Please try adding an item again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
        } else {
            PFObject *item = [PFObject objectWithClassName:@"Item"];
            
            [item setObject:file forKey:@"file"];
            [item setObject:fileType forKey:@"fileType"];
            [item setObject:self.itemTitle.text forKey:@"title"];
            [item setObject:self.itemDescription.text forKey:@"description"];
            [item setObject:self.itemLocation.text forKey:@"location"];
            
//            [item setObject:self.recipients forKey:@"recipientsIds"];
            [item setObject:[[PFUser currentUser] objectId] forKey:@"ownerId"];
            [item setObject:[[PFUser currentUser] username] forKey:@"ownerName"];
            
            [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if( error ) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred" message:@"Please try adding an item again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    
                    [alertView show];
                } else {
                    [self reset];
                }
            }];
        }
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helper Methods
- (UIImage *) resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height
{
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    
    UIGraphicsBeginImageContext(newSize);
    [self.picture.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (void)reset
{
    self.picture= nil;
//    self.videoFilePath = nil;
}

- (IBAction)selectImage:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - Image Picker Controller Delegate

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
//    [self.tabBarController setSelectedIndex:0];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if( [mediaType isEqualToString:(NSString *)kUTTypeImage] )
    {
        // image
        self.picture.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    } else {
        // video
//        self.videoFilePath = (NSString *)[[info objectForKey:UIImagePickerControllerMediaURL] path];
        
//        if( UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath) )
//            UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
        [theTextField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //hides keyboard when another part of layout was touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}
@end
