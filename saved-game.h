/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <ob/OBFramework.h>
#import "globaldefines.h"

@interface SavedGame : OBObject

@property (nonatomic) UBYTE difficulty;
@property (nonatomic) ULONG score;
@property (nonatomic) ULONG time;

-(id) initFromData: (OBData *)data;
-(OBData *) serialize;
-(VOID) storeFieldsState: (__strong GameField *[GAME_FIELDS_IN_LINE][GAME_FIELDS_IN_LINE])fields;
-(VOID) loadFieldsState: (__strong GameField *[GAME_FIELDS_IN_LINE][GAME_FIELDS_IN_LINE])fields;
-(VOID) storeNextItems: (BYTE[3])nextItems;
-(VOID) loadNextItems: (BYTE[3])nextItems;

@end
