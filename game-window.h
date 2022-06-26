/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <mui/MUIFramework.h>

@interface GameWindow : MUIWindow

-(BOOL) startNewGame;
-(VOID) gameOver;
-(VOID) pauseTimer;
-(VOID) resumeTimer;
-(VOID) addToScore: (ULONG) points;
-(VOID) setNextItems: (LONG[3])nextItems;

@end
