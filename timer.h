/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <mui/MUIFramework.h>

@interface Timer : MUIGroup

-(VOID) start;
-(VOID) startWithDiff: (ULONG)diff;
-(VOID) stop;
-(VOID) pause;
-(VOID) resume;
-(ULONG) time;

@end
