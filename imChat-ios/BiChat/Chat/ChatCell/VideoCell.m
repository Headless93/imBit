//
//  VideoCell.m
//  BiChat
//
//  Created by imac2 on 2019/4/23.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "VideoCell.h"
#import "JSONKit.h"
#import "SectorProgressView.h"

@implementation VideoCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *dict4VideoInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    CGSize size = [BiChatGlobal calcThumbSize:[[dict4VideoInfo objectForKey:@"width"]integerValue] height:[[dict4VideoInfo objectForKey:@"height"]integerValue]];
    
    if (![[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] && showNickName)
        return size.height + 36;
    else
        return size.height + 16;
}

+ (void)renderCellInView:(UIView *)contentView
                 peerUid:(NSString *)peerUid
                 message:(NSMutableDictionary *)message
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
       inMultiSelectMode:(BOOL)inMultiSelectMode
               indexPath:(NSIndexPath *)indexPath
         longPressTarget:(id)longPressTarget
         longPressAction:(SEL)longPressAction
               tapTarget:(id)tapTarget
               tapAction:(SEL)tapAction
     tapUserAvatarTarget:(id)tapUserAvatarTarget
     tapUserAvatarAction:(SEL)tapUserAvatarAction
longPressUserAvatarTarget:(id)longPressUserAvatarTarget
longPressUserAvatarAction:(SEL)longPressUserAvatarAction
            remarkTarget:(id)remarkTarget
            remarkAction:(SEL)remarkAction
            resendTarget:(id)resendTarget
            resendAction:(SEL)resendAction
{
    //获取图片信息
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *dict4VideoInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //计算比较合适的图片大小
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    CGSize size = [BiChatGlobal calcThumbSize:[[dict4VideoInfo objectForKey:@"width"]integerValue] height:[[dict4VideoInfo objectForKey:@"height"]integerValue]];
    
    //是否自己发言
    if ([[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        //头像
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[BiChatGlobal sharedManager].uid nickName:[BiChatGlobal sharedManager].nickName avatar:[BiChatGlobal sharedManager].avatar frame:CGRectMake(cellWidth - 50, 0, 40, 40)];
        [self bundleView:view4Avatar
                WithUser:[message objectForKey:@"sender"]
                userName:[message objectForKey:@"senderUserName"]
                nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                  avatar:[message objectForKey:@"senderAvatar"]
                isPublic:[[message objectForKey:@"isPublic"]boolValue]
               tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
         longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
        [contentView addSubview:view4Avatar];
        
        //准备获取图片
        UIImageView *image4ThumbNail = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - size.width - 67, 0, size.width + 8, size.height + 6)];
        image4ThumbNail.contentMode = UIViewContentModeScaleAspectFill;
        image4ThumbNail.layer.cornerRadius = 7;
        image4ThumbNail.layer.borderWidth = 0.5;
        image4ThumbNail.layer.borderColor = [UIColor colorWithWhite:.8 alpha:1].CGColor;
        image4ThumbNail.clipsToBounds = YES;
        if ([[dict4VideoInfo objectForKey:@"thumbName"]length] > 0)
        {
            //本地是否已经存在
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *thumbPath = [documentsDirectory stringByAppendingPathComponent:[dict4VideoInfo objectForKey:@"localThumbName"]];
            NSFileManager *fmgr = [NSFileManager defaultManager];
            BOOL thumbFileExist = [[dict4VideoInfo objectForKey:@"localThumbName"]length] > 0 && [fmgr fileExistsAtPath:thumbPath];
            
            //图片
            if (thumbFileExist)
                image4ThumbNail.image = [UIImage imageWithContentsOfFile:thumbPath];
            else
            {
                NSString *thumbFile = [dict4VideoInfo objectForKey:@"ThumbName"];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, thumbFile]];
                [image4ThumbNail sd_setImageWithURL:url];
            }
            [contentView addSubview:image4ThumbNail];
        }
        
        //给图片增加长按手势
        if (!inMultiSelectMode)
        {
            image4ThumbNail.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
            objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetView", image4ThumbNail, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [image4ThumbNail addGestureRecognizer:longPressGest];
            
            //给图片增加轻点手势
            UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
            objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetView", image4ThumbNail, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [image4ThumbNail addGestureRecognizer:tapGest];
            
            //是否发送成功
            if ([[BiChatDataModule sharedDataModule]isMessageUnSent:[message objectForKey:@"msgId"]])
            {
                UIButton *button4Resend = [[UIButton alloc]initWithFrame:CGRectMake(cellWidth - size.width - 110, size.height / 2 - 20, 40, 40)];
                [button4Resend setImage:[UIImage imageNamed:@"failure"] forState:UIControlStateNormal];
                [button4Resend addTarget:resendTarget action:resendAction forControlEvents:UIControlEventTouchUpInside];
                objc_setAssociatedObject(button4Resend, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(button4Resend, @"targetView", image4ThumbNail, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(button4Resend, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [contentView addSubview:button4Resend];
            }
        }
        
        //是否有mask
        NSMutableDictionary *UploadInfo = [[BiChatGlobal sharedManager].dict4GlobalUFileUploadCache objectForKey:[message objectForKey:@"msgId"]];
        if (UploadInfo)
        {
            SectorProgressView *view4Progress = [UploadInfo objectForKey:@"progressView"];
            view4Progress.layer.cornerRadius = 7;
            view4Progress.clipsToBounds = YES;
            view4Progress.frame = image4ThumbNail.frame;
            [contentView addSubview:view4Progress];
            
            CGFloat ratio = [[UploadInfo objectForKey:@"ratio"]floatValue];
            view4Progress.progress = ratio;
        }
        else
        {
            //播放图标
            UIImageView *ImagePlay = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"playVideo"]];
            ImagePlay.center = CGPointMake(CGRectGetMidX(image4ThumbNail.bounds), CGRectGetMidY(image4ThumbNail.bounds));
            [image4ThumbNail addSubview:ImagePlay];
        }
    }
    else
    {
        if (inMultiSelectMode)
        {
            //头像
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[message objectForKey:@"sender"]
                                                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                                                      avatar:[message objectForKey:@"senderAvatar"]
                                                       width:40 height:40];
            view4Avatar.center = CGPointMake(70, 20);
            [self bundleView:view4Avatar
                    WithUser:[message objectForKey:@"sender"]
                    userName:[message objectForKey:@"senderUserName"]
                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                      avatar:[message objectForKey:@"senderAvatar"]
                    isPublic:[[message objectForKey:@"isPublic"]boolValue]
                   tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
             longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
            [contentView addSubview:view4Avatar];
            
            UIImageView *image4Content;
            if (showNickName)
            {
                UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, cellWidth - 150, 20)];
                label4NickName.text =  [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                label4NickName.font = [UIFont systemFontOfSize:12];
                label4NickName.textColor = [UIColor grayColor];
                [contentView addSubview:label4NickName];
                
                //图片
                image4Content = [[UIImageView alloc]initWithFrame:CGRectMake(99, 20, size.width + 8, size.height + 6)];
                image4Content.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                image4Content.layer.cornerRadius = 6;
                image4Content.layer.borderColor = [UIColor colorWithWhite:.8 alpha:1].CGColor;
                image4Content.layer.borderWidth = 0.5;
                image4Content.clipsToBounds = YES;
                image4Content.contentMode = UIViewContentModeScaleAspectFill;
                [image4Content sd_setImageWithURL:[NSURL URLWithString:[message objectForKey:@"content"]]placeholderImage:[UIImage imageNamed:@"default_image"]];
                [contentView addSubview:image4Content];
            }
            else
            {
                //图片
                image4Content = [[UIImageView alloc]initWithFrame:CGRectMake(99, 0, size.width + 8, size.height + 6)];
                image4Content.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                image4Content.layer.cornerRadius = 6;
                image4Content.layer.borderColor = [UIColor colorWithWhite:.8 alpha:1].CGColor;
                image4Content.layer.borderWidth = 0.5;
                image4Content.clipsToBounds = YES;
                image4Content.contentMode = UIViewContentModeScaleAspectFill;
                [image4Content sd_setImageWithURL:[NSURL URLWithString:[message objectForKey:@"content"]]placeholderImage:[UIImage imageNamed:@"default_image"]];
                [contentView addSubview:image4Content];
            }
            
            if ([[dict4VideoInfo objectForKey:@"thumbName"]length] > 0)
            {
                //本地是否已经存在
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *thumbPath = [documentsDirectory stringByAppendingPathComponent:[dict4VideoInfo objectForKey:@"localThumbName"]];
                NSFileManager *fmgr = [NSFileManager defaultManager];
                BOOL thumbFileExist = [[dict4VideoInfo objectForKey:@"localThumbName"]length] > 0 && [fmgr fileExistsAtPath:thumbPath];

                //图片
                if (thumbFileExist)
                    image4Content.image = [UIImage imageWithContentsOfFile:thumbPath];
                else
                {
                    NSString *thumbFile = [dict4VideoInfo objectForKey:@"thumbName"];
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, thumbFile]];
                    [image4Content sd_setImageWithURL:url];
                }
                [contentView addSubview:image4Content];
            }
        }
        else
        {
            //头像
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[message objectForKey:@"sender"]
                                                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                                                      avatar:[message objectForKey:@"senderAvatar"]
                                                       width:40 height:40];
            view4Avatar.center = CGPointMake(30, 20);
            [self bundleView:view4Avatar
                    WithUser:[message objectForKey:@"sender"]
                    userName:[message objectForKey:@"senderUserName"]
                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                      avatar:[message objectForKey:@"senderAvatar"]
                    isPublic:[[message objectForKey:@"isPublic"]boolValue]
                   tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
             longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
            [contentView addSubview:view4Avatar];
            
            UIImageView *image4Content;
            if (showNickName)
            {
                UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, cellWidth - 150, 20)];
                label4NickName.text =  [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                label4NickName.font = [UIFont systemFontOfSize:12];
                label4NickName.textColor = [UIColor grayColor];
                [contentView addSubview:label4NickName];
                
                //图片
                image4Content = [[UIImageView alloc]initWithFrame:CGRectMake(59, 20, size.width + 8, size.height + 6)];
                image4Content.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                image4Content.backgroundColor = [UIColor blueColor];
                image4Content.layer.cornerRadius = 6;
                image4Content.layer.borderColor = [UIColor colorWithWhite:.8 alpha:1].CGColor;
                image4Content.layer.borderWidth = 0.5;
                image4Content.clipsToBounds = YES;
                image4Content.contentMode = UIViewContentModeScaleAspectFill;
                [image4Content sd_setImageWithURL:[NSURL URLWithString:[message objectForKey:@"content"]]placeholderImage:[UIImage imageNamed:@"default_image"]];
                [contentView addSubview:image4Content];
            }
            else
            {
                //图片
                image4Content = [[UIImageView alloc]initWithFrame:CGRectMake(59, 0, size.width + 8, size.height + 6)];
                image4Content.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                image4Content.layer.cornerRadius = 6;
                image4Content.layer.borderColor = [UIColor colorWithWhite:.8 alpha:1].CGColor;
                image4Content.layer.borderWidth = 0.5;
                image4Content.clipsToBounds = YES;
                image4Content.contentMode = UIViewContentModeScaleAspectFill;
                [image4Content sd_setImageWithURL:[NSURL URLWithString:[message objectForKey:@"content"]]placeholderImage:[UIImage imageNamed:@"default_image"]];
                [contentView addSubview:image4Content];
            }
            
            if ([[dict4VideoInfo objectForKey:@"thumbName"]length] > 0)
            {
                //本地是否已经存在
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *thumbPath = [documentsDirectory stringByAppendingPathComponent:[dict4VideoInfo objectForKey:@"localThumbName"]];
                NSFileManager *fmgr = [NSFileManager defaultManager];
                BOOL thumbFileExist = [[dict4VideoInfo objectForKey:@"localThumbName"]length] > 0 && [fmgr fileExistsAtPath:thumbPath];

                //图片
                if (thumbFileExist)
                    image4Content.image = [UIImage imageWithContentsOfFile:thumbPath];
                else
                {
                    NSString *thumbFile = [dict4VideoInfo objectForKey:@"thumbName"];
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, thumbFile]];
                    [image4Content sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"default_image"]];
                }
                [contentView addSubview:image4Content];
            }
            
            //播放图标
            UIImageView *ImagePlay = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"playVideo"]];
            ImagePlay.center = CGPointMake(CGRectGetMidX(image4Content.bounds), CGRectGetMidY(image4Content.bounds));
            [image4Content addSubview:ImagePlay];
            
            //给图片增加长按手势
            image4Content.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
            objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetView", image4Content, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [image4Content addGestureRecognizer:longPressGest];
            
            //给图片增加轻点手势
            UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
            objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetView", image4Content, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [image4Content addGestureRecognizer:tapGest];
        }
    }
}

@end