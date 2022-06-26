/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <mui/MUIFramework.h>

@interface HighScores : MUIArea

-(BOOL) checkQualification: (ULONG)score;
-(VOID) addEntry: (OBString *)name score: (OBNumber *)score;

@end
