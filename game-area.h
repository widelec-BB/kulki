/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <mui/MUIFramework.h>

@class StatusBar;

@interface GameArea : MUIArea

@property (nonatomic, readonly) BOOL firstMoveDone;
@property (nonatomic, readonly) UBYTE difficulty;

-(VOID) startNewGameWithDifficulty: (UBYTE)level;

@end
