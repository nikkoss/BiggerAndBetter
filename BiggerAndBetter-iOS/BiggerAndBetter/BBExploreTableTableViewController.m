//
//  BBExploreTableTableViewController.m
//  BiggerAndBetter
//
//  Created by Nik Osipov on 5/7/14.
//  Copyright (c) 2014 SafeChats Pte. Ltd. All rights reserved.
//

#import "BBExploreTableTableViewController.h"
#import <Parse/Parse.h>
#import "MSCellAccessory.h"
#import "BBShowOthersItemViewController.h"
#import "FTWCache.h"
#import "NSString+MD5.h"

@interface BBExploreTableTableViewController ()

@end

@implementation BBExploreTableTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(exploreItems) forControlEvents:UIControlEventValueChanged];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     if ([PFUser currentUser]) {
         [self exploreItems];
     }
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;

}

- (void)showLogin
{
    // Create the log in view controller
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    logInViewController.fields = PFLogInFieldsUsernameAndPassword
    | PFLogInFieldsLogInButton
    | PFLogInFieldsSignUpButton;
    
    [logInViewController.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]]];
    
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    
    // Create the sign up view controller
    PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
    [signUpViewController.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]]];
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    
    // Assign our sign up controller to be displayed from the login controller
    [logInViewController setSignUpController:signUpViewController];
    
    // Present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser]) { // No user logged in
        [self showLogin];
    }
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

#pragma mark - Parse

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:NO completion:nil];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}


#pragma mark - Helper Methods

- (void)exploreItems
{
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    [query whereKey:@"ownerId" notEqualTo:[[PFUser currentUser] objectId]];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Item" forIndexPath:indexPath];
    
    PFObject *item = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"title"];
    NSString *tmp = [[NSString alloc] initWithFormat:@"100m - %@", [item objectForKey:@"description"]];
    cell.detailTextLabel.text = tmp;
    
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
        NSError* error = nil;
        
        NSString *key = [imageFileUrl.absoluteString MD5Hash];
        NSData *data = [FTWCache objectForKey:key];

        NSData *imageData;

        if(!data) {
            imageData = [NSData dataWithContentsOfURL:imageFileUrl options:NSDataReadingMappedAlways error:&error];
            [FTWCache setObject:imageData forKey:key];
        }
        else
        {
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
        [self performSegueWithIdentifier:@"showDesc" sender:self];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"showDesc"] && self.selectedItem )
    {
        BBShowOthersItemViewController *viewController = (BBShowOthersItemViewController *)segue.destinationViewController;
        viewController.item = self.selectedItem;
    }
}

@end
