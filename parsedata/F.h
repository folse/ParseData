//
//  F.h
//  Weidian
//
//  Created by Folse on 5/11/13.
//  Copyright (c) 2013 Folse. All rights reserved.
//

#define USER_ID [USER_DEFAULTS valueForKey:@"userId"]
#define USER_NAME [USER_DEFAULTS valueForKey:@"userName"]
#define USER_MOBILE [USER_DEFAULTS valueForKey:@"userMobile"]
#define USER_LOGIN [USER_DEFAULTS boolForKey:@"userLogined"]
#define PLAYED_GUIDE [USER_DEFAULTS boolForKey:@"playedGuide"]
#define PINK_COLOR [UIColor colorWithRed:253.0/255.0 green:119.0/255.0 blue:142.0/255.0 alpha:1.0]

#define MORE_THAN_FIRST_LOAD [USER_DEFAULTS boolForKey:@"moreThanFirstLoad"]
#define NEED_CREATE_SHOP [USER_DEFAULTS boolForKey:@"needCreateShop"]
#define DEVICE_TOKEN [USER_DEFAULTS valueForKey:@"deviceToken"]
#define PUSH_MESSAGE [USER_DEFAULTS valueForKey:@"pushMessage"]

@interface F : NSObject

+ (NSString *)MD5:(NSString *)text;

+ (NSString *)getMD5FilePathWithUrl:(NSString *)url;

+ (NSString *)getQiNiuToken;

+ (BOOL)validateMobile:(NSString *)mobileNum;

+ (void)storeSession;

+ (BOOL)isStringContainsEmoji:(NSString *)string;

@end