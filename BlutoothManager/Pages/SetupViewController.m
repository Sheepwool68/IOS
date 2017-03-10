//
//  SetupViewController.m
//  BluetoothManager
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import "SetupViewController.h"
#import "FindViewController.h"
#import "BashboardCell.h"
#import "CommonAPI.h"


@interface SetupViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UITextFieldDelegate>
{
    NSMutableArray * titleArray;
    NSMutableArray * speedArray;
    
    NSString * m_selectSpeed;
    int        m_selectSteps;
    
    UITextField * stepField;
}
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITableView *tbl_main;
@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.backgroundView.layer setCornerRadius:15];
    titleArray = [[NSMutableArray alloc] initWithObjects:@"Name:",@"Default Speed:",@"Goal Steps:",@"Goal Time:",@"Device", nil];
    speedArray = [[NSMutableArray alloc] initWithObjects:@"Walk",@"Jog",@"Run",@"Sprint", nil];
    
    
    NSString * device_speed = [CommonAPI getLocalValeuForKey:DEVICECONF_SPEED];
    if(device_speed)
        m_selectSpeed = device_speed;
    else{
        m_selectSpeed = @"Jog";
        [CommonAPI saveStringToLocal:m_selectSpeed keyString:DEVICECONF_SPEED];
    }
    NSString * device_steps = [CommonAPI getLocalValeuForKey:DEVICECONF_STEPS];
    if(device_steps)
        m_selectSteps = [device_steps intValue];
    else{
        [CommonAPI saveStringToLocal:[NSString stringWithFormat:@"10000"] keyString:DEVICECONF_STEPS];
        m_selectSteps = 10000;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tbl_main reloadData];
}

- (void) reloadTables
{
    [self.tbl_main reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"showFindDevice"]){
        FindViewController * controller = (FindViewController*)[segue destinationViewController];
        controller.parent_viewController = self;
    }
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"SetupCell"];
    BashboardCell * cell = (BashboardCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell){
        [cell.lbl_title setText:[titleArray objectAtIndex:indexPath.row]];
        [cell.edt_steps setHidden:YES];
        if(indexPath.row == 0){
            if([CommonAPI getLocalValeuForKey:USERKEY_USERNAME].length > 0){
                [cell.lbl_value setText:[CommonAPI getLocalValeuForKey:USERKEY_USERNAME]];
            }else{
                [cell.lbl_value setText:@"GJ User"];
            }
        }
        else if(indexPath.row == 1){
            [cell.lbl_value setText:m_selectSpeed];
        }
        else if(indexPath.row == 2){
            [cell.edt_steps setHidden:NO];
            [cell.edt_steps setText:[NSString stringWithFormat:@"%d",m_selectSteps]];
            cell.edt_steps.delegate = self;
            
            UIToolbar * toolbar = [[UIToolbar alloc] init];
            [toolbar setBarStyle:UIBarStyleBlackTranslucent];
            [toolbar sizeToFit];
            
            UIBarButtonItem * flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onHideKeyboardForAvgTicket)];
            
            NSArray * itemsArray = [NSArray arrayWithObjects:flexButton,doneButton, nil];
            [toolbar setItems:itemsArray];
            [cell.edt_steps setInputAccessoryView:toolbar];
            stepField = cell.edt_steps;
        }
        else if(indexPath.row == 3){
            int second = 0;
            if([m_selectSpeed isEqualToString:@"Walk"]){
                 second = (m_selectSteps/120.f) * 60;
            }else if([m_selectSpeed isEqualToString:@"Jog"]){
                second = (m_selectSteps/150.f) * 60;
            }else if([m_selectSpeed isEqualToString:@"Run"]){
                second = (m_selectSteps/180.f) * 60;
            }else if([m_selectSpeed isEqualToString:@"Sprint"]){
                second = (m_selectSteps/200.f) * 60;
            }
            NSString * timeStr = [CommonAPI convertSecondToTime:second];
            [cell.lbl_value setText:timeStr];
        }
        else if(indexPath.row == 4){
            if([CommonAPI getLocalValeuForKey:USERKEY_DEVICE_NAME].length > 0){
                [cell.lbl_value setText:[CommonAPI getLocalValeuForKey:USERKEY_DEVICE_NAME]];
            }else{
                [cell.lbl_value setText:@"Select Device"];
            }
        }
        cell.btn_select.tag = indexPath.row;
        [cell.btn_select addTarget:self action:@selector(onClickCell:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;

}
- (void) onClickCell:(UIButton*)button
{
    int index = (int)button.tag;
    if(index == 1){// speed
        NSMutableArray * selectableSpeeds = [NSMutableArray new];
        [selectableSpeeds addObject:m_selectSpeed];
        for(NSString * str in speedArray){
            if(![str isEqualToString:m_selectSpeed]){
                [selectableSpeeds addObject:str];
            }
        }
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:[selectableSpeeds objectAtIndex:0] otherButtonTitles:[selectableSpeeds objectAtIndex:1],[selectableSpeeds objectAtIndex:2],[selectableSpeeds objectAtIndex:3], nil];
        [actionSheet showInView:self.view];
        speedArray = selectableSpeeds;
    }else if(index == 4){// device
        [self performSegueWithIdentifier:@"showFindDevice" sender:self];
    }
}
- (void)onHideKeyboardForAvgTicket
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect selfViewRect =  self.view.frame;
        selfViewRect.origin.y = 0;
        [self.view setFrame:selfViewRect];
    } completion:^(BOOL finished){
        [stepField resignFirstResponder];
        m_selectSteps = stepField.text.intValue;
        [CommonAPI saveStringToLocal:stepField.text keyString:DEVICECONF_STEPS];
        [self.tbl_main reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
    }];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == stepField){
        [UIView animateWithDuration:0.2 animations:^{
            CGRect selfViewRect =  self.view.frame;
            selfViewRect.origin.y = - 100;
            [self.view setFrame:selfViewRect];
        } completion:^(BOOL finished){
            
        }];
        return YES;
    }
    return YES;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 4)
        return;
    m_selectSpeed = [speedArray objectAtIndex:buttonIndex];
    [self.tbl_main reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:3 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
    [CommonAPI saveStringToLocal:m_selectSpeed keyString:DEVICECONF_SPEED];
}
@end
