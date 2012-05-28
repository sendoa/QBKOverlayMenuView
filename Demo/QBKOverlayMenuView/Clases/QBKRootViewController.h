//
//  QBKRootViewController.h
//  QBKOverlayMenuView
//
//  Created by Sendoa Portuondo on 11/05/12.
//  Copyright (c) 2012 Qbikode Solutions, S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBKOverlayMenuView.h"

@interface QBKRootViewController : UIViewController <QBKOverlayMenuViewDelegate>
{
    QBKOverlayMenuView *_qbkOverlayMenu;
}

@end
