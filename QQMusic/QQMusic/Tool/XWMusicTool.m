//
//  XWMusicTool.m
//  QQMusic
//
//  Created by fangjs on 16/9/8.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "XWMusicTool.h"
#import "XWMusic.h"


@implementation XWMusicTool

static NSArray *_musics;
static XWMusic *_playingMusic;

+(void)initialize {
    if (_musics == nil) {
        _musics = [XWMusic mj_objectArrayWithFilename:@"Musics.plist"];
    }
    if (_playingMusic == nil) {
        _playingMusic = _musics[1];
    }
}

+(NSArray *)musics {
    return _musics;
}

+ (XWMusic *)playingMusic {
    return _playingMusic;
}

+ (void)setupPlayingMusic:(XWMusic *)playingMusic {
    _playingMusic = playingMusic;
}

+ (XWMusic *)playPreviousMusic {
    //获取当前播放的音乐的下标
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    
    //获取上一首音乐的下标
    NSInteger previousIndex = --currentIndex;
    XWMusic *previousMusic = nil;
    if (previousIndex < 0) {
        previousIndex = _musics.count - 1;
    }
    
    previousMusic = _musics[previousIndex];
    return previousMusic;
}

+ (XWMusic *)playNextMusic {
    //获取当前播放的音乐的下标
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    
    NSInteger nextIndex = ++currentIndex;
    XWMusic *previousMusic = nil;
    if (nextIndex >= _musics.count) {
        nextIndex = 0;
    }
    
    previousMusic = _musics[nextIndex];
    return previousMusic;
}

@end
