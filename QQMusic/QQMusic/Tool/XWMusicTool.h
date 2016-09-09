//
//  XWMusicTool.h
//  QQMusic
//
//  Created by fangjs on 16/9/8.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XWMusic;


@interface XWMusicTool : NSObject

/** 所有音乐 */
+ (NSArray *) musics;

/** 当前正在播放的音乐 */
+ (XWMusic *) playingMusic;

/** 设置默认的音乐 */
+ (void) setupPlayingMusic:(XWMusic *) playingMusic;

/** 播放上一首音乐 */
+ (XWMusic *) playPreviousMusic;

/** 播放下一首音乐 */
+ (XWMusic *) playNextMusic;

@end
