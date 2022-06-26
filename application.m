/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <proto/icon.h>
#import "globaldefines.h"
#import "game-window.h"
#import "application.h"

@implementation Application
{
	MCCAboutbox *_aboutbox;
	GameWindow *_gameWindow;
}

-(id) init
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
		self.diskObject = GetDiskObject("PROGDIR:" APP_TITLE);

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

@end
