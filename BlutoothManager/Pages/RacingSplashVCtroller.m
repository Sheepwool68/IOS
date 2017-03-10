//
//  RacingSplashVCtroller.m
//  RFIDRacing
//
//  Created by user1 on 2/10/17.
//  Copyright © 2017 Malhotra. All rights reserved.
//

#import "RacingSplashVCtroller.h"



@interface RacingSplashVCtroller ()
@end

@implementation RacingSplashVCtroller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performSelector:@selector(onGotoNext) withObject:nil afterDelay:2.f];
    
//    [self didPressLink];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onGotoNext
{
    [self performSegueWithIdentifier:@"gotoScan" sender:self];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
