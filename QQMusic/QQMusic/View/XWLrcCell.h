//
//  XWLrcCell.h
//  QQMusic
//
//  Created by fangjs on 16/9/9.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XWLrcLabel;

@interface XWLrcCell : UITableViewCell

/**歌词 label*/
@property (strong , nonatomic) XWLrcLabel *lrcLabel;

+ (instancetype) initCellWithTableView:(UITableView *) tableView;



@end
