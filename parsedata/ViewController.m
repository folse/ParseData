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
    int keyArrayId;
    int photoArrayId;
    NSArray *keyArray;
    NSArray *clearArray;
    NSArray *photoArray;
    NSArray *jsonArray;
    UIWebView *photoWebView;
    PFObject *currentObject;
    NSString *loadingPhotoUrl;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    keyArray = [NSArray arrayWithObjects:@"AIzaSyC8IfTEGsA4s8I6SB4SZBgT0b2WJR7mkcY",
                @"AIzaSyC5xWawMGqWOi3VJq0xoLsdGKU84Nf8eLk",
                @"AIzaSyC6GGSFl-RKY5XgFeGEFNdkLIzC5g5JSpw",
                @"AIzaSyBCgh8Bmg43FiPBBAjrMj7bJTDpK5wlLZ4",
                @"AIzaSyAqLUgVvQV1qmN1APpndQJqoF8q1MR-Ls0",
                @"AIzaSyD7LqPOyd_uwydZgeeWNHIThV3794q2bEY",
                @"AIzaSyBvs25RjogtWqPDD13ja_iOvC26ODLvQeM",
                @"AIzaSyAcsvwj8u-Lvvm7gCMKzkzP5p33TVHHEeU",
                @"AIzaSyCy7uC4Uy974sAyIujoJDKJaIIoVZDtXx4",
                @"AIzaSyAsFPk3j65gBZZd1QSm9HaJAxscWg_gKY0",
                @"AIzaSyAeHrJ1pTedhijma8bP1GSu8dZVvPGn77s",
                @"AIzaSyAKXbdKWEO6xrhe_lk4dk3RTxCtQc8hfVw",
                @"AIzaSyA_oc9uDRGeC3dkZWD4awlK5uhygss5seg",
                @"AIzaSyDJxa5YEb1cDhNvt8RGaUjPsmTLVwWNbdc",
                @"AIzaSyBdwlLFKYF7QbAfMGjtcUS3Lp_-1grDFU0",nil];
    
    [self readJSONData];
    
    [self clearData];
    
    //[self clearPhoto];
    
}

-(void)clearData
{
    PFQuery *query = [PFQuery queryWithClassName:@"StockholmPlace"];
    query.skip = pageId * 100;
    query.limit = 100;
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            clearArray = objects;
            
            //[self findDuplicateData:clearArray[clearId]];
            
            //[self addDetailToParse:clearArray[clearId]];
            
            [self addReferenceToPlace:clearArray[clearId]];
            
        } else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)clearPhoto
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"url" hasPrefix:@"https"];
    query.skip = pageId * 100;
    query.limit = 100;
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            clearArray = objects;
            
            //[self addPhotoToParse:clearArray[clearId]];
            
            //[self addPhotoToQiniu:clearArray[clearId]];
            
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

-(void)addDetailToParse:(PFObject *)eachObject
{
    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
    [parameterDict setObject:@"false" forKey:@"sensor"];
    [parameterDict setObject:eachObject[@"g_reference"] forKey:@"reference"];
    [parameterDict setObject:keyArray[keyArrayId] forKey:@"key"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"https://maps.googleapis.com/maps/api/place/details/json" parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"%@:%@",operation.response.URL.relativePath,JSON);
        
        if ([[JSON valueForKey:@"status"] isEqualToString:@"OK"]) {
            NSDictionary *result = (NSDictionary *)[JSON valueForKey:@"result"];
            
            NSString *phone = [result valueForKey:@"formatted_phone_number"];
            
            [eachObject setObject:phone forKey:@"phone"];
            [eachObject save];
            
            clearId += 1;
            
            [self addDetailToParse:clearArray[clearId]];
            
            
        }else if ([[JSON valueForKey:@"status"] isEqualToString:@"OVER_QUERY_LIMIT"]){
            
            keyArrayId += 1;
            [self addDetailToParse:eachObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        s(operation.responseString)
    }];
    
}

-(void)addReferenceToPlace:(PFObject *)eachObject
{
    for (NSDictionary *item in jsonArray) {
        
        if ([eachObject[@"place_id"] isEqualToString:item[@"place_id"]]) {
            [eachObject setObject:item[@"reference"] forKey:@"reference"];
            [eachObject save];
            break;
        }
    }
    
    clearId += 1;
    
    if (clearId == clearArray.count) {
        
        pageId += 1;
        clearId = 0;
        [self clearData];
        
    }else{
        
        i(clearId)
        
        [self addReferenceToPlace:clearArray[clearId]];
    }
}

-(void)readJSONData
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"merchant_Stockholm" ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
