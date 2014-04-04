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

/**
 *  Enum for Apple Keychain Wrapper access mode.
 */
typedef enum _UYLPMAccessMode {
    UYLPMAccessibleWhenUnlocked = 0,
    UYLPMAccessibleAfterFirstUnlock = 1,
    UYLPMAccessibleAlways = 2
} UYLPMAccessMode;

/**
 *  Apple Keychain Wrapper
 */
@interface UYLPasswordManager : NSObject {

}

/**
 *  Set to YES on init. Probably should be private. Used in conjunction with accessMode.
 */
@property (nonatomic,assign) BOOL migrate;

/**
 *  Used to describe the access mode. Has enum above attached.
 */
@property (nonatomic,assign) UYLPMAccessMode accessMode;

/**
 *  The shared instance is allocated the first time it is accessed. All subsequent access to this method returns a reference to the existing instance.
 *
 *  @return Returns a reference to the UYLPasswordManager shared instance.
 */
+ (UYLPasswordManager *)sharedInstance;

/**
 *  Force the shared instance to be released. There should not normally be a reason to do this as the shared instance uses only a small amount of memory.
 */
+ (void)dropShared;


/**
 *  Removes any cached keychain data. Use this method to ensure that all sensitive keychain data is removed from memory. This method is automatically invoked when the device is locked or when the application enters the background.
 */
- (void)purge;

/**
 *  Add an item or update an existing item to the keychain.
 *
 *  @param key        The key value to be stored in the keychain. This is typically the password, or preferably a hash of the actual password that you want to store.
 *  @param identifier The identifier of the keychain item to be stored.
 *  @param group      The keychain access group. This parameter is option and may be set to nil.
 */
- (void)registerKey:(NSString *)key forIdentifier:(NSString *)identifier inGroup:(NSString *)group;

/**
 *  Delete an item from the keychain.
 *
 *  @param identifier The identifier of the keychain item to be deleted.
 *  @param group      The keychain access group. This parameter is option and may be set to nil.
 */
- (void)deleteKeyForIdentifier:(NSString *)identifier inGroup:(NSString *)group;

/**
 *  Search the keychain for the identifier and compare the value of the key. If you do not care about the value of the key you can pass it as nil.
 *
 *  @param key        The value of the key that you want to validate. This parameter can be nil in which case the method returns true if an item is found for the identifier.
 *  @param identifier The identifier of the keychain item to search for.
 *  @param group      The keychain access group. This parameter is option and may be set to nil.
 *
 *  @return A BOOL result for a valid key.
 */
- (BOOL)validKey:(NSString *)key forIdentifier:(NSString *)identifier inGroup:(NSString *)group;

/**
 *  Add an item or update an existing item to the keychain. Equivalent to calling registerKey:forIdentifier:inGroup: with group set to nil.
 *
 *  @param key        The key value to be stored in the keychain. This is typically the password, or preferably a hash of the actual password that you want to store.
 *  @param identifier The identifier of the keychain item to be stored.
 */
- (void)registerKey:(NSString *)key forIdentifier:(NSString *)identifier;

/**
 *  Delete an item from the keychain. Equivalent to calling deleteKeyForIdentifier:inGroup: with group set to nil.
 *
 *  @param identifier The identifier of the keychain item to be deleted.
 */
- (void)deleteKeyForIdentifier:(NSString *)identifier;

/**
 *  Search the keychain for the identifier and compare the value of the key. If you do not care about the value of the key you can pass it as nil. Equivalent to calling validKey:forIdentifier:inGroup: with group set to nil.
 *
 *  @param key        The value of the key that you want to validate. This parameter can be nil in which case the method returns true if an item is found for the identifier.
 *  @param identifier The identifier of the keychain item to search for.
 *
 *  @return A BOOL result for a valid key.
 */
- (BOOL)validKey:(NSString *)key forIdentifier:(NSString *)identifier;

// added by Chad-Skidmore Thanks Chad!! pasted in by Michael Baptist
/**
 *  Get an item from the keychain.
 *
 *  @param identifier The identifier of the keychain item to be stored.
 *  @param group      The keychain access group. This parameter is option and may be set to nil.
 *
 *  @return The value coresponding to the identifier or nil if not valid.
 */
- (NSString *)keyForIdentifier:(NSString *)identifier inGroup:(NSString *)group;

/**
 *  Add an item from the keychain. Equivalent to calling keyForIdentifier:forIdentifier:inGroup: with group set to nil.
 *
 *  @param identifier The identifier of the keychain item to be stored.
 *
 *  @return The value coresponding to the identifier or nil if not valid.
 */
- (NSString *)keyForIdentifier:(NSString *)identifier;

@end
