//
//  DetailViewController.m
//  XMLFlights
//
//  Created by Sergey Kireev on 26.02.14.
//  Copyright (c) 2014 Sergey Kireev. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <NSXMLParserDelegate> {
    NSMutableString *currentStringValue;
    NSString *element;
    
    NSXMLParser *parser;
}

@property (weak, nonatomic) IBOutlet UILabel *tripDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *flightNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *takeoffCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *takeoffDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *takeoffTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *landingCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *landingDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *landingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItemLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageActivityIndicator;

@end

@implementation DetailViewController

#pragma mark - XML Parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    element = elementName;
    
    //Photo - Scr
    if ([elementName isEqualToString:@"photo"]) {
        NSString *thisSrc = [attributeDict objectForKey:@"src"];
        if (thisSrc) {
            self.selectedTrip.photoScr = thisSrc;
            thisSrc = nil;
        }
        return;
    }
    
    //Description
    if ([elementName isEqualToString:@"description"]) {
        self.selectedTrip.description = currentStringValue;
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([element isEqualToString:@"description"]) {
        
        if (!currentStringValue)
            currentStringValue = [[NSMutableString alloc] init];
        [currentStringValue appendString:string];
        //element = @"";
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"description"]) {
        self.selectedTrip.description = currentStringValue;
        currentStringValue = nil;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    self.tripDurationLabel.text = self.selectedTrip.tripDuration;
    self.flightNumberLabel.text = self.selectedTrip.flightNumber;
    self.takeoffDateLabel.text = self.selectedTrip.takeoffDate;
    self.takeoffTimeLabel.text = self.selectedTrip.takeoffTime;
    self.takeoffCityLabel.text = self.selectedTrip.takeoffCity;
    self.landingDateLabel.text = self.selectedTrip.landingDate;
    self.landingTimeLabel.text = self.selectedTrip.landingTime;
    self.landingCityLabel.text = self.selectedTrip.landingCity;
    self.navigationItemLabel.title = [NSString stringWithFormat:@"Цена %@ Руб", self.selectedTrip.price];
    self.descriptionLabel.text = self.selectedTrip.description;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *photoURL = [NSURL URLWithString:self.selectedTrip.photoScr];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (![self.selectedTrip.photoScr isEqualToString:@""]) {
        [self.imageActivityIndicator startAnimating];
        NSData *imageData = [NSData dataWithContentsOfURL:photoURL];
        [self.imageActivityIndicator stopAnimating];
        self.imageView.image = [[UIImage alloc] initWithData:imageData];
    }
}

#pragma mark - Managing the detail item


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *stringURL = [NSString stringWithFormat:@"http://cleverpumpkin.ru/test/flights/%@.xml",
                           self.selectedTrip.flightNumber];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:stringURL];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    
    dispatch_queue_t xmlParser = dispatch_queue_create("xml parser", NULL);

    dispatch_async(xmlParser, ^{
        [parser parse];
    });
}


@end
