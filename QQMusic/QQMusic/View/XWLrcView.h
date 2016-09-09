//
//  XWScrollView.h
//  QQMusic
//
//  Created by fangjs on 16/9/9.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XWLrcLabel;
@interface XWLrcView : UIScrollView

/**歌词名*/
@property (copy , nonatomic)  NSString *lrcName;

/**歌词 label*/
@property (strong , nonatomic) XWLrcLabel *lrcLabel;

/** 当前播放器播放的时间*/
@property (assign , nonatomic)  NSTimeInterval currentTime;

@end
