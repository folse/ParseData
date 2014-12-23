//
//  ViewController.m
//  parsedata
//
//  Created by folse on 12/22/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "ViewController.h"
#import "QiniuSimpleUploader.h"
#import "F.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController ()<QiniuUploadDelegate>
{
    int pageId;
    int clearId;
    NSMutableArray *clearArray;
    PFObject *currentObject;
}

@property (nonatomic, strong) QiniuSimpleUploader *qiniuUploader;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    clearArray = [NSMutableArray new];
    
    [self initQiniu];
    
    [self clearData];
}

-(void)initQiniu
{
    self.qiniuUploader = [QiniuSimpleUploader uploaderWithToken:[F getQiNiuToken]];
    self.qiniuUploader.delegate = self;
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
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:eachObject[@"url"]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            currentObject = eachObject;
            
            [self uploadToQiNiu:image];
            
        }];

    }
}

-(void)uploadToQiNiu:(UIImage *)image
{
    NSString *timeSp = [NSString stringWithFormat:@"%.3f", [[NSDate date] timeIntervalSince1970]];
    timeSp = [timeSp stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSData *imageData = UIImageJPEGRepresentation(image , 1.0);
    [self.qiniuUploader uploadFileData:imageData key:[NSString stringWithFormat:@"%@.png", timeSp] extra:nil];
}

- (void)uploadSucceeded:(NSString *)theFilePath ret:(NSDictionary *)ret
{
    NSString *imageUrl = [NSString stringWithFormat:@"http://mmwd-client.qiniudn.com/%@",ret[@"key"]];
    
    currentObject[@"url"] = imageUrl;
    [currentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
       
        clearId += 1;
        
        if (clearId == clearArray.count) {
            
            pageId += 1;
            clearId = 0;
            [self clearData];
            
        }else{
            
            [self addPhotoToQiniu:clearArray[clearId]];
        }
        
    }];

}

- (void)uploadProgressUpdated:(NSString *)theFilePath percent:(float)percent
{
    
}

- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
