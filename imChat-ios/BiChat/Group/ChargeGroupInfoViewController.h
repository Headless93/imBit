//
//  ChargeGroupInfoViewController.h
//  BiChat
//
//  Created by imac2 on 2019/4/1.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChargeGroupInfoViewController : UITableViewController

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;

@end

NS_ASSUME_NONNULL_END
