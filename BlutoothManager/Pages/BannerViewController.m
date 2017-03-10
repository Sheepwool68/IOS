//
//  BannerViewController.m
//  BluetoothManager
//
//  Created by user1 on 12/3/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import "BannerViewController.h"

@interface BannerViewController ()
    {
        int showedImageIndex;
    }
    @property (weak, nonatomic) IBOutlet UIImageView *imageViewController;

@end

@implementation BannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    showedImageIndex = 0;
    [self.imageViewController setImage:[UIImage imageNamed:@"0"]];
    [self performSelector:@selector(showNextImage) withObject:nil afterDelay:0.25];
}
-(void)showNextImage
    {
        showedImageIndex ++;
        if(showedImageIndex <= 20){
            [self.imageViewController setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",showedImageIndex]]];
            [self performSelector:@selector(showNextImage) withObject:nil afterDelay:0.25];
        }else{
            [self performSegueWithIdentifier:@"showMainView" sender:self];
        }
    }
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation///showMainView

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
