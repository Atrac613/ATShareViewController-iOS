//
//  ShareViewController.m
//  ShareView
//
//  Created by Osamu Noguchi on 4/30/12.
//  Copyright (c) 2012 atrac613.io. All rights reserved.
//

#import "ATShareViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ATShareViewController ()

@end

@implementation ATShareViewController

@synthesize tableView;
@synthesize navigationBar;
@synthesize navigationItem;
@synthesize toolBar;
@synthesize shareMessage;
@synthesize shareImage;
@synthesize twitterAccountNumber;
@synthesize twitterAccountsArray;
@synthesize pickerView;
@synthesize pickerToolbar;
@synthesize pickerViewPopup;
@synthesize pendingView;
@synthesize doTweet;
@synthesize doFacebook;
@synthesize delegate;


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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
	
    [self.navigationItem setTitle:NSLocalizedString(@"SHARE", @"")];
    
    SharedAppDelegate.facebook = [[Facebook alloc] initWithAppId:FACEBOOK_KEY_APP_ID andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:FACEBOOK_KEY_ACCESS_TOKEN] 
        && [defaults objectForKey:FACEBOOK_KEY_EXPIRATION_DATE]) {
        SharedAppDelegate.facebook.accessToken = [defaults objectForKey:FACEBOOK_KEY_ACCESS_TOKEN];
        SharedAppDelegate.facebook.expirationDate = [defaults objectForKey:FACEBOOK_KEY_EXPIRATION_DATE];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Button Action

- (void)cancelButtonPressed {
    [delegate shareViewController:self didFinishWithResult:ATShareViewControllerResultCancelled];
}

- (void)doneButtonPressed {
    [self showPendingView];
    
    UITextView *textView = (UITextView*)[self.view viewWithTag:1001];
    shareMessage = textView.text;
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operationSendTwitter) object:nil];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [SharedAppDelegate.operationQueue addOperation:operation];
}

- (void)closeButtonPressed {
    UITextView *textView = (UITextView*)[self.view viewWithTag:1001];
    [textView resignFirstResponder];
    
    [toolBar removeFromSuperview];
}

#pragma mark - Operation

- (void)operationSendTwitter {
    NSLog(@"operationSendTwitter");
    
    if (doTweet && [TWTweetComposeViewController canSendTweet]) {
        UITextView *textView = (UITextView*)[self.view viewWithTag:1001];
        [self sendTwitter:textView.text accountNumber:twitterAccountNumber];
    } else {
        [self performSelectorOnMainThread:@selector(operationSendFacebook) withObject:nil waitUntilDone:YES];
    }
}

- (void)operationSendFacebook {
    NSLog(@"operationSendFacebook");
    
    if (doFacebook) {
        [self sendFacebook:shareMessage url:@""];
    } else {
        NSLog(@"Completed.");
        
        [delegate shareViewController:self didFinishWithResult:ATShareViewControllerResultSent];
    }
}

#pragma mark - Keyboard Notification

- (void)keyboardChanged:(NSNotification*)notification {
    // Remove toolbar
    [toolBar removeFromSuperview];
    
    // Get KeyBoard CGRect.
    NSDictionary *info = [notification userInfo];
    NSValue *keyValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [keyValue CGRectValue].size;
    
    NSInteger toolBarY = self.view.frame.size.height - keyboardSize.height - 40;
    
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 40)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeButtonPressed)];
    [toolBar setItems:[[NSArray alloc] initWithObjects:flexibleSpace, closeButton,nil]];
    [toolBar setAlpha:0.9f];
    
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [toolBar setFrame:CGRectMake(0, toolBarY, 320, 40)];
    
    [UIView commitAnimations];
}

#pragma mark - TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return 2;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 70.f;
        }
    }
    
    return 40.f;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"MESSAGE", @"");
    } else {
        return NSLocalizedString(@"SHARING", @"");
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return  @"";
}

