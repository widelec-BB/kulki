/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <ob/OBFramework.h>
#import "theme.h"

@interface ThemeInternal : OBObject <Theme>

-(VOID) drawItem: (LONG)type on: (struct RastPort *)rp left: (ULONG)x top: (ULONG)y width: (LONG)w height: (LONG)h alpha: (ULONG)a;

@end
