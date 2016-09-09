//
//  XWMusic.h
//  QQMusic
//
//  Created by fangjs on 16/9/8.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XWMusic : NSObject

/**歌曲名称*/
@property (strong , nonatomic) NSString *name;
/**文件名*/
@property (strong , nonatomic) NSString *filename;
/**歌词名称*/
@property (strong , nonatomic) NSString *lrcname;
/**歌手名称*/
@property (strong , nonatomic) NSString *singer;
/**歌手图片*/
@property (strong , nonatomic) NSString *singerIcon;
/**歌曲背景图片*/
@property (strong , nonatomic) NSString *icon;

@end
