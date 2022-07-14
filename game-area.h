/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <mui/MUIFramework.h>

@class StatusBar;
@class SavedGame;

@interface GameArea : MUIArea

@property (nonatomic, readonly) BOOL firstMoveDone;
@property (nonatomic) UBYTE difficulty;
@property (nonatomic) ULONG score;

-(VOID) startNewGameWithDifficulty: (UBYTE)level;
-(VOID) restoreFieldsStateFrom: (SavedGame *)sg;
-(SavedGame *) saveGame;
-(VOID) loadGame: (SavedGame *)sg;

@end
