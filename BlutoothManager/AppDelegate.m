//
//  AppDelegate.m
//  BlutoothManager
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import "AppDelegate.h"
#import "CommonAPI.h"
#import <DropboxSDK/DropboxSDK.h>
#import "DeviceMemory.h"

@interface AppDelegate ()<DBSessionDelegate, DBNetworkRequestDelegate,DBRestClientDelegate>
{
    UIActivityIndicatorView *_loader;
    UIImageView *_loaderBackgroundView;
    
    UIView * m_showCustomView;
    
    NSString *relinkUserId;
}
@property (nonatomic, retain)DBRestClient *restClient;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [CommonAPI resetTodayCountATime];
    
    // Set these variables before launching the app
    NSString* appKey = @"aoz3k82pelyuhbl";
    NSString* appSecret = @"rjjd5l7frff42qx";
    NSString *root = kDBRootDropbox; // Should be set to either kDBRootAppFolder or kDBRootDropbox
    // You can determine if you have App folder access or Full Dropbox along with your consumer key/secret
    // from https://dropbox.com/developers/apps
    
    // Look below where the DBSession is created to understand how to use DBSession in your app
    
    NSString* errorMsg = nil;
    if ([appKey rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
        errorMsg = @"Make sure you set the app key correctly in DBRouletteAppDelegate.m";
    } else if ([appSecret rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
        errorMsg = @"Make sure you set the app secret correctly in DBRouletteAppDelegate.m";
    } else if ([root length] == 0) {
        errorMsg = @"Set your root to use either App Folder of full Dropbox";
    } else {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        NSData *plistData = [NSData dataWithContentsOfFile:plistPath];
        NSDictionary *loadedPlist =
        [NSPropertyListSerialization
         propertyListFromData:plistData mutabilityOption:0 format:NULL errorDescription:NULL];
        NSString *scheme = [[[[loadedPlist objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
        if ([scheme isEqual:@"db-APP_KEY"]) {
            errorMsg = @"Set your URL scheme correctly in DBRoulette-Info.plist";
        }
    }
    
    DBSession* session =
    [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
    session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
    [DBSession setSharedSession:session];
    
    [DBRequest setNetworkRequestDelegate:self];
    
    if (errorMsg != nil) {
        [[[UIAlertView alloc] initWithTitle:@"Error Configuring Session" message:errorMsg
           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    NSURL *launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    NSInteger majorVersion =
    [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
    if (launchURL && majorVersion < 4) {
        // Pre-iOS 4.0 won't call application:handleOpenURL; this code is only needed if you support
        // iOS versions 3.2 or below
        [self application:application handleOpenURL:launchURL];
        return NO;
    }

    
    return YES;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
            self.restClient.delegate = self;
            [self sharedTxtFile];
        }
        return YES;
    }
    
    return NO;
}
- (void)sharedTxtFile
{
    NSString * fileName = ((DeviceMemory*)[DeviceMemory createInstance]).shared_fileName;
    NSString * localDit = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString * localPath = [localDit stringByAppendingPathComponent:fileName];
    
    NSString * destDir = @"/";
    [self.restClient uploadFile:fileName toPath:destDir withParentRev:nil fromPath:localPath];
}
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    NSLog(@"File uploaded to path:%@",metadata.path);
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError *)error
{
    NSLog(@"File uploaded to path:%@",error);
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)showLoader {
    if (_loader == nil) {
        _loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loaderBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loader_background"]];
        [self.window addSubview:_loaderBackgroundView];
        _loader.frame = CGRectMake(_loaderBackgroundView.center.x - (_loader.frame.size.width / 2),
                                   _loaderBackgroundView.center.y - (_loader.frame.size.height / 2),
                                   _loader.frame.size.width,
                                   _loader.frame.size.height);
        [_loaderBackgroundView addSubview:_loader];
    }
    [self centerLoader];
    [self.window bringSubviewToFront:_loaderBackgroundView];
    _loaderBackgroundView.hidden = NO;
    [_loader startAnimating];
    [self.window setUserInteractionEnabled:NO];
}
- (void)hideLoader {
    [self.window setUserInteractionEnabled:YES];
    [_loader stopAnimating];
    _loaderBackgroundView.hidden = YES;
}
- (void)centerLoader {
    _loaderBackgroundView.frame = CGRectMake(self.window.center.x - (_loaderBackgroundView.frame.size.width / 2),
                                             self.window.center.y - (_loaderBackgroundView.frame.size.height / 2),
                                             _loaderBackgroundView.frame.size.width,
                                             _loaderBackgroundView.frame.size.height);
    
}
- (void)showCustomView:(UIView*)view
{
    m_showCustomView = view;
    m_showCustomView.center = self.window.center;
    [self.window addSubview:m_showCustomView];
}
- (void)hideCustomView
{
    [m_showCustomView removeFromSuperview];
}
#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
    relinkUserId = userId;
    [[[UIAlertView alloc]initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self
       cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil]  show];
}


#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
    if (index != alertView.cancelButtonIndex) {
//        [[DBSession sharedSession] linkUserId:relinkUserId fromController:rootViewController];
    }
}


#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
    outstandingRequests++;
    if (outstandingRequests == 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)networkRequestStopped {
    outstandingRequests--;
    if (outstandingRequests == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

@end
