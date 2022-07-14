/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <mui/MUIFramework.h>
#import <proto/dos.h>
#import <libraries/charsets.h>
#import "globaldefines.h"
#import "game-area.h"
#import "application.h"
#import "next-items.h"
#import "timer.h"
#import "title-image.h"
#import "picture.h"
#import "highscores.h"
#import "theme.h"
#import "theme-internal.h"
#import "theme-gfx.h"
#import "game-field.h"
#import "game-window.h"

enum MenuOptions
{
	MenuDifficulty5 = 5,
	MenuDifficulty7 = 7,
	MenuDifficulty9 = 9,

	MenuNewGame = 20,
	MenuMUIPreferences,
	MenuAbout,
	MenuAboutMUI,
	MenuQuit,

	MenuThemeInternal = 100,
};

@implementation GameWindow
{
	MUIGroup *_gamePager, *_statusBarPager;
	MUIText *_scoreTxt;
	MUIString *_nameStr;
	MUIMenu *_themeMenu;
	MUIMenuitem *_difficultyMenuItems[3];

	GameArea *_ga;
	HighScores *_hs;
	Timer *_timer;
	NextItems *_nextItems;

	OBArray *_availableThemes;
}

-(id) init
{
	if ((self = [super init]))
	{
		MUIButton *start = [MUIButton buttonWithLabel: OBL(@"Start New Game", @"Start button label")];
		MUILabel *scoreLabel = [MUILabel label: OBL(@"Score:", @"Label for string with score result")];
		MUILabel *nextItemsLabel = [MUILabel label2: OBL(@"Next Colors:", @"Label for next items display")];
		TitleImage *titleImg = [[TitleImage alloc] initWithPicture: [[Picture alloc] initFromFile: @"PROGDIR:gfx/title"]];
		TitleImage *congratsImg = [[TitleImage alloc] initWithPicture: [[Picture alloc] initFromFile: @"PROGDIR:gfx/congrats"]];
		MUIGroup *statusBar, *highscoresGroup;
		MUIText *congratulations;
		MUIButton *saveButton;
		LONG i;

		start.weight = 1;

		_scoreTxt = [MUIText textWithContents: [OBString stringWithFormat: OBL(@"%u points", @"Score format template for status bar"), 0]];
		_ga = [[GameArea alloc] init];
		_timer = [[Timer alloc] init];
		_nextItems = [[NextItems alloc] init];
		_availableThemes = [self scanAvailableThemes];

		self.objectID = MAKE_ID('G', 'W', 'I', 'N');
		self.title = @APP_TITLE;
		self.rootObject = [MUIGroup groupWithObjects:
			(statusBar = [MUIGroup horizontalGroupWithObjects:
				(_statusBarPager = [MUIGroup groupWithPages:
					[MUIGroup horizontalGroupWithObjects: [MUIRectangle rectangleWithWeight: 10], start, [MUIRectangle rectangleWithWeight: 10], nil],
					[MUIGroup horizontalGroupWithObjects: [MUIRectangle rectangleWithWeight: 2], nextItemsLabel, _nextItems, [MUIRectangle rectangleWithWeight: 10], nil],
				nil]),
				[MUIGroup groupWithObjects:
					[MUIRectangle rectangle],
					[MUIGroup horizontalGroupWithObjects:
						[MUIRectangle rectangle],
						scoreLabel,
						_scoreTxt,
						_timer,
					nil],
					[MUIRectangle rectangle],
				nil],
			nil]),
			(_gamePager = [MUIGroup groupWithPages:
				[MUIGroup groupWithObjects:
					[MUIRectangle rectangleWithWeight: 5],
					[MUIGroup horizontalGroupWithObjects:
						titleImg,
						[MUIGroup groupWithObjects:
							[MUIRectangle rectangle],
							(highscoresGroup = [MUIGroup groupWithObjects:
								(_hs = [[HighScores alloc] init]),
							nil]),
							[MUIRectangle rectangle],
						nil],
					nil],
					[MUIRectangle rectangleWithWeight: 5],
				nil],
				_ga,
				[MUIGroup groupWithObjects:
					[MUIRectangle rectangleWithWeight: 1],
					[MUIGroup horizontalGroupWithObjects:
						[MUIRectangle rectangleWithWeight: 1],
						congratsImg,
						[MUIRectangle rectangleWithWeight: 1],
					nil],
					[MUIGroup horizontalGroupWithObjects:
						[MUIRectangle rectangle],
						(congratulations = [MUIText textWithContents: OBL(@"Congratulations!", @"Message when player got highscore")]),
						[MUIRectangle rectangle],
					nil],
					[MUIGroup horizontalGroupWithObjects:
						[MUILabel label2: OBL(@"Enter your name:", @"Message when player got highscore")],
						(_nameStr = [MUIString string]),
					nil],
					[MUIGroup horizontalGroupWithObjects:
						[MUIRectangle rectangle],
						(saveButton = [MUIButton buttonWithLabel: OBL(@"Save", @"Save new highscore entry")]),
						[MUIRectangle rectangle],
					nil],
					[MUIRectangle rectangleWithWeight: 1],
				nil],
			nil]),
		nil];
		self.screenTitle = @APP_SCREEN_TITLE;
		self.menustrip = [[MUIMenustrip alloc] initWithObjects:
			[[MUIMenu alloc] initWithTitle: @APP_TITLE objects:
				[MUIMenuitem itemWithTitle: OBL(@"Start New Game", @"Menu entry label for starting new game") shortcut: OBL(@"N", @"Menu new game entry shortcut") userData: MenuNewGame],
				[MUIMenuitem barItem],
				[MUIMenuitem itemWithTitle: OBL(@"About...", @"Menu About") shortcut: OBL(@"?", @"Menu About entry shortcut") userData: MenuAbout],
				[MUIMenuitem itemWithTitle: OBL(@"About MUI...", @"Menu About MUI") shortcut: nil userData: MenuAboutMUI],
				[MUIMenuitem barItem],
				[MUIMenuitem itemWithTitle: OBL(@"Quit", @"Menu quit") shortcut: OBL(@"Q", @"Menu quit shortcut") userData: MenuQuit],
			nil],
			[[MUIMenu alloc] initWithTitle: OBL(@"Settings", @"Menu entry label for settings") objects:
				[[MUIMenu alloc] initWithTitle: OBL(@"Difficulty...", @"Menu entry for difficulty settings") objects:
					(_difficultyMenuItems[0] = [MUIMenuitem checkmarkItemWithTitle: OBL(@"5 colors", @"Menu label difficulty 5 colors") shortcut: nil userData: MenuDifficulty5 checked: NO]),
					(_difficultyMenuItems[1] = [MUIMenuitem checkmarkItemWithTitle: OBL(@"7 colors", @"Menu label difficulty 7 colors") shortcut: nil userData: MenuDifficulty7 checked: NO]),
					(_difficultyMenuItems[2] = [MUIMenuitem checkmarkItemWithTitle: OBL(@"9 colors", @"Menu label difficulty 9 colors") shortcut: nil userData: MenuDifficulty9 checked: NO]),
				nil],
				(_themeMenu = [[MUIMenu alloc] initWithTitle: OBL(@"Theme...", @"Menu entry label for themes selection") objects: nil, nil]),
				[MUIMenuitem barItem],
				[MUIMenuitem itemWithTitle: OBL(@"MUI...", @"Menu MUI Preferences") shortcut: nil userData: MenuMUIPreferences],
			nil],
		nil];

		_difficultyMenuItems[0].objectID = MAKE_ID('L', 'V', 'L', MenuDifficulty5);
		_difficultyMenuItems[1].objectID = MAKE_ID('L', 'V', 'L', MenuDifficulty7);
		_difficultyMenuItems[2].objectID = MAKE_ID('L', 'V', 'L', MenuDifficulty9);

		for (i = 0; i < _availableThemes.count; i++)
		{
			id<Theme>ms = [_availableThemes objectAtIndex: i];
			MUIMenuitem *mi = [MUIMenuitem checkmarkItemWithTitle: ms.name shortcut: nil userData: MenuThemeInternal + i checked: NO];
			[_themeMenu addObject: mi];
		}

		statusBar.frame = MUIV_Frame_Group;

		[start notify: @selector(selected) trigger: NO performSelector: @selector(startNewGame) withTarget: self];
		[saveButton notify: @selector(selected) trigger: NO performSelector: @selector(saveHighScore) withTarget: self];
		[_nameStr notify: @selector(acknowledge) performSelector: @selector(saveHighScore) withTarget: self];

		highscoresGroup.frameTitle = OBL(@"Highscores", @"Highscores list group title");
		highscoresGroup.frame = MUIV_Frame_Group;

		congratulations.preParse = @"\33c\33b";

		return self;
	}
	return nil;
}

