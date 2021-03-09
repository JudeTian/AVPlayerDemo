//
//  RootViewController.m
//  AVPlayer
//
//  Created by tl on 2018/5/14.
//  Copyright © 2018年 cmjstudio. All rights reserved.
//

#import "RootViewController.h"
#import "AVPlayerViewController.h"
#import "ZoomTransition.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)openVideo:(id)sender {
    AVPlayerViewController *vc = [[AVPlayerViewController alloc]initWithNibName:@"AVPlayerViewController" bundle:nil];
    vc.videoPath = @"demo.mp4";
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.delegate = self;
}

#pragma mark - UINavigationControllerDelegate
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationPush) {
        
        ZoomTransition *zoom = [ZoomTransition new];
        return zoom;
    }else{
        return nil;
    }
}

@end
