//
//  FSUtilSettings.h
//
//  Created by Folse on 5/11/13.
//  Copyright (c) 2013 Folse. All rights reserved.
//
#import <AFNetworking.h>
#import <Parse/Parse.h>

#define s(content) NSLog(@"%@", content);
#define i(content) NSLog(@"%d", content);
#define f(content) NSLog(@"%f", content);

#define USER [NSUserDefaults standardUserDefaults]
#define USER_ID [USER valueForKey:@"userId"]
#define USER_NAME [USER valueForKey:@"userName"]
#define USER_LOGIN [USER boolForKey:@"userLogined"]
#define USER_SKIP_LOGIN [USER boolForKey:@"userSkipLogin"]
#define APP_COLOR [UIColor colorWithRed:18.0/255.0 green:168.0/255.0 blue:255.0/255.0 alpha:1.0]
//#define APP_COLOR [UIColor colorWithRed:54.0/255.0 green:159.0/255.0 blue:220.0/255.0 alpha:1.0]

#define FIRST_LOAD [USER boolForKey:@"isFirstLoad"]
#define PAGE_ID [USER valueForKey:@"pageId"]

#define MAIN_STORYBOARD [UIStoryboard storyboardWithName:@"Main" bundle:nil]
#define ACCOUNT_STORYBOARD [UIStoryboard storyboardWithName:@"Account" bundle:nil]
#define MUTILANGUAGE_STORYBOARD [UIStoryboard storyboardWithName:@"MutiLanguage" bundle:nil]

#define e(content) [MobClick event:content];

#define AppVersionShort [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define AppVersionBuild [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

#define OS_Version [[UIDevice currentDevice] systemVersion]

#define Device_Model [[UIDevice currentDevice] model]

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define VIEW_WIDTH self.view.frame.size.width
#define VIEW_HEIGHT self.view.frame.size.height

#define HUD_Define \
HUD = [[MBProgressHUD alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];\
HUD.center = self.view.center;\
HUD.square = YES;\
HUD.margin = 15;\
HUD.minShowTime = 1;\
HUD.mode = MBProgressHUDModeCustomView;\
HUD.customView = [[YSpinKitView alloc] initWithStyle:YSpinKitViewStyleBounce color:APP_COLOR];\
[[UIApplication sharedApplication].keyWindow addSubview:HUD];

#define HUD_SHOW \
[SVProgressHUD setForegroundColor:[UIColor colorWithRed:18/255.0 green:168/255.0 blue:245/255.0 alpha:1]]; \
[SVProgressHUD setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8]]; \
[SVProgressHUD show];

#define HUD_DISMISS \
[SVProgressHUD dismiss]; \

#define TEST FALSE

#if TEST
#define API_BASE_URL @"http://0.api.com"
#else
#define API_BASE_URL @"http://api.com"
#endif

#define UMENG_APP_KEY @"536ef5ee56240b0a790f4074"

//#define QiNiuAK @"StbRobqxbTkicUShT5AlRXqXs6I7LCEZCk-tmLXz"
//#define QiNiuSK @"RuWkSQA1pXyjI_Rn_W4aRylC6cj0q_sgT3m7Xc39"

#define QiNiuAK @"vdc6zqJGZLdU2z_lXXBJ_NLXK-M18XQ2Y7E5cyjb"
#define QiNiuSK @"iANjdgatLuHhmXVTE5ibQ5OnIfg8AqKbWzYI-HXr"

//#define API_BASE_URL [NSString stringWithFormat:@"http://%@",[USER valueForKey:@"test"]]

@interface FSUtilSettings : NSObject

+ (NSString *)MD5:(NSString *)text;

+ (NSString *)getMD5FilePathWithUrl:(NSString *)url;

+ (UIImage *)createImageWithColor:(UIColor *)color;

@end