-(BOOL) startNewGame
{
	LONG level = 5;

	if (_difficultyMenuItems[1].checked)
		level = 7;
	else if (_difficultyMenuItems[2].checked)
		level = 9;

	[self changeDifficultyLevel: level];

	return YES;
}

-(VOID) gameOver
{
	[_timer stop];

	_statusBarPager.activePage = 0;

	if ([_hs checkQualification: _ga.score])
		_gamePager.activePage = 2;
	else
		_gamePager.activePage = 0;
}

-(VOID) saveHighScore
{
	[_hs addEntry: _nameStr.contents score: [OBNumber numberWithUnsignedLong: _ga.score]];

	[(Application *)self.applicationObject saveENV];
	[(Application *)self.applicationObject saveENVARC];

	_gamePager.activePage = 0;
}

-(VOID) updateScore
{
	_scoreTxt.contents = [OBString stringWithFormat: OBL(@"%u points", @"Score format template for status bar"), _ga.score];
}

-(VOID) setNextItems: (LONG[3])nextItems
{
	[_nextItems setNextItems: nextItems];
}

-(VOID) setCloseRequest: (BOOL)closerequest
{
	[super setCloseRequest: closerequest];

	if (!closerequest)
		return;

	if (_ga.firstMoveDone)
	{
		MUIRequest *req = [MUIRequest requestWithTitle: OBL(@"Are you sure?", @"Quit game confirmation requester title")
		   message: OBL(@"\33cAre you sure you want to quit?\nAll progress will be lost.", @"Quit game confirmation requester message")
		   buttons: [OBArray arrayWithObjects: OBL(@"_Yes", @"Quit game confirmation"), OBL(@"_No", @"Quit game cancel button label"), nil]];
		if ([req requestWithWindow: self] != 1)
			return;
	}
	[self.applicationObject quit];
}

