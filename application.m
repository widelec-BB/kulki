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

-(id) init
{
	if ((self = [super init]))
	{
		[OBLocalizedString openCatalog:@APP_TITLE ".catalog" withLocale:NULL];

		if (!(_executablePath = [Application getExecutableName]))
			return nil;

		self.title = @APP_TITLE;
		self.author = @APP_AUTHOR;
		self.copyright = @APP_COPYRIGHT;
		self.applicationVersion = @APP_VERSION;
		self.description = OBL(@"Puzzle game", @"Application Description");
		self.base = @APP_TITLE;
		self.diskObject = GetDiskObject((STRPTR)self.executablePath.nativeCString);

		_aboutbox = [[MCCAboutbox alloc] init];
	#ifdef __GIT_HASH__
		_aboutbox.build = @__GIT_HASH__;
	#endif
		_aboutbox.credits = @"\33b%p\33n\n\t" APP_AUTHOR "\n\33b%t\33n\n\tJaca\n\tPhibrizzo\n\tStefkos";

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
	[_gameWindow loadGame];

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
+(OBString *) getExecutableName
{
	OBString *executablePath = nil;
	UBYTE programName[PATH_MAX];
	struct WBArg;

	if (_WBenchMsg && _WBenchMsg->sm_NumArgs >= 1 && NameFromLock(_WBenchMsg->sm_ArgList[0].wa_Lock, programName, sizeof(programName)) != 0)
	{
		OBString *fileName = [OBString stringWithCString: _WBenchMsg->sm_ArgList[0].wa_Name encoding: MIBENUM_SYSTEM];
		executablePath = [[OBString stringWithCString: programName encoding: MIBENUM_SYSTEM] stringByAddingPathComponent: fileName];
	}
	else
	{
		LONG res = GetProgramName(programName, sizeof(programName));
		if (res == 0 || !strstr(programName, ":"))
		{
			UBYTE progdirPath[PATH_MAX] = {'P', 'R', 'O', 'G', 'D', 'I', 'R', ':', '\0'};
			BPTR lock;

			if (res != 0)
				AddPart(progdirPath, res ? FilePart(programName) : APP_TITLE, sizeof(progdirPath));

			if ((lock = Lock(progdirPath, SHARED_LOCK)))
			{
				if (NameFromLock(lock, progdirPath, sizeof(progdirPath)))
					executablePath = [OBString stringWithCString: progdirPath encoding: MIBENUM_SYSTEM];

				UnLock(lock);
			}
		}
		else // GetProgramName() returned absolute path, we can use it as is.
			executablePath = [OBString stringWithCString: programName encoding: MIBENUM_SYSTEM];
	}
	return executablePath;
}

@end
