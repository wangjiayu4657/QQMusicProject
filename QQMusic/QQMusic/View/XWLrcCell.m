//
//  XWLrcCell.m
//  QQMusic
//
//  Created by fangjs on 16/9/9.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "XWLrcCell.h"
#import "XWLrcLabel.h"


@implementation XWLrcCell

+ (instancetype)initCellWithTableView:(UITableView *)tableView {
    static NSString *cellID = @"cellID";
    XWLrcCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[XWLrcCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        XWLrcLabel *lrcLabel = [[XWLrcLabel alloc] init];
        [self.contentView addSubview:lrcLabel];
        self.lrcLabel = lrcLabel;
        [lrcLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo (self.contentView);
        }];
        
        self.lrcLabel.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        self.lrcLabel.textColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.lrcLabel.font = [UIFont systemFontOfSize:15];
    }
    return self;
}

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