- (UITableViewCell*)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"TableViewCell";
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            if (indexPath.row == 0) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, 300, 61)];
                [textView setTag:1001];
                [textView setBackgroundColor:[UIColor clearColor]];
                
                [textView setText:shareMessage];
                
                [cell addSubview:textView];
            }
        }
    } else if (indexPath.section == 1) {
        cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (indexPath.row == 0) {
                
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.image = [UIImage imageNamed:@"twitter_icon.jpg"];
                imageView.layer.cornerRadius = 5.f;
                imageView.clipsToBounds = YES;
                imageView.frame = CGRectMake(15, 6, 30, 30);
                [cell addSubview:imageView];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 100, 30)];
                label.text = NSLocalizedString(@"TWITTER", @"");
                label.font = [UIFont boldSystemFontOfSize:18];
                label.backgroundColor = [UIColor clearColor];
                
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                switchView.tag = 11001;
                cell.accessoryView = switchView;
                
                [switchView setOn:NO animated:NO];
                [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                
                [cell.contentView addSubview:label];
            } else {
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.image = [UIImage imageNamed:@"facebook_icon.jpg"];
                imageView.layer.cornerRadius = 5.f;
                imageView.clipsToBounds = YES;
                imageView.frame = CGRectMake(15, 5, 30, 30);
                [cell addSubview:imageView];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 100, 30)];
                label.text = NSLocalizedString(@"FACEBOOK", @"");
                label.font = [UIFont boldSystemFontOfSize:18];
                label.backgroundColor = [UIColor clearColor];
                
                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
                switchView.tag = 11002;
                cell.accessoryView = switchView;
                
                [switchView setOn:NO animated:NO];
                [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                
                [cell.contentView addSubview:label];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tv deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Other delegate

- (void)switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSLog(@"Switch is %@", switchControl.on ? @"ON" : @"OFF");
    
    if (switchControl.tag == 11001) {
        doTweet = switchControl.on;
        
        if (doTweet) {
            [self twitterAccountCheck];
        }
    } else {
        doFacebook = switchControl.on;
        
        if (doFacebook) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (![appDelegate.facebook isSessionValid]) {
                NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream", @"offline_access",nil];
                [appDelegate.facebook authorize:permissions];
            }
        }
    }
    
    if (doFacebook || doTweet) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    
    return YES;
}

#pragma mark - Send Action

- (void)twitterAccountCheck {
    // Create an account store object.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            // For the sake of brevity, we'll assume there is only one Twitter account present.
            // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
            if ([accountsArray count] == 1) {
                twitterAccountNumber = 0;
            } else if ([accountsArray count] > 1) {
                [self selectTwitterAccount:accountsArray];
            }
        }
    }];
}

- (void)sendTwitter:(NSString *)message accountNumber:(NSInteger)accountNumber {
    // Create an account store object.
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	
	// Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	// Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
			// Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			
            ACAccount *twitterAccount = [accountsArray objectAtIndex:accountNumber];
            
            // Create a request, which in this example, posts a tweet to the user's timeline.
            // This example uses version 1 of the Twitter API.
            // This may need to be changed to whichever version is currently appropriate.
            
            NSString *url;
            if (shareImage) {
                url = @"https://upload.twitter.com/1/statuses/update_with_media.json";
            } else {
                url = @"https://api.twitter.com/1/statuses/update.json";
            }
            
            TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:url] parameters:nil requestMethod:TWRequestMethodPOST];
            
            // Set the account used to post the tweet.
            [postRequest setAccount:twitterAccount];
            
            if (shareImage) {
                NSData *data = UIImagePNGRepresentation(shareImage);
                
                [postRequest addMultiPartData:data 
                                     withName:@"media[]" 
                                         type:@"multipart/form-data"];
            }
            
            [postRequest addMultiPartData:[message dataUsingEncoding:NSUTF8StringEncoding] 
                                 withName:@"status" 
                                     type:@"multipart/form-data"];
            
            // Perform the request created above and create a handler block to handle the response.
            [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                NSLog(@"%@", output);
                
                [self performSelectorOnMainThread:@selector(operationSendFacebook) withObject:nil waitUntilDone:YES];
            }];
        }
	}];
}

