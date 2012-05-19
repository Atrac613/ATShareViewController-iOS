//
//  MasterViewController.m
//  ATShareViewController
//
//  Created by Osamu Noguchi on 5/19/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController () {

}
@end

@implementation MasterViewController


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Button Action

- (IBAction)shareButtonPressed:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ATShareViewStoryboard" bundle:nil];
    ATShareViewController *shareViewController = [storyboard instantiateViewControllerWithIdentifier:@"ATShareViewController"];
    shareViewController.delegate = self;
    [self presentModalViewController:shareViewController animated:YES];
}

#pragma mark ATShareViewController delegate
- (void)shareViewController:(ATShareViewController *)controller didFinishWithResult:(ATShareViewControllerResult)result {
    NSString *message;
    switch (result) {
        case ATShareViewControllerResultCancelled:
            message = NSLocalizedString(@"SHARE_CANCELED", @"");
            break;
        case ATShareViewControllerResultSent:
            message = NSLocalizedString(@"SHARE_SENT", @"");
            break;
        case ATShareViewControllerResultFailed:
            message = NSLocalizedString(@"SHARE_FAILED", @"");
            break;
        default:
            message = NSLocalizedString(@"SHARE_NOT_SENT", @"");
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SEND_TWITTER_OR_FACEBOOK", @"") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"CLOSE", @"") otherButtonTitles:nil, nil];
    [alert show];
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
