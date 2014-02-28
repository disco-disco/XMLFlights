//
//  DetailViewController.h
//  XMLFlights
//
//  Created by Sergey Kireev on 26.02.14.
//  Copyright (c) 2014 Sergey Kireev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface DetailViewController : UIViewController

@property (nonatomic, strong) Trip *selectedTrip;

@end
