//
//  ViewController.m
//  parsedata
//
//  Created by folse on 12/22/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    int pageId;
    int clearId;
    NSMutableArray *clearArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    clearArray = [NSMutableArray new];
    
    [self clearData];
}

-(void)clearData
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"url" hasPrefix:@"https"];
    query.skip = pageId * 100;
    query.limit = 100;
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            clearArray = [NSMutableArray arrayWithArray:objects];
            
            //[self findDuplicateData:clearArray[clearId]];
            
            //[self addPhotoToParse:clearArray[clearId]];

            [self addPhotoToQiniu:clearArray[clearId]];

        } else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)addPhotoToQiniu:(PFObject *)eachObject
{
    if (eachObject && eachObject[@"url"]){
        
        NSLog(@"%@",eachObject[@"url"]);
        
        NSString *token = @"";
        QNUploadManager *upManager = [[QNUploadManager alloc] init];
        NSData *data = [@"Hello, World!" dataUsingEncoding : NSUTF8StringEncoding];
        [upManager putData:data key:@"hello" token:token
                  complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                      NSLog(@"%@", info);
                      NSLog(@"%@", resp);
                  } option:nil];
        
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
