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

#import "WSFClient.h"
#import "WSFRequest.h"
#import "WSFResponse.h"
#import "WSFError.h"
#import "WSFErrorResponse.h"

#import "NSString+SBJSON.h"

@implementation WSFClient

+ (id) sendSynchronousRequest: (WSFRequest*) request returningResponse: (WSFResponse*) response error: (NSError**) error
{
   return nil;
}

- (id) initWithRequest: (WSFRequest*) request delegate: (id) delegate
{
   if ((self = [super init]) != nil) {
      request_ = [request retain];
      delegate_ = [delegate retain];
      json_ = [[NSMutableData data] retain];
      connection_ = [[NSURLConnection alloc] initWithRequest: [request_ URLRequest] delegate: self];
   }
   return self;
}

- (id) initWithRequest: (WSFRequest*) request delegate: (id) delegate startImmediately: (BOOL) startImmediately
{
   if ((self = [super init]) != nil) {
      request_ = request;
      delegate_ = delegate;
      json_ = [[NSMutableData data] retain];
      connection_ = [[NSURLConnection alloc] initWithRequest: [request_ URLRequest] delegate: self startImmediately: startImmediately];
   }
   return self;
}

- (void) dealloc
{
   [request_ release];
   [connection_ release];
   [super dealloc];
}

+ (id) clientWithRequest: (WSFRequest*) request delegate: (id) delegate
{
   return [[(WSFClient*) [self alloc] initWithRequest: request delegate: delegate] autorelease];
}

+ (id) clientWithRequest: (WSFRequest*) request delegate: (id) delegate startImmediately: (BOOL) startImmediately
{
   return [[(WSFClient*) [self alloc] initWithRequest: request delegate: delegate startImmediately: startImmediately] autorelease];
}

- (void) start
{
   [connection_ start];
}

- (void) cancel
{
   [connection_ cancel];
}

//

- (void) connection: (NSURLConnection*) connection didReceiveResponse: (NSURLResponse*) response
{
#if defined(WSFCLIENT_DEBUG)
      NSLog(@"connection: %@ didReceiveResponse: %@", connection, response);
#endif

   [json_ setLength: 0];
}

- (void) connection: (NSURLConnection*) connection didReceiveData: (NSData*) data
{
#if defined(WSFCLIENT_DEBUG)
      NSLog(@"connection: %@ didReceiveData: %@", connection, data);
#endif
   
   [json_ appendData: data];
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection
{
#if defined(WSFCLIENT_DEBUG)
      NSLog(@"connectionDidFinishLoading: %@", connection);
#endif
   
   NSString* json = [[[NSString alloc] initWithData: json_ encoding: NSUTF8StringEncoding] autorelease];
   NSLog(@"JSON = %@", json);
   NSDictionary* data = [json JSONValue];
   
   if ([data objectForKey: @"errors"]) {
      if ([delegate_ respondsToSelector: @selector(client:didReceiveErrorResponse:)]) {
         NSMutableArray* errors = [NSMutableArray array];
         for (NSDictionary* error in [data objectForKey: @"errors"]) {
            [errors addObject: [WSFError errorWithCode: [[error objectForKey: @"code"] intValue] message: [error objectForKey: @"description"]]];
         }
         WSFErrorResponse* errorResponse = [[WSFErrorResponse alloc] initWithRequestId: [data objectForKey: @"webServiceCallId"] errors: errors];
         @try {
            [delegate_ client: self didReceiveErrorResponse: errorResponse];
         } @catch (id e) {
            NSLog(@"WSFClient %@ ignored exception thrown from delegate's client:didReceiveErrorResponse: %@", e);
         } @finally {
            [errorResponse release];
         }
      }
   } else if ([data objectForKey: @"response"]) {
      if ([delegate_ respondsToSelector: @selector(client:didReceiveResponse:)]) {
         WSFResponse* response = [[WSFResponse alloc] initWithRequestId: [data objectForKey: @"webServiceCallId"] data: [data objectForKey: @"response"]];
         @try {
            [delegate_ client: self didReceiveResponse: response];
         } @catch (id e) {
            NSLog(@"WSFClient %@ ignored exception thrown from delegate's client:didReceiveResponse: %@", e);
         } @finally {
            [response release];
         }
      }
   }
}

- (void) connection: (NSURLConnection*) connection didFailWithError: (NSError*) error
{
#if defined(WSFCLIENT_DEBUG)
      NSLog(@"connection: %@ didFailWithError: %@", connection, error);
#endif
   
   if ([delegate_ respondsToSelector: @selector(client:didFailWithError:)]) {
      @try {
         [delegate_ client: self didFailWithError: error];
      } @catch (id e) {
         NSLog(@"WSFClient %@ ignored exception thrown from delegate's client:didFailWithError: %@", e);
      }
   }
}

@end
