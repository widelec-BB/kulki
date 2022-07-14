/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <mui/MUIFramework.h>

@class SavedGame;

@interface GameWindow : MUIWindow

@property (nonatomic) SavedGame *prevoiusGameState;

-(BOOL) startNewGame;
-(VOID) gameOver;
-(VOID) pauseTimer;
-(VOID) resumeTimer;
-(VOID) updateScore;
-(VOID) setNextItems: (BYTE[3])nextItems;

@end
