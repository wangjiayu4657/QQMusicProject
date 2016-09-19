//
//  AppDelegate.m
//  QQMusic
//
//  Created by fangjs on 16/9/7.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "AppDelegate.h"

#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //获取音频会话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    //设置后台类型
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //激活后台模式
    [session setActive:YES error:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:boolKey];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
   
    if (![[NSUserDefaults standardUserDefaults] boolForKey:boolKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:boolKey];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:iconViewAnimationNotification object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
