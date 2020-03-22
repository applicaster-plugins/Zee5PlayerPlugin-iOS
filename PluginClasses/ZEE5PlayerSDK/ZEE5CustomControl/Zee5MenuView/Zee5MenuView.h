//
//  Zee5MenuView.h
//  ZEE5PlayerSDK
//
//  Created by Mani on 18/06/19.
//  Copyright © 2019 ZEE5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Zee5MenuModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Zee5MenuView : UIView

@property (weak, nonatomic) IBOutlet UIView *insideView;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *con_height_tblView;
@property (strong, nonatomic) NSMutableArray<Zee5MenuModel*> *aryObjects;
-(void)reloadDataWithObjects:(NSMutableArray<Zee5MenuModel*>*)aryObjs :(Boolean )isSubMenu;
@end

NS_ASSUME_NONNULL_END
