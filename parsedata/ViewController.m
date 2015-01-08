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
            
            //[self addReferenceToPlace:clearArray[clearId]];
            
            //[self copyParseClass:clearArray[clearId]];
            
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
    if (eachObject[@"url"]){
        
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
    [parameterDict setObject:eachObject[@"reference"] forKey:@"reference"];
    [parameterDict setObject:keyArray[keyArrayId] forKey:@"key"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"https://maps.googleapis.com/maps/api/place/details/json" parameters:parameterDict success:^(AFHTTPRequestOperation *operation, id JSON) {
        
        //NSLog(@"%@:%@",operation.response.URL.relativePath,JSON);
        
        if ([[JSON valueForKey:@"status"] isEqualToString:@"OK"]) {
            
            NSDictionary *result = (NSDictionary *)[JSON valueForKey:@"result"];
            
            if ([result objectForKey:@"opening_hours"]) {
                
                NSArray *openHoursArray = [result valueForKey:@"opening_hours"][@"weekday_text"];
                
                NSString *openHourString = @"";
                
                for (NSString *openDayString in openHoursArray) {
                    openHourString = [NSString stringWithFormat:@"%@\n%@",openHourString,openDayString];
                }
                
                [eachObject setObject:openHourString forKey:@"open_hour"];
            }
            
            if ([result objectForKey:@"formatted_phone_number"]) {
                NSString *phone = [result valueForKey:@"formatted_phone_number"];
                [eachObject setObject:phone forKey:@"phone"];
            }
            
            if ([eachObject[@"avatar"] length] > 0) {
                eachObject[@"has_photo"] = @YES;
            }else{
                eachObject[@"has_photo"] = @NO;
            }

            [eachObject save];
           
            clearId += 1;
            
            if (clearId == clearArray.count) {
                
                pageId += 1;
                clearId = 0;
                [self clearData];
                
            }else{
                
                i(clearId+pageId*100)
                
                [self addDetailToParse:clearArray[clearId]];
            }
            
        }else if ([[JSON valueForKey:@"status"] isEqualToString:@"OVER_QUERY_LIMIT"]){
            
            keyArrayId += 1;
            [self addDetailToParse:eachObject];
            
        }else{
            
            clearId += 1;
            
            if (clearId == clearArray.count) {
                
                pageId += 1;
                clearId = 0;
                [self clearData];
                
            }else{
                
                i(clearId+pageId*100)
                
                [self addDetailToParse:clearArray[clearId]];
            }
        }
        
        s([JSON valueForKey:@"status"])
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        s(operation.responseString)
    }];
}

//-(void)addReferenceToPlace:(PFObject *)eachObject
//{
//    for (NSDictionary *item in jsonArray) {
//        
//        if ([eachObject[@"place_id"] isEqualToString:item[@"place_id"]]) {
//            [eachObject setObject:item[@"reference"] forKey:@"reference"];
//            [eachObject save];
//            break;
//        }
//    }
//    
//    clearId += 1;
//    
//    if (clearId == clearArray.count) {
//        
//        pageId += 1;
//        clearId = 0;
//        [self clearData];
//        
//    }else{
//        
//        i(clearId+pageId*100)
//        
//        [self addReferenceToPlace:clearArray[clearId]];
//    }
//}

-(void)addAvatarToParse:(PFObject *)eachObject
{
    PFRelation *relation = [eachObject relationForKey:@"photos"];
    PFQuery *productPhotoQuery = [relation query];
    productPhotoQuery.limit = 1;
    
    NSArray *objects = [productPhotoQuery findObjects];
    
    if (objects.count > 0) {
        
        eachObject[@"avatar"] = objects[0][@"url"];
        
        [eachObject save];
    }
    
    [self goNextPhoto];
}

-(void)addPhotoToParse:(PFObject *)eachObject
{
    photoArray = [NSArray arrayWithArray:eachObject[@"g_photos"]];
    
    if (photoArray.count > 0){
        
        currentObject = eachObject;
        
        PFRelation *relation = [eachObject relationForKey:@"photos"];
        PFQuery *productPhotoQuery = [relation query];
        productPhotoQuery.limit = 1;
        [productPhotoQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            //if the "photos" has no photo relations, it should be the first time to add photo
            if (!error && number == 0) {
                
                [self getPhotoUrl:photoArray[0]];
                
            }else{
                
                [self goNextPhoto];
            }
        }];
        
    }else{
        
        s(@"g_photos is 0")
        [self goNextPhoto];
    }
}

