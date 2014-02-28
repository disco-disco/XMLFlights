//
//  XMLCustomCellViewController.h
//  XMLFlights
//
//  Created by Sergey Kireev on 27.02.14.
//  Copyright (c) 2014 Sergey Kireev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLCustomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *takeoffCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *flightCarrierLabel;

@end
