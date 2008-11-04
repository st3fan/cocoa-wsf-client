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

#import "WSFAccount.h"

@implementation WSFAccount

- (id) initWithAccessKey: (NSString*) accessKey secretAccessKey: (NSString*) secretAccessKey
{
   if ((self = [super init]) != nil) {
      accessKey_ = [accessKey retain];
      secretAccessKey_ = [secretAccessKey retain];
   }
   return self;
}

+ (id) accountWithAccessKey: (NSString*) accessKey secretAccessKey: (NSString*) secretAccessKey
{
   return [[[self alloc] initWithAccessKey: accessKey secretAccessKey: secretAccessKey] autorelease];
}

- (NSString*) accessKey
{
   return accessKey_;
}

- (NSString*) secretAccessKey
{
   return secretAccessKey_;
}

@end