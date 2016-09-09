//
//  XMGAudioTool.h
//  02-播放音效
//
//  Created by xiaomage on 15/12/18.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface XMGAudioTool : NSObject

// 播放音乐 fileName:音乐文件
+ (AVAudioPlayer *)playMusicWithFileName:(NSString *)fileName;

// 暂停音乐 fileName:音乐文件
+ (void)pauseMusicWithFileName:(NSString *)fileName;

// 停止音乐 fileName:音乐文件
+ (void)stopMusicWithFileName:(NSString *)fileName;

// 播放音效 soundName:音效文件
+ (void)playSoundWithSoundName:(NSString *)soundName;

@end