- (void)selectTwitterAccount:(NSArray*)accountsArray {
    twitterAccountsArray = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < [accountsArray count]; i++) {
        ACAccount *twitterAccount = [accountsArray objectAtIndex:i];
        [twitterAccountsArray addObject:[NSString stringWithFormat:@"@%@", twitterAccount.username]];
    }
    
    [self performSelectorOnMainThread:@selector(showTwitterAccountPickerView) withObject:nil waitUntilDone:NO];
}

- (void)showTwitterAccountPickerView {
    pickerViewPopup = [[UIActionSheet alloc] initWithTitle:@"Select Account"
                                                  delegate:self
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,44,0,0)];
    
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    
    pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    [pickerToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closePicker:)];
    [barItems addObject:doneBtn];
    
    [pickerToolbar setItems:barItems animated:YES];
    
    [pickerViewPopup addSubview:pickerToolbar];
    [pickerViewPopup addSubview:pickerView];
    [pickerViewPopup showInView:self.view];
    [pickerViewPopup setBounds:CGRectMake(0,0,320, 476)];
}

- (BOOL)closePicker:(id)sender {
    twitterAccountNumber = [pickerView selectedRowInComponent:0];
    NSLog(@"TwitterAccount: %@", [twitterAccountsArray objectAtIndex:twitterAccountNumber]);
    
    [pickerViewPopup dismissWithClickedButtonIndex:0 animated:YES];
    
    return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [twitterAccountsArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [twitterAccountsArray objectAtIndex:row];
}

- (void)sendFacebook:(NSString *)message url:(NSString*)url {
    if ([SharedAppDelegate.facebook isSessionValid]) {
        if ([url length] > 0) {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: url, @"link", message, @"message", nil];
            
            [SharedAppDelegate.facebook requestWithGraphPath:@"me/links" andParams:params andHttpMethod:@"POST" andDelegate:self];
        } else {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: message, @"message", nil];
            
            [SharedAppDelegate.facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
        }
    } else {
        NSLog(@"Facebook session is invalid.");
        
        [delegate shareViewController:self didFinishWithResult:ATShareViewControllerResultFailed];
    }
}

#pragma mark - Facebook delegate

- (void)fbDidLogin {
    NSLog(@"fbDidLogin");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[SharedAppDelegate.facebook accessToken] forKey:FACEBOOK_KEY_ACCESS_TOKEN];
    [defaults setObject:[SharedAppDelegate.facebook expirationDate] forKey:FACEBOOK_KEY_EXPIRATION_DATE];
    [defaults synchronize];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"fbDidNotLogin");
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"request didReceiveResponse");
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"request didLoad");
    
    [delegate shareViewController:self didFinishWithResult:ATShareViewControllerResultSent];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"request didFailWithError");
    
    [delegate shareViewController:self didFinishWithResult:ATShareViewControllerResultFailed];
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data {
    NSLog(@"request didLoadRawResponse");
}

- (void)requestLoading:(FBRequest *)request {
    NSLog(@"requestLoading");
}

- (void)fbSessionInvalidated {
    NSLog(@"fbSessionInvalidated");
}

#pragma mark - FBSession delegate

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt {
    NSLog(@"fbDidExtendToken");
}

- (void)fbDidLogout {
    NSLog(@"fbDidLogout");
}

#pragma mark - Pending View

- (void)showPendingView {
    if (pendingView == nil && ![self.view.subviews containsObject:pendingView]) {
        pendingView = [[PendingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40)];
        pendingView.titleLabel.text = NSLocalizedString(@"PLEASE_WAIT", @"Please wait");
        pendingView.userInteractionEnabled = YES;
        [self.view addSubview:pendingView];
    }
    
    [pendingView showPendingView];
}

- (void)hidePendingView {
    if ([self.view.subviews containsObject:pendingView]) {
        [pendingView hidePendingView];
        
        pendingView = nil;
    }
}

@end