-(void)copyParseClass:(PFObject *)eachObject
{
    PFObject *newObject = [PFObject objectWithClassName:@"Place"];
    
    newObject[@"news"] = eachObject[@"news"];
    newObject[@"name"] = eachObject[@"name"];
    newObject[@"phone"] = eachObject[@"phone"];
    newObject[@"address"] = eachObject[@"address"];
    newObject[@"location"] = eachObject[@"location"];
    newObject[@"reference"] = eachObject[@"reference"];
    newObject[@"description"] = eachObject[@"description"];
    
    newObject[@"delivery"] = eachObject[@"delivery"];
    newObject[@"has_park"] = eachObject[@"has_park"];
    newObject[@"has_wifi"] = eachObject[@"has_wifi"];
    newObject[@"has_photo"] = eachObject[@"has_photo"];
    newObject[@"has_alcohol"] = eachObject[@"has_alcohol"];
    newObject[@"phone_reservation"] = eachObject[@"phone_reservation"];
    
    newObject[@"open_hour"] = [self replaceWeekDay:eachObject[@"open_hour"]];
    
    PFRelation *tagRelation = [newObject relationForKey:@"tag"];
    NSArray *tagArray = [[[eachObject relationForKey:@"tag"] query] findObjects];
    for (PFObject *item in tagArray) {
        [tagRelation addObject:item];
    }
    
    PFRelation *userRelation = [newObject relationForKey:@"user"];
    NSArray *userArray = [[[eachObject relationForKey:@"user"] query] findObjects];
    for (PFObject *item in userArray) {
        [userRelation addObject:item];
    }
    
    PFRelation *menuRelation = [newObject relationForKey:@"menu"];
    NSArray *menuArray = [[[eachObject relationForKey:@"menu"] query] findObjects];
    for (PFObject *item in menuArray) {
        [menuRelation addObject:item];
    }
    
    PFRelation *categoryRelation = [newObject relationForKey:@"category"];
    NSArray *categoryArray = [[[eachObject relationForKey:@"category"] query] findObjects];
    for (PFObject *item in categoryArray) {
        [categoryRelation addObject:item];
    }
    
    if (eachObject[@"has_photo"]) {
        
        newObject[@"avatar"] = eachObject[@"avatar"];
        
        PFRelation *photosRelation = [newObject relationForKey:@"photos"];
        NSArray *photosArray = [[[eachObject relationForKey:@"photos"] query] findObjects];
        for (PFObject *item in photosArray) {
            [photosRelation addObject:item];
        }
    }
    [newObject save];
    
    clearId += 1;
    
    if (clearId == clearArray.count) {
        
        pageId += 1;
        clearId = 0;
        [self clearData];
        
    }else{
        
        i(clearId+pageId*100)
        
        [self copyParseClass:clearArray[clearId]];
    }
}

-(NSString *)replaceWeekDay:(NSString *)weekday
{
    weekday = [weekday stringByReplacingOccurrencesOfString:@"Monday:" withString:@"Mon"];
    weekday = [weekday stringByReplacingOccurrencesOfString:@"Tuesday:" withString:@"Tue"];
    weekday = [weekday stringByReplacingOccurrencesOfString:@"Wednesday:" withString:@"Wed"];
    weekday = [weekday stringByReplacingOccurrencesOfString:@"Thursday:" withString:@"Thur"];
    weekday = [weekday stringByReplacingOccurrencesOfString:@"Friday:" withString:@"Fri"];
    weekday = [weekday stringByReplacingOccurrencesOfString:@"Saturday:" withString:@"Sat"];
    weekday = [weekday stringByReplacingOccurrencesOfString:@"Sunday:" withString:@"Sun"];
    weekday = [weekday stringByReplacingOccurrencesOfString:@"–" withString:@"~"];
    
    return weekday;
}

-(void)findDuplicateData:(PFObject *)eachObject
{
    PFQuery *query = [PFQuery queryWithClassName:@"StockholmPlace"];
    [query whereKey:@"name" equalTo:eachObject[@"name"]];
    [query whereKey:@"address" equalTo:eachObject[@"address"]];
    [query whereKey:@"reference" equalTo:eachObject[@"reference"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            for (int i = 0; i < objects.count - 1; i++) {
                
                if ([objects[i] delete]) {
                    s(@"Delete Successful")
                }
            }
            
            clearId += 1;
            
            i(clearId+pageId*100)
            
            if(clearId != 100){
                [self findDuplicateData:clearArray[clearId]];
            }else{
                clearId = 0;
                pageId += 1;
                [self clearData];
            }
            
        } else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)getPhotoUrl:(NSDictionary *)photoDataDictionary
{
    NSString *photoReference = photoDataDictionary[@"photo_reference"];
    
    [self getRealImageUrl:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=1536&photoreference=%@&sensor=false&key=%@",photoReference,keyArray[keyArrayId]]];
}

-(void)savePhotoUrl:(PFObject *)object withUrl:(NSString *)photoUrl
{
    PFObject *photoObject = [PFObject objectWithClassName:@"Photo"];
    photoObject[@"url"] = photoUrl;
    photoObject[@"other_category"]=@YES;
    [photoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        PFRelation *photoRelation = [object relationForKey:@"photos"];
        [photoRelation addObject:photoObject];
        
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            photoArrayId += 1;
            
            if (photoArray.count > photoArrayId) {
                
                [self getPhotoUrl:photoArray[photoArrayId]];
                
            }else{
                
                [self goNextPhoto];
            }
        }];
    }];
}

-(void)getRealImageUrl:(NSString *)url
{
    [photoWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    s(request.URL.absoluteString)
    
    if ([request.URL.absoluteString rangeOfString:@"googleusercontent.com"].length > 0) {
        
        loadingPhotoUrl = request.URL.absoluteString;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (loadingPhotoUrl) {
        [self savePhotoUrl:currentObject withUrl:loadingPhotoUrl];
        loadingPhotoUrl = nil;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    s(@"load error:")
    s(error)
    if (error.code == 403) {
        keyArrayId += 1;
        [self getPhotoUrl:photoArray[photoArrayId]];
    }
}

-(void)goNextPhoto
{
    photoArrayId = 0;
    
    clearId += 1;
    
    if(clearId != 100){
        NSLog(@"arrayId:%d",clearId+pageId*100);
        [self addPhotoToParse:clearArray[clearId]];
        //[self addAvatarToParse:clearArray[clearId]];
    }else{
        clearId = 0;
        pageId += 1;
        i(clearId+pageId*100)
        [self clearData];
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
