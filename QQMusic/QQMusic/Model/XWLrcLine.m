//
//  XWLrcLine.m
//  QQMusic
//
//  Created by fangjs on 16/9/9.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "XWLrcLine.h"

@implementation XWLrcLine


- (instancetype)initWithLrcLineString:(NSString *)lrcLineString {
    if (self = [super init]) {
        //[02:08.49]怎么爱你都不嫌多
        
        NSArray *lrcArray = [lrcLineString componentsSeparatedByString:@"]"];
        self.text = lrcArray[1];
        self.time = [self timeWithLrcLineString:[lrcArray[0] substringFromIndex:1]];
    }
    return self;
}

+ (instancetype)LrcLineString:(NSString *)lrcLineString {
    return [[self alloc] initWithLrcLineString:lrcLineString];
}

- (NSTimeInterval) timeWithLrcLineString:(NSString *)lrcLineString {
    //02:08.49
    //分钟
    double min = [[lrcLineString componentsSeparatedByString:@":"][0] doubleValue];
    
    //秒钟
    double sec = [[lrcLineString substringWithRange:NSMakeRange(3, 2)] doubleValue];
    
    //毫秒
    double hs = [[lrcLineString componentsSeparatedByString:@"."][1] doubleValue];

    return min * 60 + sec + hs * 0.001;
    
}

@end
