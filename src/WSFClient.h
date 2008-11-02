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

#import <Cocoa/Cocoa.h>

@class WSFRequest;
@class WSFResponse;
@class WSFErrorResponse;

@interface WSFClient : NSObject {
   WSFRequest* request_;
   NSURLConnection* connection_;
   id delegate_;
   NSMutableData* json_;
   BOOL debug_;
}

+ (id) sendSynchronousRequest: (WSFRequest*) request returningResponse: (WSFResponse*) response error: (NSError**) error;

- (id) initWithRequest: (WSFRequest*) request delegate: (id) delegate;
- (id) initWithRequest: (WSFRequest*) request delegate: (id) delegate startImmediately: (BOOL) startImmediately;
- (void) start;
- (void) cancel;

+ (id) clientWithRequest: (WSFRequest*) request delegate: (id) delegate;
+ (id) clientWithRequest: (WSFRequest*) request delegate: (id) delegate startImmediately: (BOOL) startImmediately;

@end

@interface NSObject (WSFClientDelegate)
- (void) client: (WSFClient*) client didFailWithError: (NSError*) error;
- (void) client: (WSFClient*) client didReceiveResponse: (WSFResponse*) response;
- (void) client: (WSFClient*) client didReceiveErrorResponse: (WSFErrorResponse*) errorResponse;
@end
