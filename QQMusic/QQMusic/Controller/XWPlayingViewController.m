//
//  XWPlayingViewController.m
//  QQMusic
//
//  Created by fangjs on 16/9/7.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "XWPlayingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "XWMusic.h"
#import "CALayer+PauseAimate.h"
#import "XWLrcView.h"
#import "XWLrcLabel.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

#define XMGColor(r,g,b,a)[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


@interface XWPlayingViewController ()<UIScrollViewDelegate,AVAudioPlayerDelegate>
/**背景图片*/
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
/**歌手图片*/
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
/**进度条*/
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
/** 歌曲名 */
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
/** 歌手名 */
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
/** 当前播放时间 */
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
/** 歌曲的总时间 */
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
/** 播放/暂停按钮*/
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseButton;
/** 上一首按钮 */
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
/** 下一首按钮*/
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
/** 进度条时间 */
@property (nonatomic, strong) NSTimer *progressTimer;
/** 歌词内容的尺寸*/
@property (weak, nonatomic) IBOutlet XWLrcView *lrcView;
/** 歌词显示*/
@property (weak, nonatomic) IBOutlet XWLrcLabel *lrcLabel;

/** 播放器 */
@property (nonatomic, strong) AVAudioPlayer *currentPlayer;
/** 定时器 */
@property (strong , nonatomic) CADisplayLink *lrcTime;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
#pragma mark - slider 的处理
- (IBAction)start;
- (IBAction)end;
- (IBAction)progressValueChange;
- (IBAction)sliderClick:(UITapGestureRecognizer *)sender;

#pragma mark - 按钮处理事件
- (IBAction)playOrPause;
- (IBAction)preVious;
- (IBAction)next;

@end


@implementation XWPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加毛玻璃效果
    [self setupBlur];
    
    //添加背景图片
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    
    //设置主界面上的歌词显示
    self.lrcView.lrcLabel = self.lrcLabel;
    
    //开始播放音乐
    [self startPlayMusic];
    
    // 设置歌词 view 的 contentSize
    self.lrcView.contentSize = CGSizeMake(self.view.bounds.size.width * 3, 0);
    [self.lrcView setContentOffset:CGPointMake(self.view.bounds.size.width, 0) animated:YES];
    
    //从后台返回前台是通过通知让背景图片继续转动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iconViewAnimation) name:iconViewAnimationNotification object:nil];
    
}


//iconView 的动画
- (void) iconViewAnimation{
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = @(0);
    rotateAnimation.toValue = @(M_PI * 2);
    rotateAnimation.repeatCount = NSIntegerMax;
    rotateAnimation.duration = 35;
    [self.iconView.layer addAnimation:rotateAnimation forKey:nil];
}


//开启远程交互(启用远程事件接收,即使用耳机上的控制键开控制)
- (void) remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self playOrPause];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self preVious];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self next];
            break;
            
        default:
            break;
    }
}

#pragma mark - 添加毛玻璃效果
- (void)setupBlur{
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [self.backgroundView addSubview:toolBar];
    toolBar.barStyle = UIBarStyleBlack;
    
    //添加约束
    [toolBar makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.backgroundView);
    }];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // .添加圆角
    self.iconView.layer.cornerRadius = self.iconView.bounds.size.width * 0.5;
    self.iconView.layer.masksToBounds = YES;
    self.iconView.layer.borderColor = XMGColor(36, 36, 36, 1.0).CGColor;
    self.iconView.layer.borderWidth = 8;
}


#pragma mark - 开始播放音乐
- (void) startPlayMusic {
    
    //添加 iconView 的动画
    [self iconViewAnimation];
    
    //获取当前正在播放的音乐
    XWMusic *playingMusic = [XWMusicTool playingMusic];
    
    //设置界面信息
    self.backgroundView.image = [UIImage imageNamed:playingMusic.icon];
    self.iconView.image = [UIImage imageNamed:playingMusic.icon];
    self.songLabel.text = playingMusic.name;
    self.singerLabel.text = playingMusic.singer;
    
    //播放音乐
    AVAudioPlayer *currentPlayer = [XMGAudioTool playMusicWithFileName:playingMusic.filename];
    currentPlayer.delegate = self;
    self.currentTimeLabel.text = [self stringWithTime:currentPlayer.currentTime];
    self.totalTimeLabel.text = [self stringWithTime:currentPlayer.duration];
    self.currentPlayer = currentPlayer;
    
    //设置播放按钮的状态
    self.playOrPauseButton.selected = self.currentPlayer.isPlaying;
    
    //设置歌词
    self.lrcView.lrcName = playingMusic.lrcname;
    self.lrcView.duration = self.currentPlayer.duration;
    
    //添加或移除定时器
    [self removeProgressTimer];
    [self addProgressTimer];
    [self removeLrcTimer];
    [self addLrcTimer];
}

//将时间戳转换为字符串
- (NSString *)stringWithTime:(NSTimeInterval) time {
    NSInteger minute = time / 60;
    //round():四舍五入
    NSInteger second = (int) round(time) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",minute,second];
}

