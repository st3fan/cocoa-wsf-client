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

@interface WSFRequest (Private)
- (NSURLRequest*) createURLRequest;
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

- (NSString*) createArrayParametersForArray: (NSArray*) array withName: (NSString*) name
{
   NSMutableString* parametersString = [NSMutableString string];

   int i = 0;
   for (id value in array) {
      [parametersString appendFormat: @"&%@.%d=%@", name, i++, value];
   }
   
   return parametersString;
}

- (NSURLRequest*) createURLRequest
{
   NSString* baseQueryString = [NSString stringWithFormat: @"?Version=%@&Action=%@", version_, action_];

   NSMutableString* parametersString = [NSMutableString string];
   for (NSString* key in parameters_) {
      id value = [parameters_ objectForKey: key];
      if ([value respondsToSelector: @selector(objectAtIndex:)]) { // XXX Is there a better idea to find out if this is an array
         [parametersString appendString: [self createArrayParametersForArray: value withName: key]];
      } else {
         [parametersString appendFormat: @"&%@=%@", key, [parameters_ objectForKey: key]];
      }
   }
   
   NSLog(@"ParametersString = %@", parametersString);

   NSURL* requestUrl = [NSURL URLWithString: [parameters_ count] == 0 ? baseQueryString : [NSString
      stringWithFormat: @"%@%@", baseQueryString, parametersString] relativeToURL: endpointURL_];
   return [NSURLRequest requestWithURL: requestUrl];
}

@end
