/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <proto/icon.h>
#import <proto/dos.h>
#import <string.h>
#import "globaldefines.h"
#import "game-window.h"
#import "application.h"

@implementation Application
{
	OBString *_executablePath;

	MCCAboutbox *_aboutbox;
	GameWindow *_gameWindow;
}

@synthesize executablePath = _executablePath;

-(id) initWithExecutableName: (STRPTR)executableName
{
	if ((self = [super init]))
	{
		[OBLocalizedString openCatalog:@APP_TITLE ".catalog" withLocale:NULL];

		self.title = @APP_TITLE;
		self.author = @APP_AUTHOR;
		self.copyright = @APP_COPYRIGHT;
		self.applicationVersion = @APP_VERSION;

		self.description = OBL(@"Puzzle game", @"Application Description");
		self.base = @APP_TITLE;

		_aboutbox = [[MCCAboutbox alloc] init];
	#ifdef __GIT_HASH__
		_aboutbox.build = @__GIT_HASH__;
	#endif
		_aboutbox.credits = @"\33b%p\33n\n\t" APP_AUTHOR "\n\33b%t\33n\n\tJaca\n\tPhibrizzo\n\tStefkos";

		[self parseWBStartupMessage];
		if (self.executablePath == nil)
		{
			UBYTE buffer[1024];
			BPTR lock;

			strcpy(buffer, "PROGDIR:");
			strncat(buffer, executableName ? executableName : APP_TITLE, sizeof(buffer) - strlen("PROGDIR:") - 1);

			if ((lock = Lock(buffer, SHARED_LOCK)))
			{
				if (NameFromLock(lock, buffer, sizeof(buffer)))
					_executablePath = [OBString stringWithCString: buffer encoding: MIBENUM_SYSTEM];

				UnLock(lock);
			}
		}
		self.diskObject = GetDiskObject((STRPTR)self.executablePath.nativeCString);

		_gameWindow = [[GameWindow alloc] init];

		return self;
	}

	return nil;
}

-(VOID) run
{
	[super instantiateWithWindows: _gameWindow, _aboutbox, nil];

	[super loadENV];

	_gameWindow.open = YES;

	[super run];

	[super saveENV];
	[super saveENVARC];
}

-(VOID) about
{
	_aboutbox.open = YES;
}

-(VOID) setIconified: (BOOL)iconified
{
	if (iconified)
		[_gameWindow pauseTimer];
	else
		[_gameWindow resumeTimer];

	[super setIconified: iconified];
}

-(VOID) dealloc
{
	if (self.diskObject)
		FreeDiskObject(self.diskObject);
}

extern struct WBStartup *_WBenchMsg; // from startup code
-(VOID) parseWBStartupMessage
{
	UBYTE buffer[1024];
	struct WBArg;

	if (!_WBenchMsg || _WBenchMsg->sm_NumArgs < 1)
		return;

	if (NameFromLock(_WBenchMsg->sm_ArgList[0].wa_Lock, buffer, sizeof(buffer)) != 0)
	{
		OBString *fileName = [OBString stringWithCString: _WBenchMsg->sm_ArgList[0].wa_Name encoding: MIBENUM_SYSTEM];
		_executablePath = [[OBString stringWithCString: buffer encoding: MIBENUM_SYSTEM] stringByAddingPathComponent: fileName];
	}
}

@end
