/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <mui/MUIFramework.h>
#import "globaldefines.h"
#import "application.h"
#import "game-field.h"

#if !__has_feature(objc_arc)
#error "Automatic Reference Counting is required"
#endif

#ifdef __GIT_HASH__
__attribute__ ((section(".text.consts"))) const char GitHash[] = "$GIT: "__GIT_HASH__;
#endif

int muiMain(int argc, char *argv[])
{
	Application *mapp = [[Application alloc] initWithExecutableName: argc >= 1 ? argv[0] : NULL];

	[mapp run];

	return RETURN_OK;
}
