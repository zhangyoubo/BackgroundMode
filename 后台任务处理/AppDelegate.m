//
//  AppDelegate.m
//  后台任务处理
//
//  Created by 张友波 on 17/2/6.
//  Copyright © 2017年 张友波. All rights reserved.
//


/*
 第二部分：保持程序在后台长时间运行
 iOS为了让设备尽量省电，减少不必要的开销，保持系统流畅，因而对后台机制采用墓碑式的“假后台”。除了系统官方极少数程序可以真后台，一般开发者开发出来的应用程序后台受到以下限制：
 
 1.用户按Home之后，App转入后台进行运行，此时拥有180s后台时间（iOS7）或者600s（iOS6）运行时间可以处理后台操作
 
 2.当180S或者600S时间过去之后，可以告知系统未完成任务，需要申请继续完成，系统批准申请之后，可以继续运行，但总时间不会超过10分钟。
 
 3.当10分钟时间到之后，无论怎么向系统申请继续后台，系统会强制挂起App，挂起所有后台操作、线程，直到用户再次点击App之后才会继续运行。
 
 当然iOS为了特殊应用也保留了一些可以实现“真后台”的方法，摘取比较常用的：
 
 1.VOIP
 
 2.定位服务
 
 3.后台下载
 
 4.在后台一直播放无声音乐（容易受到电话或者其他程序影响，所以暂未考虑）
 
 5….更多
 */





#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) NSTimer *myTimer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if ([self isMultitaskingSupported] == NO){
        return;
    }
    
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                    target:self
                                                  selector:@selector(timerMethod:) userInfo:nil
                                                   repeats:YES];
    /*
     在程序中你可以多次调用beginBackgroundTaskWithExpirationHandler:方法。要记住的重点是，当iOS为你的程序返回一个token或者任务标识（task identifier）时，你都必须调用endBackgroundTask:方法，在运行的任务结束时，用来标志任务结束。如果你不这么做的话，iOS会终止你的程序。
     */
    
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^(void) {
        [self endBackgroundTask];
        
    }];
    
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


- (void) endBackgroundTask{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    __weak __typeof(self)weakSelf = self;
    
    dispatch_async(mainQueue, ^(void) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (strongSelf != nil){
            
            [strongSelf.myTimer invalidate];
            
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            
            strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
        
    }); }

- (BOOL) isMultitaskingSupported{
    BOOL result = NO;
    if ([[UIDevice currentDevice]
         respondsToSelector:@selector(isMultitaskingSupported)]){ result = [[UIDevice currentDevice] isMultitaskingSupported];
    }
    return result;
}

- (void) timerMethod:(NSTimer *)paramSender{
    /* 
     当你的程序在前台时，UIApplication的backgroundTimeRemaining属性等于DBL_MAX常量，这是double类型可表示的最大值（和这个值相当的integer通常等于-1）。在iOS被要求在程序被完全挂起之前给于更多的执行时间，这个属性指明了在完成任务前程序拥有多少秒。
     
     */
   
    NSTimeInterval backgroundTimeRemaining =[[UIApplication sharedApplication] backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX){
        NSLog(@"Background Time Remaining = Undetermined");
    } else {
        NSLog(@"Background Time Remaining = %.02f Seconds", backgroundTimeRemaining);
        
        
    }
}

@end















