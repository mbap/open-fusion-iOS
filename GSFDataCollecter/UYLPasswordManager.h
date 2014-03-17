//
//  PasswordManager.h
//  
//  Created by Keith Harrison on 23-May-2011 http://useyourloaf.com
//  Copyright (c) 2012 Keith Harrison. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//
//  Neither the name of Keith Harrison nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ''AS IS'' AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 


#import <Foundation/Foundation.h>

typedef enum _UYLPMAccessMode {
    UYLPMAccessibleWhenUnlocked = 0,
    UYLPMAccessibleAfterFirstUnlock = 1,
    UYLPMAccessibleAlways = 2
} UYLPMAccessMode;

@interface UYLPasswordManager : NSObject {

}

@property (nonatomic,assign) BOOL migrate;
@property (nonatomic,assign) UYLPMAccessMode accessMode;

+ (UYLPasswordManager *)sharedInstance;
+ (void)dropShared;

- (void)purge;

- (void)registerKey:(NSString *)key forIdentifier:(NSString *)identifier inGroup:(NSString *)group;
- (void)deleteKeyForIdentifier:(NSString *)identifier inGroup:(NSString *)group;
- (BOOL)validKey:(NSString *)key forIdentifier:(NSString *)identifier inGroup:(NSString *)group;

- (void)registerKey:(NSString *)key forIdentifier:(NSString *)identifier;
- (void)deleteKeyForIdentifier:(NSString *)identifier;
- (BOOL)validKey:(NSString *)key forIdentifier:(NSString *)identifier;

// added by Chad-Skidmore Thanks Chad!! pasted in by Michael Baptist
- (NSString *)keyForIdentifier:(NSString *)identifier inGroup:(NSString *)group;
- (NSString *)keyForIdentifier:(NSString *)identifier;

@end
