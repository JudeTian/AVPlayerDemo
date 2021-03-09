//
//  AVPlayerViewController.m
//  AVPlayerDemo
//
//  Created by tl on 2018/5/15.
//  Copyright © 2018年 tl. All rights reserved.
//

#import "AVPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZoomInverTransition.h"

@interface AVPlayerViewController ()
@property (nonatomic,strong) AVPlayer *player;//播放器对象

@property (weak, nonatomic) IBOutlet UIView *container; //播放器容器
@property (weak, nonatomic) IBOutlet UIButton *playOrPause; //播放/暂停按钮
@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UISlider *progress;//播放进度
@property (assign, nonatomic) float total;

@end

@implementation AVPlayerViewController
@synthesize videoPath;

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self.player play];
    [self addNotification];
}

-(void)dealloc{
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self removeNotification];
}

-(void)setupUI{
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame= CGRectMake(0, 0, CGRectGetWidth(self.container.frame), CGRectGetHeight(self.container.frame)) ;
    playerLayer.videoGravity=AVLayerVideoGravityResizeAspect;
    [self.container.layer addSublayer:playerLayer];
    
    [self.backButton setImage:[UIImage imageNamed:@"baise"] forState:UIControlStateNormal];
    [self.backButton setImage:[UIImage imageNamed:@"huise"] forState:UIControlStateHighlighted];
    [self.progress setThumbImage:[UIImage imageNamed:@"yuandian"] forState:UIControlStateNormal];
    [self.progress setThumbImage:[UIImage imageNamed:@"yuandian"] forState:UIControlStateSelected];
}

-(AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem=[self getPlayItem:0];
        _player=[AVPlayer playerWithPlayerItem:playerItem];
        [self addProgressObserver];
        [self addObserverToPlayerItem:playerItem];
    }
    return _player;
}

-(AVPlayerItem *)getPlayItem:(int)videoIndex{
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:[self getFileUrl]];
    return playerItem;
}

-(NSURL *)getFileUrl{
    
    NSString *urlStr=[[NSBundle mainBundle] pathForResource:self.videoPath ofType:nil];
    
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    
    return url;
}
- (IBAction)progressValueChange:(UISlider *)sender {
    NSLog(@"progressValueChange：%.1f", sender.value);
    [self.currentTime setText:[self switchTime:self.total * sender.value]];
    [self.player seekToTime:CMTimeMake(self.total * sender.value,1)completionHandler:^(BOOL finished){
        if (finished) {
            [self.playOrPause setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
            [self.player play];
            if (!self.playBtn.isHidden) {
                [self.playBtn setHidden:true];
            }
        }
    }];
}

-(void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    [self.playOrPause setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
    [self.currentTime setText:[NSString stringWithFormat:@"00:00"]];
    [self.player seekToTime:CMTimeMake(0,1)];
    [self.progress setValue:0 animated:false];
    [self.playBtn setHidden:false];
    
}

id timeObserver;

-(void)addProgressObserver{
    AVPlayerItem *playerItem=self.player.currentItem;
    UISlider *progress=self.progress;
    //这里设置每秒执行一次
    __weak typeof(self)WeakSelf = self;
    timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        WeakSelf.total=CMTimeGetSeconds([playerItem duration]);
        NSLog(@"当前已经播放%.2fs.",current);
        if (current) {
            [progress setValue:current/WeakSelf.total animated:YES];
            [WeakSelf.currentTime setText:[WeakSelf switchTime:current]];
        }
    }];
}

-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            [self.totalTime setText:[self switchTime:CMTimeGetSeconds(playerItem.duration)]];
        }
    }
}

- (IBAction)playClick:(UIButton *)sender {
    NSLog(@"self.player.rate= %f", self.player.rate);
    if(self.player.rate==0){ //说明时暂停
        [self.playOrPause setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        [self.playBtn setHidden:true];
        [self.player play];
    }else if(self.player.rate==1){//正在播放
        [self.player pause];
        [self.playOrPause setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
        [self.playBtn setHidden:false];
    }
}

- (IBAction)closeClick:(id)sender {
    [self removeNotification];
    [self.player removeTimeObserver:timeObserver];
    [self.navigationController popViewControllerAnimated:YES];
}

UIPercentDrivenInteractiveTransition *percentTransition;

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationPop) {
        ZoomInverTransition *zoomInvert = [ZoomInverTransition new];
        return zoomInvert;
    }else{
        return nil;
    }
    
}

- (NSString *)switchTime:(float) currentSecond{
    int second = (int)currentSecond%60;
    int mintue = (int)currentSecond/60;
    NSString *secondStr = @"00";
    NSString *mintueStr = @"00";
    if (second <10) {
        secondStr = [NSString stringWithFormat:@"0%d", second];
    } else {
        secondStr = [NSString stringWithFormat:@"%d", second];
    }
    if (mintue <10) {
        mintueStr = [NSString stringWithFormat:@"0%d", mintue];
    } else {
        mintueStr = [NSString stringWithFormat:@"%d", mintue];
    }
    return [NSString stringWithFormat:@"%@:%@",mintueStr,secondStr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
