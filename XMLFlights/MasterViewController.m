//
//  MasterViewController.m
//  XMLFlights
//
//  Created by Sergey Kireev on 26.02.14.
//  Copyright (c) 2014 Sergey Kireev. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "XMLCustomCell.h"
#import "Trip.h"

@interface MasterViewController () <NSXMLParserDelegate>
{
    NSXMLParser *parser;
    NSMutableArray *trips;
    NSString *element;
    BOOL priceAscending;
    BOOL durationAcsending;

    NSMutableString *currentStringValue;
    
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortByDurationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortByCostButton;

@property (strong, nonatomic) Trip *currentTrip;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)sortByDuration:(UIBarButtonItem *)sender;
- (IBAction)sortByCost:(UIBarButtonItem *)sender;

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadFlights];
    [self.refreshControl addTarget:self
                            action:@selector(loadFlights)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)loadFlights
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:@"http://cleverpumpkin.ru/test/flights0541.xml"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    
    dispatch_queue_t xmlParser = dispatch_queue_create("xml parser", NULL);
    [self.refreshControl beginRefreshing];
    dispatch_async(xmlParser, ^{
        [parser parse];
    });
    

}

#pragma mark - Sorting Table

- (IBAction)sortByCost:(UIBarButtonItem *)sender
{
    priceAscending = !priceAscending;
    [self sortwithKey:@"price" ascending:priceAscending];
    [sender setTitle: priceAscending ? @"Цена ⬇️" : @"Цена ⬆️"];
    [self.sortByDurationButton setTitle:@"В пути"];
}

- (IBAction)sortByDuration:(UIBarButtonItem *)sender
{
    durationAcsending = !durationAcsending;
    [self sortwithKey:@"tripDuration" ascending:durationAcsending];
    [sender setTitle: durationAcsending ? @"В пути ⬇️" : @"В пути ⬆️"];
    [self.sortByCostButton setTitle:@"Цена"];

}

- (void)sortwithKey:(NSString *)sortingKey ascending:(BOOL)ascending
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortingKey ascending:ascending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [trips sortedArrayUsingDescriptors:sortDescriptors];
    
    trips = [NSMutableArray arrayWithArray:sortedArray];
    
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return trips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMLCustomCell *cell = (XMLCustomCell *)[tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    
    cell.priceLabel.text =  [NSString stringWithFormat:@"%@ %@",
                             [[trips objectAtIndex:indexPath.row] price], @" Р."];
    
    cell.durationLabel.text = [[trips objectAtIndex:indexPath.row] tripDuration];
    cell.takeoffCityLabel.text = [[trips objectAtIndex:indexPath.row] takeoffCity];
    cell.flightCarrierLabel.text = [NSString stringWithFormat:@"%@ № рейса: %@",
                                    [[trips objectAtIndex:indexPath.row] flightCarrier],
                                    [[trips objectAtIndex:indexPath.row] flightNumber]];
    
    cell.takeoffCityLabel.text = [NSString stringWithFormat:@"%@ %@ - %@ %@",
                                  [[trips objectAtIndex:indexPath.row] takeoffTime],
                                  [[trips objectAtIndex:indexPath.row] takeoffCity],
                                  [[trips objectAtIndex:indexPath.row] landingTime],
                                  [[trips objectAtIndex:indexPath.row] landingCity]];
    return cell;
}

#pragma mark - XML Parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    element = elementName;
    
    //Result
    if ([elementName isEqualToString:@"result"]) {
        trips = [[NSMutableArray alloc] init];
        return;
    }
    
    // Trip
    if ([elementName isEqualToString:@"trip"]) {
        
        self.currentTrip = [[Trip alloc] init];
        
        //Duration
        NSString *thisDuration = [attributeDict objectForKey:@"duration"];
        if (thisDuration) {
            self.currentTrip.tripDuration = thisDuration;
            thisDuration = nil;
        }
        return;
    }
    
    // Takeoff
    if ([elementName isEqualToString:@"takeoff"]) {
        
        // Date
        NSString *thisDate = [attributeDict objectForKey:@"date"];
        if (thisDate) {
            self.currentTrip.takeoffDate = thisDate;
            thisDate = nil;
        }
        
        //Time
        NSString *thisTime = [attributeDict objectForKey:@"time"];
        if (thisTime) {
            self.currentTrip.takeoffTime = thisTime;
            thisTime = nil;
        }
        
        //City
        NSString *thisCity = [attributeDict objectForKey:@"city"];
        if (thisCity) {
            self.currentTrip.takeoffCity = thisCity;
            thisCity = nil;
        }
        
    }

    // Landing
    if ([elementName isEqualToString:@"landing"]) {
        
        // Date
        NSString *thisDate = [attributeDict objectForKey:@"date"];
        if (thisDate) {
            self.currentTrip.landingDate = thisDate;
            thisDate = nil;
        }
        
        //Time
        NSString *thisTime = [attributeDict objectForKey:@"time"];
        if (thisTime) {
            self.currentTrip.landingTime = thisTime;
            thisTime = nil;
        }
        
        //City
        NSString *thisCity = [attributeDict objectForKey:@"city"];
        if (thisCity) {
            self.currentTrip.landingCity = thisCity;
            thisCity = nil;
        }
    }
    
    // Flight
    if ([elementName isEqualToString:@"flight"]) {
        
        //Carrier
        NSString *thisCarrier = [attributeDict objectForKey:@"carrier"];
        if (thisCarrier) {
            self.currentTrip.flightCarrier = thisCarrier;
            thisCarrier = nil;
        }
        
        //Number
        NSString *thisNumber = [attributeDict objectForKey:@"number"];
        if (thisNumber) {
            self.currentTrip.flightNumber = thisNumber;
            thisNumber = nil;
        }
        
        //Eq
        NSString *thisEq = [attributeDict objectForKey:@"eq"];
        if (thisEq) {
            self.currentTrip.flightEq = thisEq;
            thisEq = nil;
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([element isEqualToString:@"price"]) {
        
        if (!currentStringValue)
            currentStringValue = [[NSMutableString alloc] init];
        [currentStringValue appendString:string];
    }
    element = @"";
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if ([elementName isEqualToString:@"result"] ||
        [elementName isEqualToString:@"takeoff"] ||
        [elementName isEqualToString:@"landing"] ||
        [elementName isEqualToString:@"flight"]) return;
    
    if ([elementName isEqualToString:@"trip"]) {
        [trips addObject:self.currentTrip];
        self.currentTrip = nil;
        return;
    }
    
    if ([elementName isEqualToString:@"price"]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        self.currentTrip.price = [formatter numberFromString:currentStringValue];
        formatter = nil;
    }
    
    currentStringValue = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{

    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[XMLCustomCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Flight"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setSelectedTrip:)]) {
                    [segue.destinationViewController setSelectedTrip:trips[indexPath.row]];
                }
            }
        }
    }
}



@end