-(VOID) checkDifficultyLevel: (LONG)level
{
	LONG i;

	for (i = 0; i < 3; i++)
		_difficultyMenuItems[i].checked = NO;

	switch (level)
	{
		case MenuDifficulty5:
			_difficultyMenuItems[0].checked = YES;
		break;

		case MenuDifficulty7:
			_difficultyMenuItems[1].checked = YES;
		break;

		case MenuDifficulty9:
			_difficultyMenuItems[2].checked = YES;
		break;
	}
}

-(VOID) changeDifficultyLevel: (LONG)level
{
	if (_ga.firstMoveDone)
	{
		MUIRequest *req = [MUIRequest requestWithTitle: OBL(@"Are you sure?", @"New game start confirmation requester title")
		   message: OBL(@"\33cAre you sure you want to start new game?\nAll progress will be lost.", @"New game start confirmation requester message")
		   buttons: [OBArray arrayWithObjects: OBL(@"_Yes", @"New game start confirmation"), OBL(@"_No", @"New game start cancel button"), nil]];
		if ([req requestWithWindow: self] != 1)
		{
			[self checkDifficultyLevel: _ga.difficulty];
			return;
		}
	}

	[self checkDifficultyLevel: level];
	[_ga startNewGameWithDifficulty: level];

	[_timer start];

	_statusBarPager.activePage = 1;
	_gamePager.activePage = 1;
}

