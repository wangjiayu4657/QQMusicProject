//
//  XWLrcTool.m
//  QQMusic
//
//  Created by fangjs on 16/9/9.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "XWLrcTool.h"
#import "XWLrcLine.h"

@implementation XWLrcTool

+ (NSArray *)lrcToolWithLrcName:(NSString *)lrcName {
    //获取路径
    NSString *path = [[NSBundle mainBundle] pathForResource:lrcName ofType:nil];
    //获取歌词
    NSString *lrcString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //转化为歌词数组
    NSArray *lrcArray = [lrcString componentsSeparatedByString:@"\n"];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSString *lrcline in lrcArray) {
        /**
         [00:00.91]小苹果
         [00:01.75]作词：王太利 作曲：王太利
         [00:02.47]演唱：筷子兄弟
         [00:03.32]
         */
        //过滤歌词以外的信息
        if ([lrcline hasPrefix:@"[ti:"] || [lrcline hasPrefix:@"[ar:"] || [lrcline hasPrefix:@"[al:"] || ![lrcline hasPrefix:@"["] ) {
            continue;
        }
        
        //将歌词转化为模型
        XWLrcLine *lrcLineString = [XWLrcLine LrcLineString:lrcline];
        [tempArray addObject:lrcLineString];
    }
    
    return tempArray;
}

@end
