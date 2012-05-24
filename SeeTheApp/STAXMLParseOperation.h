//
//  STAXMLParseOperation.h
//  SeeTheApp
//
//  Created by Joe Bonniwell on 5/13/12.
//  Copyright (c) 2012 goVertex LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STAXMLParseOperation : NSOperation <NSXMLParserDelegate>

- (id)initWithXMLData:(NSData*)argXMLData country:(NSString*)argCountry;

@end
