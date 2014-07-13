//
//  BBProfileViewController.m
//  BiggerAndBetter
//
//  Created by Nik Osipov on 5/7/14.
//  Copyright (c) 2014 SafeChats Pte. Ltd. All rights reserved.
//

#import "BBProfileViewController.h"
#import <Parse/Parse.h>
#import "GravatarUrlBuilder.h"

@interface BBProfileViewController ()

@end

@implementation BBProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.username.text = [[PFUser currentUser] username];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [tempImageView setFrame:self.view.frame];
    
    [self.view insertSubview:tempImageView atIndex:0];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSString *email = [[PFUser currentUser] objectForKey:@"email"];
        NSURL *gravatarURL = [GravatarUrlBuilder getGravatarUrl:email size:128];
        NSError *error = nil;
        NSData *imageData = [NSData dataWithContentsOfURL:gravatarURL options:NSDataReadingMappedAlways error:&error];
        
        if( imageData != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image.image = [UIImage imageWithData:imageData];
                [self.image setNeedsLayout];
            } );
        }
        
    } );
    
    self.image.image = [UIImage imageNamed:@"Avatar"];

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

- (IBAction)update:(id)sender {
}

- (IBAction)logout:(id)sender {
        [PFUser logOut];
        [self.tabBarController setSelectedIndex:0];
}
@end
