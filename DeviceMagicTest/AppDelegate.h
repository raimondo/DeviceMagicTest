//
//  AppDelegate.h
//  DeviceMagicTest
//
//  Created by Ray de Rose on 2017/05/17.
//  Copyright © 2017 Ray de Rose. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(void)downloadDataFromURL:(NSURL *)url withCompletionHandler:(void (^)(NSData *))completionHandler;


@end