-(VOID) setMenuAction: (ULONG)menuAction
{
	if (menuAction >= MenuThemeInternal)
	{
		[GameField setActiveTheme: [_availableThemes objectAtIndex: menuAction - MenuThemeInternal]];

		[_ga redraw: MADF_DRAWOBJECT];
		[_nextItems redraw: MADF_DRAWOBJECT];

		for (MUIMenuitem *mi in _themeMenu)
			mi.checked = mi.userData == menuAction;

		return;
	}

	switch (menuAction)
	{
		case MenuNewGame:
			[self startNewGame];
		break;

		case MenuMUIPreferences:
			[self.applicationObject openConfigWindow: 0 classid: nil];
		break;

		case MenuAbout:
			[(Application *)self.applicationObject about];
		break;

		case MenuAboutMUI:
			[self.applicationObject aboutMUI: self];
		break;

		case MenuQuit:
			[self setCloseRequest: YES];
		break;

		case MenuDifficulty5:
		case MenuDifficulty7:
		case MenuDifficulty9:
			[self changeDifficultyLevel: menuAction];
		break;
	}
}

-(VOID) pauseTimer
{
	[_timer pause];
}

-(VOID) resumeTimer
{
	[_timer resume];
}

-(IPTR) export: (MUIDataspace *)dataspace
{
	OBString *selectedTheme = nil;

	for (MUIMenuitem *mi in _themeMenu)
	{
		if (mi.checked && mi.userData > MenuThemeInternal) // do not save internal theme name, it's localized, besides it is anyway the default one.
			selectedTheme = mi.title;
	}
	if (selectedTheme != nil)
		[dataspace setData: [selectedTheme dataWithEncoding: MIBENUM_UTF_8] forID: MAKE_ID('T', 'H', 'E', 'M')];

	[GameField setActiveTheme: nil]; // allow active theme object to be released

	return [super export: dataspace];
}

-(IPTR) import: (MUIDataspace *)dataspace
{
	LONG i;
	OBString *theme = [OBString stringFromData: [dataspace dataForID: MAKE_ID('T', 'H', 'E', 'M')] encoding: MIBENUM_UTF_8];
	id <Theme> activeTheme = [_availableThemes objectAtIndex: 0]; // default to internal theme which is always first one.

	for (i = 1; i < _availableThemes.count; i++)
	{
		id <Theme> t = [_availableThemes objectAtIndex: i];
		if ([t.name isEqualToString: theme])
			activeTheme = t;
	}

	[GameField setActiveTheme: activeTheme];

	for (MUIMenuitem *mi in _themeMenu)
		mi.checked = [mi.title isEqualToString: activeTheme.name];

	// default to easy difficulty
	if (!_difficultyMenuItems[0].checked && !_difficultyMenuItems[1].checked && !_difficultyMenuItems[2].checked)
		_difficultyMenuItems[0].checked = YES;

	return [super import: dataspace];
}

-(OBArray *) scanAvailableThemes
{
	OBMutableArray *themes = [OBMutableArray arrayWithCapacity: 10];
	BOOL success = NO;
	struct FileInfoBlock *fib;
	OBString *drawerPath = @"PROGDIR:gfx";

	if ((fib = AllocDosObject(DOS_FIB, NULL)))
	{
		BPTR lock;
		if ((lock = Lock(drawerPath.cString, SHARED_LOCK)))
		{
			if (Examine(lock, fib))
			{
				while (ExNext(lock, fib))
				{
					if (fib->fib_DirEntryType < 0)
					{
						OBString *fileName = [OBString stringWithCString: fib->fib_FileName encoding: MIBENUM_SYSTEM];
						OBString *name = [fileName substringToIndex: fileName.length - 3];
						ThemeGfx *ms = [[ThemeGfx alloc] initWithName: name fromFile: [drawerPath stringByAddingPathComponent: fileName]];
						if (ms)
							[themes addObject: ms];
					}
				}
				if (IoErr() == ERROR_NO_MORE_ENTRIES)
					success = YES;
			}
			UnLock(lock);
		}
		FreeDosObject(DOS_FIB, fib);
	}

	[themes sortUsingSelector: @selector(compareNames:)];
	[themes insertObject: [[ThemeInternal alloc] init] atIndex: 0];

	return success ? themes : nil;
}

@end