//添加定时器
- (void) addProgressTimer {
    [self updateProgressValue];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressValue) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}

//移除定时器
- (void) removeProgressTimer {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

//添加歌词定时器
- (void) addLrcTimer{
    //添加定时器
    self.lrcTime = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrcLine)];
    [self.lrcTime addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
//移除歌词定时器
- (void)removeLrcTimer{
    [self.lrcTime invalidate];
    self.lrcTime = nil;
}

//更新播放时间和滑块的位置
- (void) updateProgressValue {
    self.currentTimeLabel.text = [self stringWithTime:self.currentPlayer.currentTime];
    self.progressSlider.value = self.currentPlayer.currentTime / self.currentPlayer.duration;
}

//更新歌词
- (void) updateLrcLine {
    self.lrcView.currentTime = self.currentPlayer.currentTime;
}

#pragma mark - 旋转动画
- (void) rotatingAnimation {
    //每次刷新所旋转的角度
    CGFloat angleA = (10 / 60.0) / 180.0 * M_PI;
    self.iconView.transform = CGAffineTransformRotate(self.iconView.transform,angleA);
}

- (void) timeChange {
    //移除定时器
    [self rotatingAnimation];
}

#pragma mark - slider 的处理
//slider 按下时的响应事件
- (IBAction)start {
    [self removeProgressTimer];
}
//slider 松开时的响应事件
- (IBAction)end {
    //更新播放时间
    self.currentPlayer.currentTime = self.progressSlider.value * self.currentPlayer.duration;
    
    //添加定时器
    [self addProgressTimer];
}
//slider 滑动时的响应事件
- (IBAction)progressValueChange {
    self.currentTimeLabel.text = [self stringWithTime:self.progressSlider.value * self.currentPlayer.duration];
}
//slider 上点击事件的响应
- (IBAction)sliderClick:(UITapGestureRecognizer *)sender {
    //过去点击到的点
    CGPoint point = [sender locationInView:sender.view];
    
    //获取点击处的点所占的比例
    CGFloat ratio = point.x / self.progressSlider.frame.size.width;
    
    //更新播放时间
    self.currentPlayer.currentTime = ratio * self.currentPlayer.duration;
    
    //更新时间和滑块的位置
    [self updateProgressValue];
}

#pragma mark - 按钮响应事件
- (IBAction)playOrPause {
    self.playOrPauseButton.selected = !self.playOrPauseButton.selected;
    if (self.currentPlayer.isPlaying) {
        //暂停播放
        [self.currentPlayer pause];
        //移除定时器
        [self removeProgressTimer];
        //停止旋转动画
        [self.iconView.layer pauseAnimate];
    } else {
        //开始播放
        [self.currentPlayer play];
        //添加定时器
        [self addProgressTimer];
        //继续旋转动画
        [self.iconView.layer resumeAnimate];
    }
}

- (IBAction)preVious {
    //获取上一首音乐
    XWMusic *previousMusic = [XWMusicTool playPreviousMusic];
    //播放上一首歌
    [self playMusicWithMusic:previousMusic];
}

- (IBAction)next {
    //获取下一首音乐
    XWMusic *nextMusic = [XWMusicTool playNextMusic];
    //播放下一首歌
    [self playMusicWithMusic:nextMusic];
}

- (void) playMusicWithMusic:(XWMusic *)music {
    //获取当前正在播放的音乐
    XWMusic *currentMusic = [XWMusicTool playingMusic];
    
    //停止当前正在播放的音乐
    [XMGAudioTool stopMusicWithFileName:currentMusic.filename];
    
    //设置默认播放的音乐
    [XWMusicTool setupPlayingMusic:music];
    
    //开始播放音乐
    [self startPlayMusic];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat scrollViewWidth = scrollView.bounds.size.width;
    
    //获取滑动的偏移量
    CGPoint point = scrollView.contentOffset;
    
    NSInteger pageIndex = point.x / screenWidth;
    self.pageControl.currentPage = pageIndex;
    
    CGFloat alpha = 1.0;
    if (point.x != self.view.bounds.size.width) {
        //计算滑动偏移量所占的比例
        if (point.x < 375) {
            alpha = 1.0 - (screenWidth - point.x) / scrollViewWidth;
        }else {
            alpha = 1.0 - (point.x - screenWidth) / scrollViewWidth;
        }
        //设置 alpha
        self.iconView.alpha = alpha;
        self.lrcLabel.alpha = alpha;
    }
}

#pragma mark - 改变状态栏的文字颜色
- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - 移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - <AVAudioPlayerDelegate>
//当一首歌曲播放完之后会调用此方法,暂停或遇到错误时不会被调用
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    //设置播放按钮为暂停状态
    self.playOrPauseButton.selected = NO;
    //移除定时器
    [self removeProgressTimer];
    //停止旋转动画
    [self.iconView.layer pauseAnimate];
    //播放下一首歌
    [self next];
    //添加定时器
    [self addProgressTimer];
    //继续旋转动画
    [self.iconView.layer resumeAnimate];
}

@end
