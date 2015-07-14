//
//  DetailViewController.h
//  Kfz-Kennzeichen
//
//  Created by Gisbert Amm on 14.07.15.
//  Copyright (c) 2015 Gisbert Amm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

