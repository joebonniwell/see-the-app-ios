//
//  STAXMLParseOperation.m
//  SeeTheApp
//
//  Created by Joe Bonniwell on 5/13/12.
//  Copyright (c) 2012 goVertex LLC. All rights reserved.
//

#import "STAXMLParseOperation.h"

@interface STAXMLParseOperation ()

@property (atomic, retain) NSData *xmlData;
@property (atomic, retain) NSString *countryCode;
@property (atomic, retain) NSMutableSet *appIDs;

@end

@implementation STAXMLParseOperation

- (id)initWithXMLData:(NSData*)argXMLData country:(NSString*)argCountry
{
    if ((self = [super init]))
    {
        @autoreleasepool 
        {
            [self setXmlData:argXMLData];
            [self setCountryCode:argCountry];
            [self setAppIDs:[[[NSMutableSet alloc] init] autorelease]];
        }
    }
    return self;
}

- (void)main
{            
    @autoreleasepool 
    {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[self xmlData]];
        [parser setDelegate:self];
        if([parser parse])
        {
            NSMutableArray *newJSONDownloadURLStrings = [NSMutableArray array];
        
            NSInteger appIDsInLookupString = 0;
            NSMutableString *lookupURLString = [NSMutableString stringWithFormat:@"http://itunes.apple.com/lookup?country=%@&id=", [self countryCode]];
                     
            NSInteger appIDCount = [[self appIDs] count];
                     
            for (int appIDIndex = 0; appIDIndex < appIDCount; appIDIndex++)
            {
                NSNumber *appID = [[self appIDs] anyObject];
                            
                if (appIDsInLookupString == 20)
                {
                    [newJSONDownloadURLStrings addObject:[lookupURLString substringToIndex:([lookupURLString length] - 1)]];
                    lookupURLString = [NSMutableString stringWithFormat:@"http://itunes.apple.com/lookup?country=%@&id=", [self countryCode]];
                    appIDsInLookupString = 0;
                }
                [lookupURLString appendFormat:@"%d,", [appID integerValue]];
                appIDsInLookupString++;
                            
                [[self appIDs] removeObject:appID];
            }
                     
            if (appIDsInLookupString > 0)
                [newJSONDownloadURLStrings addObject:[lookupURLString substringToIndex:([lookupURLString length] - 1)]];
        
        //NSLog(@"End of parsing operation, returning array: %@", newJSONDownloadURLStrings);
        
        
            if ([newJSONDownloadURLStrings count])
                [[NSNotificationCenter defaultCenter] postNotificationName:STAXMLParsingCompleteNotification object:newJSONDownloadURLStrings];
        
        
        }
        else
        {
            #ifdef LOG_XMLParingErrors
            NSLog(@"XML Parsing Error: %@", [[parser parserError] localizedDescription]);
            NSLog(@"XML With Error: %@", [[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding]);
            NSLog(@"XML URL With Error: %@", [argXMLDownloadData objectForKey:STAConnectionURLStringKey]);
            #endif
        }
                 
        [parser release];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"id"])
    {
        if ([[attributeDict allKeys] containsObject:@"im:id"])
        {
            NSInteger appID = [[attributeDict objectForKey:@"im:id"] integerValue];
            [[self appIDs] addObject:[NSNumber numberWithInteger:appID]];
        }
    }
}

#pragma mark - Property Synthesis

@synthesize xmlData;
@synthesize countryCode;
@synthesize appIDs;

@end
