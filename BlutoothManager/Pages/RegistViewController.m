//
//  RegistViewController.m
//  BluetoothManager
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import "RegistViewController.h"
#import "CommonAPI.h"
#import <MessageUI/MessageUI.h>

@interface RegistViewController ()<UITextFieldDelegate,MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *edt_name;
@property (weak, nonatomic) IBOutlet UITextField *edt_address1;
@property (weak, nonatomic) IBOutlet UITextField *edt_address2;
@property (weak, nonatomic) IBOutlet UITextField *edt_city;
@property (weak, nonatomic) IBOutlet UITextField *edt_zipcode;
@property (weak, nonatomic) IBOutlet UITextField *edt_emailaddress;
    @property (weak, nonatomic) IBOutlet UITextField *edt_organization;

@end

@implementation RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.edt_name setText:[CommonAPI getLocalValeuForKey:USERKEY_USERNAME]];
    [self.edt_organization setText:[CommonAPI getLocalValeuForKey:USERKEY_ORGNZIATION]];
    [self.edt_address1 setText:[CommonAPI getLocalValeuForKey:USERKEY_ADDRESS1]];
    [self.edt_address2 setText:[CommonAPI getLocalValeuForKey:USERKEY_ADDRESS2]];
    [self.edt_city setText:[CommonAPI getLocalValeuForKey:USERKEY_CITY]];
    [self.edt_zipcode setText:[CommonAPI getLocalValeuForKey:USERKEY_ZIPCODE]];
    [self.edt_emailaddress setText:[CommonAPI getLocalValeuForKey:USERKEY_EMAIL]];
    
    UIToolbar * toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    UIBarButtonItem * flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onHideKeyboardForAvgTicket)];
    
    NSArray * itemsArray = [NSArray arrayWithObjects:flexButton,doneButton, nil];
    [toolbar setItems:itemsArray];
    [self.edt_zipcode setInputAccessoryView:toolbar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onSubmitRegist:(id)sender {
    if(self.edt_name.text.length > 0){
        [CommonAPI saveStringToLocal:self.edt_name.text keyString:USERKEY_USERNAME];
    }if(self.edt_organization.text.length > 0){
        [CommonAPI saveStringToLocal:self.edt_organization.text keyString:USERKEY_ORGNZIATION];
    }if(self.edt_address1.text.length > 0){
        [CommonAPI saveStringToLocal:self.edt_address1.text keyString:USERKEY_ADDRESS1];
    }if(self.edt_address2.text.length > 0){
        [CommonAPI saveStringToLocal:self.edt_address2.text keyString:USERKEY_ADDRESS2];
    }if(self.edt_city.text.length > 0){
        [CommonAPI saveStringToLocal:self.edt_city.text keyString:USERKEY_CITY];
    }if(self.edt_zipcode.text.length > 0){
        [CommonAPI saveStringToLocal:self.edt_zipcode.text keyString:USERKEY_ZIPCODE];
    }
    if(self.edt_emailaddress.text.length > 0 && [MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        
        [picker setEditing:YES];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:@"GJ Registration"];
        
        NSString * stringTo = @"";
        stringTo = [stringTo stringByAppendingFormat:@"\n%@\n",self.edt_name.text];
        stringTo = [stringTo stringByAppendingFormat:@"\n%@\n",self.edt_organization.text];
        stringTo = [stringTo stringByAppendingFormat:@"\n%@\n",self.edt_address2.text];
        stringTo = [stringTo stringByAppendingFormat:@"\n%@\n",self.edt_address1.text];
        stringTo = [stringTo stringByAppendingFormat:@"\n%@\n",self.edt_city.text];
        stringTo = [stringTo stringByAppendingFormat:@"\n%@\n",self.edt_zipcode.text];
        
        // Set up recipients
        NSArray *toRecipients = [NSArray arrayWithObject:@" jim@sacknerwellness.com"];
        
        [picker setToRecipients:toRecipients];
        
        
        NSString *emailBody = stringTo;
        
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}
- (IBAction)onSubmitJoinEmail:(id)sender {
    [CommonAPI saveStringToLocal:self.edt_emailaddress.text keyString:USERKEY_EMAIL];
    if(self.edt_emailaddress.text.length > 0 && [MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
       
        [picker setEditing:YES];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:@"Please add me to your email list"];
        
                // Set up recipients
        NSArray *toRecipients = [NSArray arrayWithObject:@" jim@sacknerwellness.com"];
        
        [picker setToRecipients:toRecipients];
        
        
        NSString *emailBody = [NSString stringWithFormat:@"\n%@\n\nPlease add my email address above to your list for occasional email announcements about the Gentle Jogger and Sackner Wellness, Inc. \nI understand that you will not share my information with any other party.",self.edt_emailaddress.text];
        
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}
    
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
        [self dismissViewControllerAnimated:YES completion:NULL];
}

    
- (void)onHideKeyboardForAvgTicket
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect selfViewRect =  self.view.frame;
        selfViewRect.origin.y = 0;
        [self.view setFrame:selfViewRect];
    } completion:^(BOOL finished){
        [self.edt_zipcode resignFirstResponder];
    }];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect currentRect = [self.view convertRect:textField.frame fromView:textField.superview];
    int height = self.view.frame.size.height - currentRect.origin.y - currentRect.size.height;
    if(height < 300){
        height = 300 - height;
        [UIView animateWithDuration:0.2 animations:^(void){
            CGRect selfRect = self.view.frame;
            selfRect.origin.y = -height;
            [self.view setFrame:selfRect];
        } completion:^(BOOL finished){
        }];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^(void){
        CGRect selfRect = self.view.frame;
        selfRect.origin.y = 0;
        [self.view setFrame:selfRect];
    } completion:^(BOOL finished){
    }];
    return YES;
}
@end
