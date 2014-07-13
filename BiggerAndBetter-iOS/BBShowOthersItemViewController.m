//
//  BBShowOthersItemViewController.m
//  BiggerAndBetter
//
//  Created by Nik Osipov on 6/7/14.
//  Copyright (c) 2014 SafeChats Pte. Ltd. All rights reserved.
//

#import "BBShowOthersItemViewController.h"
#import <Parse/Parse.h>
#import "FTWCache.h"
#import "NSString+MD5.h"

@interface BBShowOthersItemViewController ()

@end

@implementation BBShowOthersItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [tempImageView setFrame:self.view.frame];
    
    [self.view insertSubview:tempImageView atIndex:0];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if( self.item )
    {
        
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            
            PFFile *imageFile = [self.item objectForKey:@"file"];
            NSURL *imageFileUrl = [[NSURL alloc] initWithString:imageFile.url];
            NSError *error = nil;
            
            NSString *key = [imageFileUrl.absoluteString MD5Hash];
            NSData *data = [FTWCache objectForKey:key];
            
            NSData *imageData;
            if(!data) {
                imageData = [NSData dataWithContentsOfURL:imageFileUrl options:NSDataReadingMappedAlways error:&error];
                [FTWCache setObject:imageData forKey:key];
            } else {
                imageData = data;
            }
            
            self.image.image = [UIImage imageWithData:imageData];
            [self.image setNeedsLayout];
            [self.image setNeedsDisplay];
            
            UIApplication* app = [UIApplication sharedApplication];
            app.networkActivityIndicatorVisible = NO;
            
        } );
        
        
        
        NSString *itemTitle = [self.item objectForKey:@"title"];
        self.navigationItem.title = itemTitle;
        
        NSString *itemDescription = [self.item objectForKey:@"description"];
        self.itemDescription.text = itemDescription;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)contactAction:(id)sender {
}
@end
