/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <ob/OBFramework.h>

struct RastPort;

@protocol Theme

@property (nonatomic) OBString *name;

-(VOID) drawItem: (LONG)type on: (struct RastPort *)rp left: (ULONG)x top: (ULONG)y width: (LONG)w height: (LONG)h alpha: (ULONG)a;

@end
