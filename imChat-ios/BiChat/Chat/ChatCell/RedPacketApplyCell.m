//
//  RedPacketApplyCell.m
//  BiChat
//
//  Created by Admin on 2018/6/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "RedPacketApplyCell.h"

@implementation RedPacketApplyCell

//返回一条系统消息cell的高度
+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    NSString *strMessage = [BiChatGlobal getMessageReadableString:message groupProperty:groupProperty];
    strMessage = [strMessage stringByAppendingString:LLSTR(@"203012")];
    CGRect rect = [strMessage boundingRectWithSize:CGSizeMake(cellWidth - 40, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                           context:nil];
    return rect.size.height + 17;
}

//渲染一条系统消息
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
    //系统消息的内容
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    NSString *strMessage = [BiChatGlobal getMessageReadableString:message groupProperty:groupProperty];
    strMessage = [strMessage stringByAppendingString:LLSTR(@"203012")];
    CGRect rect = [strMessage boundingRectWithSize:CGSizeMake(cellWidth - 40, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                           context:nil];
    
    UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake((cellWidth - rect.size.width - 20) / 2, 0, (int)rect.size.width + 20, (int)rect.size.height + 7)];
    label4Hint.text = strMessage;
    label4Hint.font = [UIFont systemFontOfSize:12];
    label4Hint.textColor = [UIColor lightGrayColor];
    //label4Hint.backgroundColor = [UIColor colorWithWhite:.78 alpha:1];
    label4Hint.textAlignment = NSTextAlignmentCenter;
    label4Hint.layer.cornerRadius = 5;
    label4Hint.layer.borderWidth = 0;
    label4Hint.layer.borderColor = [UIColor colorWithWhite:.78 alpha:1].CGColor;
    label4Hint.clipsToBounds = YES;
    label4Hint.numberOfLines = 0;
    [contentView addSubview:label4Hint];
    
    //后面3个汉字是蓝色
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4Hint.text];
    [str addAttribute:NSForegroundColorAttributeName value:THEME_DARKBLUE range:NSMakeRange(strMessage.length - LLSTR(@"203012").length, LLSTR(@"203012").length)];
    label4Hint.attributedText = str;
    
    if (!inMultiSelectMode)
    {
        //给消息增加长按手势
        label4Hint.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
        objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(longPressGest, @"targetView", label4Hint, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
        [label4Hint addGestureRecognizer:longPressGest];
        
        //给消息增加点击手势
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
        objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(tapGest, @"targetView", label4Hint, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
        [label4Hint addGestureRecognizer:tapGest];
    }
}

@end
