//
//  Zee5MenuView.m
//  ZEE5PlayerSDK
//
//  Created by Mani on 18/06/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import "Zee5MenuView.h"
#import "Zee5TableHeaderCell.h"
#import "Zee5PlayerPlugin/Zee5PlayerPlugin-Swift.h"
#import <Zee5PlayerPlugin/ZEE5PlayerSDK.h>

@interface Zee5MenuView()<UITableViewDelegate,UITableViewDataSource>
{
    Boolean isSubList;
}

@end

@implementation Zee5MenuView

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSBundle *bundel = [NSBundle bundleForClass:self.class];
    [self.tblView registerNib:[UINib nibWithNibName:@"Zee5TableHeaderCell" bundle:bundel] forCellReuseIdentifier:@"cell"];
    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:self.insideView.bounds
                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                              cornerRadii:CGSizeMake(25, 25)
                              ];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.insideView.layer.mask = maskLayer;

}

-(void)reloadDataWithObjects:(NSMutableArray<Zee5MenuModel*>*)aryObjs :(Boolean )isSubMenu
{
    isSubList = isSubMenu;
    self.aryObjects = aryObjs;
    [self.tblView reloadData];
    
    self.con_height_tblView.constant = 50 * self.aryObjects.count;

}

- (IBAction)btnClicked:(UIButton *)sender
{
    [self removeFromSuperview];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.aryObjects.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Zee5TableHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Zee5MenuModel *model = self.aryObjects[indexPath.row];
    cell.lblTitle.text = model.title;
    cell.lblTitle.font = [UIFont systemFontOfSize:cell.lblTitle.font.pointSize];
    cell.lblTitle.textColor = [UIColor whiteColor];

    if(isSubList)
    {
        if (model.type == 1 || model.isSelected)
        {
            cell.lblTitle.font = [UIFont boldSystemFontOfSize:cell.lblTitle.font.pointSize];
        }
        if (model.isSelected)
        {
            cell.lblTitle.textColor = [UIColor colorWithRed:234.0/255.0 green:54.0/255.0 blue:143.0/255.0 alpha:1.0];
        }
    }
    else
    {
        
    }
    cell.lblImage.text = model.imageName;
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Zee5MenuModel *model = self.aryObjects[indexPath.row];

    NSLog(@"|** didSelectRowAtIndexPath selectedMenuItem :: %@ **|", model.title);
    [[ZEE5PlayerManager sharedInstance] selectedMenuItem:model];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end



