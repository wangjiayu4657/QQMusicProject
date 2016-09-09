//
//  XWLrcLabel.m
//  QQMusic
//
//  Created by fangjs on 16/9/9.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "XWLrcLabel.h"

@implementation XWLrcLabel

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
//    NSLog(@"progress = %f",progress);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGRect fillRect = CGRectMake(0, 0, self.bounds.size.width * self.progress , self.bounds.size.height);
    
    [[UIColor greenColor] set];
    
    UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
}


@end
