//
//  XWScrollView.m
//  QQMusic
//
//  Created by fangjs on 16/9/9.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "XWLrcView.h"
#import "XWLrcCell.h"
#import "XWLrcTool.h"
#import "XWLrcLine.h"
#import "XWLrcLabel.h"
#import "XWMusic.h"
#import "XWMusicTool.h"
#import <MediaPlayer/MediaPlayer.h>

@interface XWLrcView()<UITableViewDataSource>

@property (weak , nonatomic) UITableView *tableView;
/**歌词数组*/
@property (strong , nonatomic)  NSArray *lrcList;

/**记录当前刷新的某行*/
@property (assign , nonatomic) NSInteger currentIndex;

@end

@implementation XWLrcView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        //设置歌词列表
        [self setupTableView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //设置歌词列表
        [self setupTableView];
    }
    return self;
}
//设置歌词列表
- (void) setupTableView {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.dataSource = self;
    [self addSubview:tableView];
    
    self.tableView = tableView;
}
//添加约束
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top);
        make.bottom.equalTo(self.bottom);
        make.height.equalTo(self.height);
        make.right.equalTo(self.right);
        make.left.equalTo(self.left).offset(self.bounds.size.width);
        make.width.equalTo(self.width);
    }];
    //设置 tableView 的属性
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.rowHeight = 30;
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.bounds.size.height * 0.5, 0, self.tableView.bounds.size.height * 0.5, 0);
}


#pragma mark - UITableViewDdataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lrcList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XWLrcCell *cell = [XWLrcCell initCellWithTableView:tableView];
   
    if ((self.currentIndex == indexPath.row)) {
        cell.lrcLabel.font = [UIFont systemFontOfSize:17];
    }else {
        cell.lrcLabel.font = [UIFont systemFontOfSize:14];
        cell.lrcLabel.progress = 0;
    }
    
    XWLrcLine *lrcLine = self.lrcList[indexPath.row];
    cell.lrcLabel.text = lrcLine.text;
   
    return cell;
}

#pragma mark - 重写 lrcName 
- (void)setLrcName:(NSString *)lrcName {
    
    //-1让 tableView 滚动到中间
    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.bounds.size.height * 0.5) animated:NO];
    
    // 0.将currentIndex设置为0
    self.currentIndex = 0;
    
    //记录歌曲名称
    _lrcName = [lrcName copy];
    
    //解析歌词
    self.lrcList = [XWLrcTool lrcToolWithLrcName:lrcName];

    //设置第一句歌词
    XWLrcLine *firstLrcLine = self.lrcList[0];
    self.lrcLabel.text = firstLrcLine.text;
    
    //刷新列表
    [self.tableView reloadData];
}

