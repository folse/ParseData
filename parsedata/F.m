//
//  F.m
//  mmgj
//
//  Created by folse on 11/19/13.
//  Copyright (c) 2013 folse. All rights reserved.
//

#import "F.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "MF_Base64Additions.h"
@interface F ()

@end

@implementation F

+ (NSString *)MD5:(NSString *)text
{
    if (text) {
        const char *cStr = [text UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5(cStr, (int)strlen(cStr), result);
        
        return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                 result[0], result[1], result[2], result[3],
                 result[4], result[5], result[6], result[7],
                 result[8], result[9], result[10], result[11],
                 result[12], result[13], result[14], result[15]
                 ] lowercaseString];
    }else{
        return @"";
    }
    
}

+ (NSString *)getMD5FilePathWithUrl:(NSString *)url
{
    NSString *urlMD5 = [self MD5:url];
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [documents[0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",urlMD5]];
}

+ (NSString *)getQiNiuToken{
    
    NSDate *localDate = [NSDate date];
    NSDate *addOneHourTime = [localDate dateByAddingTimeInterval: 24 * 60 * 60 ];
    NSString *deadLineTime = [NSString stringWithFormat:@"%ld", (long)[addOneHourTime timeIntervalSince1970]];
    NSString *base64String = [[NSString stringWithFormat:@"{\"scope\":\"ts-image1\",\"deadline\":%@}",deadLineTime] base64String];
    NSString *safeBaseURL =  [[[base64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"]stringByReplacingOccurrencesOfString:@"=" withString:@"9"];
    NSString *HMacSha1String = [self hmacsha1:safeBaseURL secret:QiNiuSK];
    HMacSha1String = [[HMacSha1String stringByReplacingOccurrencesOfString:@"+" withString:@"-"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    NSString *qiniuToken = [NSString stringWithFormat:@"%@:%@:%@",QiNiuAK,HMacSha1String,safeBaseURL];
    
    return  qiniuToken;
}

+ (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key {
    
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString *hash = [HMAC base64String];
    
    return hash;
}

+ (BOOL)validateMobile:(NSString *)mobileNum
{
    if(mobileNum.length == 11){
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)isStringContainsEmoji:(NSString *)string {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [string length])];
    
    if (numberOfMatches > 0) {
        return YES;
    }
    
    return NO;
}

@end
