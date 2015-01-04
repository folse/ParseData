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
    PFObject *currentObject;
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
        
        NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
        [parameterDict setObject:eachObject[@"url"] forKey:@"file_url"];
        [parameterDict setObject:eachObject.objectId forKey:@"file_name"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:@"http://localhost/api/upload_to_qiniu" parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id JSON) {
            
            NSLog(@"%@:%@",operation.response.URL.relativePath,JSON);
            
            if ([[JSON valueForKey:@"respcd"] isEqualToString:@"0000"]) {
                
                    currentObject = eachObject;
                
                    NSString *imageUrl = [NSString stringWithFormat:@"http://ts-image1.qiniudn.com/%@",[JSON valueForKey:@"file_name"]];
                
                    currentObject[@"url"] = imageUrl;
                
                    [currentObject save];
            }
            
            clearId += 1;
            
            if (clearId == clearArray.count) {
                
                pageId += 1;
                clearId = 0;
                [self clearData];
                
            }else{
                
                [self addPhotoToQiniu:clearArray[clearId]];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            s(operation.responseString)
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
