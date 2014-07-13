//
//  BBMyStuffViewController.m
//  BiggerAndBetter
//
//  Created by Nik Osipov on 5/7/14.
//  Copyright (c) 2014 SafeChats Pte. Ltd. All rights reserved.
//

#import "BBMyStuffViewController.h"
#import <Parse/Parse.h>
#import "MSCellAccessory.h"
#import "BBShowItemViewController.h"
#import "FTWCache.h"
#import "NSString+MD5.h"

@interface BBMyStuffViewController ()

@end

@implementation BBMyStuffViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(retrieveItems) forControlEvents:UIControlEventValueChanged];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
     [self retrieveItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PFObject *item = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"title"];
    cell.detailTextLabel.text = [item objectForKey:@"description"];
    
    UIColor *disclosureColor = [UIColor colorWithRed:0.208 green:0.267 blue:0.525 alpha:1.0];
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:disclosureColor];
    
    NSString *fileType = [item objectForKey:@"fileType"];
    if( !cell.imageView.image )
    {
        if( [fileType isEqualToString:@"image"] )
        {
            cell.imageView.image = [UIImage imageNamed:@"icon_image"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"icon_video"];
        }
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PFFile *imageFile = [item objectForKey:@"file"];
        NSURL *imageFileUrl = [[NSURL alloc] initWithString:imageFile.url];
        NSError *error = nil;
        
        NSString *key = [imageFileUrl.absoluteString MD5Hash];
        NSData *data = [FTWCache objectForKey:key];
        
        NSData *imageData;
        
        if(!data) {
            imageData = [NSData dataWithContentsOfURL:imageFileUrl  options:NSDataReadingMappedAlways error:&error];
            [FTWCache setObject:imageData forKey:key];
        } else {
            imageData = data;
        }
        
        if( imageData != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = [UIImage imageWithData:imageData];
                [cell setNeedsLayout];
            } );
        }
        
    } );
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedItem = [self.items objectAtIndex:indexPath.row];
    NSString *fileType = [self.selectedItem objectForKey:@"fileType"];
    
    if( [fileType isEqualToString:@"image"] )
    {
        [self performSegueWithIdentifier:@"showItem" sender:self];
    } else
    {
/*        PFFile *videoFile = [self.selectedMessage objectForKey:@"file"];
        NSURL *fileURL = [NSURL URLWithString:videoFile.url];
        self.moviePlayer.contentURL = fileURL;
        [self.moviePlayer prepareToPlay];
        
        UIImage *thumbnail = [self thumbnailFromVideoAtURL:self.moviePlayer.contentURL];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:thumbnail];
        [self.moviePlayer.backgroundView addSubview:imageView];
        
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
 */
    }
}

#pragma mark - Helper Methods

- (void)retrieveItems
{
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query whereKey:@"ownerId" equalTo:[[PFUser currentUser] objectId]];
    [query orderByDescending:@"createdAt"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if( error ) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            // We found messages
            self.items = objects;
            [self.tableView reloadData];
            NSLog(@"Retrieved %d items", [self.items count]);
        }
        
        if( [self.refreshControl isRefreshing] )
        {
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"showItem"] )
    {
        BBShowItemViewController *viewController = (BBShowItemViewController *)segue.destinationViewController;
        viewController.item = self.selectedItem;
    }
}

@end