#pragma mark - 重写 currentTime set 方法
- (void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    
    NSInteger count = self.lrcList.count;
    for (NSInteger i = 0; i < count; i++) {
        //取出当前的歌词
        XWLrcLine *currentLrcLine = self.lrcList[i];
        
        //取出下一句歌词
        NSInteger nextIndex = i + 1;
        XWLrcLine *nextLrcLine = nil;
        if (nextIndex < count) {
            nextLrcLine = self.lrcList[nextIndex];
        }
        
        //用当前播放器的时间,跟当前这句歌词的时间和下一句歌词的时间进行比对,如果大于等于当前歌词的时间,并且小于下一句歌词的时间及当前歌词不为空,就显示当前的歌词
        if (self.currentIndex != i && currentTime >= currentLrcLine.time && currentTime < nextLrcLine.time && currentLrcLine.text.length > 0) {
            
            //获取当前这句歌词和上一句歌词的 IndexPath
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            
            //记录当前刷新的某行
            self.currentIndex = i;
            
            //刷新当前和上一句歌词
            [self.tableView reloadRowsAtIndexPaths:@[indexPath,previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            //将当前这句歌词滚动到中间
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            //设置主界面上的歌词文字
            self.lrcLabel.text = currentLrcLine.text;
            
            //设置锁屏
            [self genaratorLockImage];

        }
        if (self.currentIndex == i) {
            //用(当前播放器的时间减去上一句歌词的时间) 除以 (下一句歌词的时间减去上一句歌词的时间)
            CGFloat value = (self.currentTime - currentLrcLine.time) / (nextLrcLine.time - currentLrcLine.time);
            
            //设置当店歌词的播放进度
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
        
            //获取对应的 cell
            XWLrcCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.lrcLabel.progress = value;
            self.lrcLabel.progress = value;
        }
    }
}

#pragma mark - 生成锁屏图片
- (void) genaratorLockImage {
    //获取当前音乐的图片
    XWMusic *playingMusic = [XWMusicTool playingMusic];
    UIImage *currentImage = [UIImage imageNamed:playingMusic.icon];
    
    //取出歌词
    //取出当前歌词
    XWLrcLine *currentLrcLine = self.lrcList[self.currentIndex];
    
    //取出上一句歌词
    NSInteger  previousIndex = self.currentIndex - 1;
    XWLrcLine *previousLrcLine = nil;
    if (previousIndex >= 0) {
        previousLrcLine = self.lrcList[previousIndex];
    }
    
    //取出下一句歌词
    NSInteger nextIndex = self.currentIndex + 1;
    XWLrcLine *nextLrcLine = nil;
    if (nextIndex < self.lrcList.count) {
        nextLrcLine = self.lrcList[nextIndex];
    }
    
    //生成水印图片
    //获取上下文
    UIGraphicsBeginImageContext(currentImage.size);
    
    //将图片画上去
    [currentImage drawInRect:CGRectMake(0, 0, currentImage.size.width, currentImage.size.height)];
    
    //将文字画上去
    //歌词显示的高度
    CGFloat lrcTextHeight = 25;
    //设置居中属性
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    //上一句歌词
    [previousLrcLine.text drawInRect:CGRectMake(0, currentImage.size.height - lrcTextHeight * 3, currentImage.size.width, lrcTextHeight) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor lightGrayColor],NSParagraphStyleAttributeName:paragraphStyle}];
    //当前正在播放的歌词
    [currentLrcLine.text drawInRect:CGRectMake(0, currentImage.size.height - lrcTextHeight * 2, currentImage.size.width, lrcTextHeight) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:paragraphStyle}];
    //下一句歌词
    [nextLrcLine.text drawInRect:CGRectMake(0, currentImage.size.height - lrcTextHeight, currentImage.size.width, lrcTextHeight) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor lightGrayColor],NSParagraphStyleAttributeName:paragraphStyle}];

    //获取完成后的图片
    UIImage *finishedIamge = UIGraphicsGetImageFromCurrentImageContext();
    //关闭上下文
    UIGraphicsEndImageContext();

    [self setUpLockScreenWithLockImage:finishedIamge];
}


#pragma mark - 设置锁屏界面
- (void)setUpLockScreenWithLockImage:(UIImage *) lockImage {
    
    //获取当前正在播放的歌曲
    XWMusic *playingMusic = [XWMusicTool playingMusic];
    
    //获取锁屏中心
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    /*
     // MPMediaItemPropertyAlbumTitle
     // MPMediaItemPropertyAlbumTrackCount
     // MPMediaItemPropertyAlbumTrackNumber
     // MPMediaItemPropertyArtist
     // MPMediaItemPropertyArtwork
     // MPMediaItemPropertyComposer
     // MPMediaItemPropertyDiscCount
     // MPMediaItemPropertyDiscNumber
     // MPMediaItemPropertyGenre
     // MPMediaItemPropertyPersistentID
     // MPMediaItemPropertyPlaybackDuration
     // MPMediaItemPropertyTitle
     */
    //设置锁屏参数
    NSMutableDictionary *playInfoDict = [NSMutableDictionary dictionary];
    
    //设置歌曲名称
    [playInfoDict setObject:playingMusic.name forKey:MPMediaItemPropertyAlbumTitle];
    
    //设置歌手名称
    [playInfoDict setObject:playingMusic.singer forKey:MPMediaItemPropertyArtist];
    
    //设置封面图片
    MPMediaItemArtwork *itemWork = [[MPMediaItemArtwork alloc] initWithImage:lockImage];
    [playInfoDict setObject:itemWork forKey:MPMediaItemPropertyArtwork];
    
    //设置歌曲总时长
    [playInfoDict setObject:@(self.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    
    //设置歌曲当前播放的时间
    [playInfoDict setObject:@(self.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    //设置参数
    infoCenter.nowPlayingInfo = playInfoDict;
    
    //开启远程交互
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}












@end
