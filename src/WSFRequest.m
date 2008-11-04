/*
 * (C) Copyright 2008, Stefan Arentz, Arentz Consulting.
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "WSFRequest.h"
#import "Base64.h"
#import "Mac.h"

@interface WSFRequest (Private)
- (NSString*) formEncodeString: (NSString*) string;
- (NSURLRequest*) createURLRequest;
- (NSString*) generateTimestamp;
- (NSString*) generateSignatureOverParameters: (NSDictionary*) parameters withAccount: (WSFAccount*) account;
- (NSString*) createArrayParametersForArray: (NSArray*) array withName: (NSString*) name;
@end

@implementation WSFRequest

- (id) initWithEndpointURL: (NSURL*) endpointURL version: (NSString*) version action: (NSString*) action
{
   if ((self = [super init]) != nil) {
      endpointURL_ = [endpointURL retain];
      version_ = [version retain];
      action_ = [action retain];
      URLRequest_ = [self createURLRequest];
   }
   return self;
}

- (id) initWithEndpointURL: (NSURL*) endpointURL version: (NSString*) version action: (NSString*) action parameters: (NSDictionary*) parameters
{
   if ((self = [super init]) != nil) {
      endpointURL_ = [endpointURL retain];
      version_ = [version retain];
      action_ = [action retain];
      parameters_ = [parameters retain];
      URLRequest_ = [self createURLRequest];
   }
   return self;
}

+ (id) requestWithEndpointURL: (NSURL*) endpointURL version: (NSString*) version action: (NSString*) action
{
   return [[[self alloc] initWithEndpointURL: endpointURL version: version action: action] autorelease];
}

+ (id) requestWithEndpointURL: (NSURL*) endpointURL version: (NSString*) version action: (NSString*) action parameters: (NSDictionary*) parameters
{
   return [[[self alloc] initWithEndpointURL: endpointURL version: version action: action parameters: parameters] autorelease];
}

- (id) initWithEndpointURL: (NSURL*) endpointURL account: (WSFAccount*) account version: (NSString*) version action: (NSString*) action
{
   if ((self = [super init]) != nil) {
      endpointURL_ = [endpointURL retain];
      version_ = [version retain];
      action_ = [action retain];
      account_ = [account retain];
      URLRequest_ = [self createURLRequest];
   }
   return self;
}

- (id) initWithEndpointURL: (NSURL*) endpointURL account: (WSFAccount*) account version: (NSString*) version action: (NSString*) action parameters: (NSDictionary*) parameters
{
   if ((self = [super init]) != nil) {
      endpointURL_ = [endpointURL retain];
      version_ = [version retain];
      action_ = [action retain];
      parameters_ = [parameters retain];
      account_ = [account retain];
      URLRequest_ = [self createURLRequest];
   }
   return self;
}

+ (id) requestWithEndpointURL: (NSURL*) endpointURL account: (WSFAccount*) account version: (NSString*) version action: (NSString*) action
{
   return [[[self alloc] initWithEndpointURL: endpointURL account: account version: version action: action] autorelease];
}

+ (id) requestWithEndpointURL: (NSURL*) endpointURL account: (WSFAccount*) account version: (NSString*) version action: (NSString*) action parameters: (NSDictionary*) parameters
{
   return [[[self alloc] initWithEndpointURL: endpointURL account: account version: version action: action parameters: parameters] autorelease];
}

- (NSURL*) endpointURL
{
   return endpointURL_;
}

- (NSString*) version
{
   return version_;
}

- (NSString*) action
{
   return action_;
}

- (NSDictionary*) parameters
{
   return parameters_;
}

- (NSURLRequest*) URLRequest
{
   return URLRequest_;
}

@end

@implementation WSFRequest (Private)

- (NSString*) formEncodeString: (NSString*) string
{
   NSString* encoded = (NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) string, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
   return [encoded autorelease];
}

- (NSString*) createArrayParametersForArray: (NSArray*) array withName: (NSString*) name
{
   NSMutableString* parametersString = [NSMutableString string];

   int i = 0;
   for (id value in array) {
      [parametersString appendFormat: @"&%@.%d=%@", name, i++, value];
   }
   
   return parametersString;
}

- (NSString*) generateTimestamp
{
   return @"2008-06-28T17:26:08+00:00"; // TODO
}


- (NSString*) generateSignatureOverParameters: (NSDictionary*) parameters withAccount: (WSFAccount*) account
{
   NSMutableString* data = [NSMutableString string];
   for (NSString* key in [[parameters allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)]) {
      [data appendString: key];
      [data appendString: [parameters objectForKey: key]];
   }
   
   return [Base64 encodeData: [[[Mac macWithAlgorithm: @"SHA1" key: [[account secretAccessKey] dataUsingEncoding: NSASCIIStringEncoding]] updateWithString: data encoding: NSASCIIStringEncoding] digest]];
}

- (NSURLRequest*) createURLRequest
{
   NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
   
   // Add standard parameters
   
   [parameters setObject: version_ forKey: @"Version"];
   [parameters setObject: action_ forKey: @"Action"];

   // Convert the action parameters

   for (NSString* key in parameters_) {
      id value = [parameters_ objectForKey: key];
      if ([value respondsToSelector: @selector(objectAtIndex:)]) { // XXX Is there a better idea to find out if this is an array
         // TODO [parametersString appendString: [self createArrayParametersForArray: value withName: key]];
      } else {
         [parameters setObject: [parameters_ objectForKey: key] forKey: key];
      }
   }
   
   // If the request is authenticated then add the required parameters
   
   if (account_ != nil) {
      [parameters setObject: [account_ accessKey] forKey: @"AccessKey"];
      [parameters setObject: [self generateTimestamp] forKey: @"Timestamp"];
      [parameters setObject: @"1" forKey: @"SignatureVersion"];
      [parameters setObject: [self generateSignatureOverParameters: parameters withAccount: account_] forKey: @"Signature"];
   }
   
   // Generate a URL with the parameters. TODO If the total length of the parameters is above a certain treshold then we create a POST request instead
   
   NSMutableString* queryString = [NSMutableString stringWithString: @"?"];

   for (NSString* key in parameters) {
      if ([queryString length] > 1) {
         [queryString appendString: @"&"];
      }
      [queryString appendString: key];
      [queryString appendString: @"="];
      [queryString appendString: [self formEncodeString: [parameters objectForKey: key]]];
   }
   
   return [NSURLRequest requestWithURL: [NSURL URLWithString: queryString relativeToURL: endpointURL_]];
}

@end
