//
//  XWLrcLine.h
//  QQMusic
//
//  Created by fangjs on 16/9/9.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWLrcLine : NSObject

/**歌词*/
@property (copy , nonatomic)  NSString *text;

/**时间戳*/
@property (assign , nonatomic)  NSTimeInterval time;

- (instancetype) initWithLrcLineString:(NSString *) lrcLineString;
+ (instancetype) LrcLineString:(NSString *) lrcLineString;

@end
