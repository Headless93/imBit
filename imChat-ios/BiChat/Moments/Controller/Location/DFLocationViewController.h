//
//  DFLocationViewController.h
//  WeChatLocationDemo
//
//  Created by Lucas.Xu on 2017/12/8.
//  Copyright © 2017年 Lucas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DFLocationViewControllerDelegate <NSObject>

-(void)saveLocationWithAMapPOI:(AMapPOI *)loca;

@end


@interface DFLocationViewController : UIViewController

@property (nonatomic,weak) id<DFLocationViewControllerDelegate> delegage;

@end


