//
//  Trip.h
//  XMLFlights
//
//  Created by Sergey Kireev on 27.02.14.
//  Copyright (c) 2014 Sergey Kireev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trip : NSObject

@property (nonatomic, strong) NSString *tripDuration;

@property (nonatomic, strong) NSString *takeoffDate;
@property (nonatomic, strong) NSString *takeoffTime;
@property (nonatomic, strong) NSString *takeoffCity;

@property (nonatomic, strong) NSString *landingDate;
@property (nonatomic, strong) NSString *landingTime;
@property (nonatomic, strong) NSString *landingCity;

@property (nonatomic, strong) NSString *flightCarrier;
@property (nonatomic, strong) NSString *flightNumber;
@property (nonatomic, strong) NSString *flightEq;

@property (nonatomic, strong) NSNumber *price;

@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *photoScr;




@end
