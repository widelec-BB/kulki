/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <proto/graphics.h>
#import <clib/debug_protos.h>
#import <clib/alib_protos.h>
#import <proto/random.h>
#import <proto/intuition.h>
#import "globaldefines.h"
#import "game-field.h"
#import "game-window.h"
#import "saved-game.h"
#import "game-area.h"

@implementation GameArea
{
	OBScheduledTimer *_animationTimer;

	GameField *_fields[GAME_FIELDS_IN_LINE][GAME_FIELDS_IN_LINE];
	GameField *_activeField;

	OBMutableArray *_dirtyFields;
	OBMutableArray *_queue;

	BYTE _nextItems[3];
	BOOL _firstMoveDone;
	UBYTE _difficulty;
	ULONG _score;

	BOOL _wasDown;
}

@synthesize firstMoveDone = _firstMoveDone;
@synthesize difficulty = _difficulty;
@synthesize score = _score;

-(id) init
{
	if ((self = [super init]))
	{
		LONG x, y;

		self.fillArea = YES;
		self.frame = MUIV_Frame_Group;
		self.background = MUII_GroupBack;
		self.handledEvents = IDCMP_MOUSEBUTTONS;

		_dirtyFields = [OBMutableArray arrayWithCapacity: GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE];
		_queue = [OBMutableArray arrayWithCapacity: 100];

		for (x = 0; x < GAME_FIELDS_IN_LINE; x++)
		{
			for (y = 0; y < GAME_FIELDS_IN_LINE; y++)
			{
				_fields[x][y] = [[GameField alloc] initWithColumn: x row: y];
			}
		}
	}
	return self;
}

-(BOOL) setup
{
	BOOL result = [super setup];

	if(result)
	{
		OBPerform *animate = [OBPerform performSelector: @selector(animate) target: self];

		_animationTimer = [[OBScheduledTimer alloc] initWithInterval: 0.09f perform: animate repeats: YES];
		[_animationTimer startOnRunLoop: [OBRunLoop mainRunLoop]];
	}

	return result;
}

-(VOID) cleanup
{
	[_animationTimer invalidate];
	_animationTimer = nil;
	[super cleanup];
}

-(VOID) startNewGameWithDifficulty: (UBYTE)level
{
	OBMutableArray *fields = [OBMutableArray arrayWithCapacity: 5];
	LONG x, y;

	[_queue removeAllObjects];
	_difficulty = level;

	for (x = 0; x < GAME_FIELDS_IN_LINE; x++)
	{
		for (y = 0; y < GAME_FIELDS_IN_LINE; y++)
		{
			[_fields[x][y] clear];
		}
	}
	[self redraw: MADF_DRAWOBJECT];

	[self setNextItems];

	for (x = 0; x < 5; x++)
		[fields addObject: [self placeInRandomEmptyField: [self getRandomItemType]]];

	[self queueSpawnAnimation: fields];
	[_queue addObject: [OBPerform performSelector: @selector(checkLinesAroundMultiple:) target: self withObject: fields]];

	_firstMoveDone = NO;
}

-(VOID) animate
{
	if (_queue.count > 0)
	{
		OBPerform *p = [_queue objectAtIndex: 0];
		if (p)
		{
			[p perform];
			[self redraw: MADF_DRAWUPDATE];
			[_queue removeObjectAtIndex: 0];
		}
	}

	if (_activeField)
		[_activeField bounce];

	[self redraw];
}

-(VOID) redraw
{
	if (_activeField || _dirtyFields.count > 0)
		[self redraw: MADF_DRAWUPDATE];
}

-(BOOL) draw: (ULONG)flags
{
	[super draw: flags];

	if (flags & MADF_DRAWOBJECT)
	{
		struct RastPort *rp = self.rastPort;
		LONG x, y, i;
		LONG field_width = (self.innerWidth - GAME_FIELDS_IN_LINE) / GAME_FIELDS_IN_LINE;
		LONG field_height = (self.innerHeight - GAME_FIELDS_IN_LINE) / GAME_FIELDS_IN_LINE;

		SetAPen(rp, 13);
		for (i = 0; i <= GAME_FIELDS_IN_LINE; i++)
		{
			// vertical line
			Move(rp, self.left + self.innerWidth / GAME_FIELDS_IN_LINE * i, self.top);
			Draw(rp, self.left + self.innerWidth / GAME_FIELDS_IN_LINE * i, self.top + self.innerHeight / GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE);

			// horizontal line
			Move(rp, self.left, self.top + self.innerHeight / GAME_FIELDS_IN_LINE * i);
			Draw(rp, self.left + self.innerWidth / GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE, self.top + self.innerHeight / GAME_FIELDS_IN_LINE * i);
		}

		for (x = 0; x < GAME_FIELDS_IN_LINE; x++)
		{
			for (y = 0; y < GAME_FIELDS_IN_LINE; y++)
			{
				LONG left = self.left + self.innerWidth / GAME_FIELDS_IN_LINE * x + 1;
				LONG top = self.top + self.innerHeight / GAME_FIELDS_IN_LINE * y + 1;

				[_fields[x][y] draw: rp left: left width: field_width top: top height: field_height];
			}
		}

		[_dirtyFields removeAllObjects];
	}

	if (flags & MADF_DRAWUPDATE)
	{
		for (GameField *gf in _dirtyFields)
		{
			[self drawBackground: gf.left top: gf.top width: gf.width height: gf.height xoffset: gf.left yoffset: gf.top flags: 0];
			[gf draw: self.rastPort];
		}
		[_dirtyFields removeAllObjects];

		if (_activeField != nil)
		{
			[self drawBackground: _activeField.left top: _activeField.top width: _activeField.width height: _activeField.height
			      xoffset: _activeField.left yoffset: _activeField.top flags: 0];
			[_activeField draw: self.rastPort];
		}
	}

	return NO;
}

-(GameField *) gameFieldAt: (WORD)x y: (WORD)y
{
	LONG i, j;

	for (i = 0; i < GAME_FIELDS_IN_LINE; i++)
	{
		for (j = 0; j < GAME_FIELDS_IN_LINE; j++)
		{
			if ([_fields[i][j] isInObject: x y: y])
				return _fields[i][j];
		}
	}

	return nil;
}

-(VOID) mouseClickX: (WORD)x y: (WORD)y
{
	GameField *clickedField = [self gameFieldAt: x y: y];

	if (_activeField == clickedField || clickedField == nil)
		return;

	if (_activeField == nil && clickedField.empty)
		return;

	if (!clickedField.empty)
	{
		if (_activeField)
		{
			_activeField.active = NO;
			[_dirtyFields addObject: _activeField];
		}

		_activeField = clickedField;
		_activeField.active = YES;

		[_dirtyFields addObject: _activeField];

		[self redraw: MADF_DRAWUPDATE];
		return;
	}

	if(_activeField != nil && clickedField.empty)
	{
		SavedGame *sg = [[SavedGame alloc] init];

		sg.score = self.score;
		[sg storeFieldsState: _fields];
		[sg storeNextItems: _nextItems];

		if ([self checkPathFrom: _activeField to: clickedField])
		{
			_firstMoveDone = YES;
			_activeField.active = NO;
			_activeField = nil;

			[_queue addObject: [OBPerform performSelector: @selector(nextTurn:) target: self withObject: clickedField]];
			[_queue addObject: [OBPerform performSelector: @selector(setPreviousGameState:) target: self.windowObject withObject: sg]];
		}
		else
			DisplayBeep(NULL);
	}
}

-(VOID) move: (GameField *)src to: (GameField *)dst
{
	dst.type = src.type;
	[src clear];
	[_dirtyFields addObject: src];
	[_dirtyFields addObject: dst];
}

-(VOID) nextTurn: (GameField *)lastMoveField
{
	if (![self checkLinesAround: lastMoveField])
		[self spawnNextItems];
}

-(VOID) checkGameOver: (OBArray *) fields
{
	LONG x, y;

	if ([self checkLinesAroundMultiple: fields])
		return;

	for (x = 0; x < GAME_FIELDS_IN_LINE; x++)
	{
		for (y = 0; y < GAME_FIELDS_IN_LINE; y++)
		{
			if ([_fields[x][y] empty])
				return;
		}
	}

	_firstMoveDone = NO;
	[(GameWindow *)self.windowObject gameOver];
}

-(BOOL) checkLinesAroundMultiple: (OBArray *)fields
{
	BOOL anyCleared = NO;

	for (GameField *f in fields)
	{
		if ([self checkLinesAround: f])
			anyCleared = YES;
	}

	return anyCleared;
}

-(BOOL) checkLinesAround: (GameField *)gf
{
	LONG fieldsCleared = 0;
	LONG xb, xf, yb, yf;

	// left
	for (xb = gf.column - 1; xb >= 0 && _fields[xb][gf.row].type == gf.type; xb--);
	// right
	for (xf = gf.column + 1; xf < GAME_FIELDS_IN_LINE && _fields[xf][gf.row].type == gf.type; xf++);
	if (xf - xb > 5)
	{
		fieldsCleared += xf - xb - 1;

		for (++xb; xb < xf; xb++)
		{
			if (gf != _fields[xb][gf.row])
			{
				[_fields[xb][gf.row] clear];
				[_dirtyFields addObject: _fields[xb][gf.row]];
			}
		}
	}

	// up
	for (yb = gf.row - 1; yb >= 0 && _fields[gf.column][yb].type == gf.type; yb--);
	// down
	for (yf = gf.row + 1; yf < GAME_FIELDS_IN_LINE && _fields[gf.column][yf].type == gf.type; yf++);
	if (yf - yb > 5)
	{
		fieldsCleared += yf - yb - 1;

		for (++yb; yb < yf; yb++)
		{
			if (gf != _fields[gf.column][yb])
			{
				[_fields[gf.column][yb] clear];
				[_dirtyFields addObject: _fields[gf.column][yb]];
			}
		}
	}

	// left up
	for (xb = gf.column - 1, yb = gf.row - 1; xb >= 0 && yb >= 0 && _fields[xb][yb].type == gf.type; xb--, yb--);
	// right down
	for (xf = gf.column + 1, yf = gf.row + 1; xf < GAME_FIELDS_IN_LINE && yf < GAME_FIELDS_IN_LINE && _fields[xf][yf].type == gf.type; xf++, yf++);
	if (yf - yb > 5 && xf - xb > 5)
	{
		fieldsCleared += yf - yb - 1;

		for (++yb, ++xb; yb < yf && xb < xf; yb++, xb++)
		{
			if (gf != _fields[xb][yb])
			{
				[_fields[xb][yb] clear];
				[_dirtyFields addObject: _fields[xb][yb]];
			}
		}
	}

	// right up
	for (xf = gf.column + 1, yb = gf.row - 1; xf < GAME_FIELDS_IN_LINE && yb >= 0 && _fields[xf][yb].type == gf.type; xf++, yb--);
	// left down
	for (xb = gf.column - 1, yf = gf.row + 1; xb >= 0 && yf < GAME_FIELDS_IN_LINE && _fields[xb][yf].type == gf.type; xb--, yf++);
	if (yf - yb > 5 && xf - xb > 5)
	{
		fieldsCleared += yf - yb - 1;

		for (--xf, yb++; xf > xb && yb < yf; xf--, yb++)
		{
			if (gf != _fields[xf][yb])
			{
				[_fields[xf][yb] clear];
				[_dirtyFields addObject: _fields[xf][yb]];
			}
		}
	}

	if (fieldsCleared > 0)
	{
		[gf clear];
		[_dirtyFields addObject: gf];
	}

	self.score += fieldsCleared / 5 * _difficulty + (fieldsCleared % 5) * 2 * _difficulty;

	return fieldsCleared > 0;
}

-(VOID) spawnNextItems
{
	OBMutableArray *fields = [OBMutableArray arrayWithCapacity: 3];
	LONG i;

	for (i = 0; i < 3; i++)
	{
		GameField *f = [self placeInRandomEmptyField: _nextItems[i]];
		if (f)
			[fields addObject: f];
	}

	[self queueSpawnAnimation: fields];
	[_queue addObject: [OBPerform performSelector: @selector(checkGameOver:) target: self withObject: fields]];

	[self setNextItems];
}

-(LONG) getRandomItemType
{
	return Random() % _difficulty;
}

-(VOID) setNextItems
{
	LONG i;

	for (i = 0; i < 3; i++)
		_nextItems[i] = [self getRandomItemType];

	[(GameWindow *)self.windowObject setNextItems: _nextItems];
}

-(GameField *) placeInRandomEmptyField: (LONG)type
{
	LONG x, y;
	LONG rx = Random() % GAME_FIELDS_IN_LINE, ry = Random() % GAME_FIELDS_IN_LINE;

	x = rx;
	y = ry;

	do
	{
		if ([_fields[x][y] empty])
		{
			_fields[x][y].alpha = 0;
			_fields[x][y].type = type;

			return _fields[x][y];
		}
		x = (x + 1) % GAME_FIELDS_IN_LINE;
		if (x == 0)
			y = (y + 1) % GAME_FIELDS_IN_LINE;
	} while(x != rx || y != ry);

	return nil;
}

-(BOOL) checkPathFrom: (GameField *)src to: (GameField *)dst
{
	SHORT g[GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE][GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE];
	SHORT d[GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE], prev[GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE];
	BOOL v[GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE];
	const SHORT inf = 500;
	SHORT x, y, count;
	SHORT mindistance, nextnode;
	SHORT srcIdx = src.column + GAME_FIELDS_IN_LINE * src.row;
	SHORT dstIdx = dst.column + GAME_FIELDS_IN_LINE * dst.row;

	for (x = 0; x < GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE; x++)
	{
		for (y = 0; y < GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE; y++)
		{
			g[x][y] = inf;
		}
	}

	for (x = 0; x < GAME_FIELDS_IN_LINE; x++)
	{
		for (y = 0; y < GAME_FIELDS_IN_LINE; y++)
		{
			if (x - 1 >= 0)
			{
				if ([_fields[x - 1][y] empty])
					g[x + GAME_FIELDS_IN_LINE * y][x - 1 + GAME_FIELDS_IN_LINE * y] = 1;
				if ([_fields[x][y] empty])
					g[x - 1 + GAME_FIELDS_IN_LINE * y][x + GAME_FIELDS_IN_LINE * y] = 1;
			}

			if (x + 1 < GAME_FIELDS_IN_LINE)
			{
				if ([_fields[x + 1][y] empty])
					g[x + GAME_FIELDS_IN_LINE * y][x + 1 + GAME_FIELDS_IN_LINE * y] = 1;
				if ([_fields[x][y] empty])
					g[x + 1 + GAME_FIELDS_IN_LINE * y][x + GAME_FIELDS_IN_LINE * y] = 1;
			}

			if (y - 1 >= 0)
			{
				if ([_fields[x][y - 1] empty])
					g[x + GAME_FIELDS_IN_LINE * y][x + GAME_FIELDS_IN_LINE * (y - 1)] = 1;
				if ([_fields[x][y] empty])
					g[x + GAME_FIELDS_IN_LINE * (y - 1)][x + GAME_FIELDS_IN_LINE * y] = 1;
			}

			if (y + 1 < GAME_FIELDS_IN_LINE)
			{
				if ([_fields[x][y + 1] empty])
					g[x + GAME_FIELDS_IN_LINE * y][x + GAME_FIELDS_IN_LINE * (y + 1)] = 1;
				if ([_fields[x][y] empty])
					g[x + GAME_FIELDS_IN_LINE * (y + 1)][x + GAME_FIELDS_IN_LINE * y] = 1;
			}
		}
	}

#if defined (DEBUG) && GAME_FIELDS_IN_LINE <= 5
	tprintf("PATH GRAPH\n");
	KPrintF("             ");
	for (int x = 0; x < GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE; x++)
	{
		KPrintF(" [%02d]  ", x);
	}
	KPrintF("\n            ");
	for (int x = 0; x < GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE; x++)
	{
		KPrintF(" (%d %d) ", x % GAME_FIELDS_IN_LINE, x / GAME_FIELDS_IN_LINE);
	}
	KPrintF("\n");
	for (int i = 0; i < GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE; i++)
	{
		KPrintF("[%02d] (%d %d)  ", i, i % GAME_FIELDS_IN_LINE, i / GAME_FIELDS_IN_LINE);
		for (int j = 0; j < GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE; j++)
		{
			if (g[i][j] == inf)
				KPrintF("   -   ");
			else
				KPrintF("   %ld   ", g[i][j]);
		}
		KPrintF("\n");
	}
	tprintf("PATH GRAPH END\n");
#endif

	for (x = 0; x < GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE; x++)
	{
		d[x] = g[srcIdx][x];
		v[x] = NO;
		prev[x] = srcIdx;
	}

	d[src.column + GAME_FIELDS_IN_LINE * src.row] = 0;
	v[src.column + GAME_FIELDS_IN_LINE * src.row] = YES;

	for (count = 1; count < GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE - 1; count++)
	{
		mindistance = inf;

		for (x = 0; x < GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE; x++)
		{
			if (d[x] < mindistance && !v[x])
			{
				mindistance = d[x];
				nextnode = x;
			}
		}
		if (mindistance == inf)
			break;

		v[nextnode] = YES;

		for (x = 0; x < GAME_FIELDS_IN_LINE * GAME_FIELDS_IN_LINE; x++)
		{
			if (!v[x])
			{
				if (mindistance + g[nextnode][x] < d[x]) {
					d[x] = mindistance + g[nextnode][x];
					prev[x] = nextnode;
				}
			}
		}
	}

	if (d[dstIdx] == inf)
		return NO;

	count = _queue.count;
	while (1)
	{
		SHORT px = prev[dstIdx] % GAME_FIELDS_IN_LINE, py = prev[dstIdx] / GAME_FIELDS_IN_LINE;
		GameField *from = _fields[px][py];
		GameField *to = _fields[dstIdx % GAME_FIELDS_IN_LINE][dstIdx / GAME_FIELDS_IN_LINE];

		if (dstIdx == srcIdx)
			break;

		[_queue insertObject: [OBPerform performSelector: @selector(move:to:) target: self withObject: from withObject: to] atIndex: count];

		dstIdx = prev[dstIdx];
	}

	return YES;
}

-(ULONG) handleEvent: (struct IntuiMessage *)imsg muikey: (LONG)muikey
{
	if (imsg)
	{
		switch (imsg->Class)
		{
			case IDCMP_MOUSEBUTTONS:
				if ([self isInObject: imsg])
				{
					switch (imsg->Code)
					{
						case SELECTDOWN:
							_wasDown = YES;
						break;

						case SELECTUP:
							if (_wasDown)
							{
								[self mouseClickX: imsg->MouseX y: imsg->MouseY];
								_wasDown = NO;
							}
						break;
					}
					return MUI_EventHandlerRC_Eat;
				}
				else
				{
					switch (imsg->Code)
					{
						case SELECTDOWN:
						case SELECTUP:
							_wasDown = NO;
					}
				}
			break;
		}
	}

	return 0;
}

-(VOID) askMinMax: (struct MUI_MinMax *)minmax
{
	minmax->MinWidth  +=  32 * GAME_FIELDS_IN_LINE + GAME_FIELDS_IN_LINE + 1;
	minmax->MinHeight +=  32 * GAME_FIELDS_IN_LINE + GAME_FIELDS_IN_LINE + 1;
	minmax->DefWidth  +=  64 * GAME_FIELDS_IN_LINE + GAME_FIELDS_IN_LINE + 1;
	minmax->DefHeight +=  64 * GAME_FIELDS_IN_LINE + GAME_FIELDS_IN_LINE + 1;
	minmax->MaxWidth  +=  MUI_MAXMAX;
	minmax->MaxHeight +=  MUI_MAXMAX;
}

-(VOID) setAlpha: (OBNumber *)alpha fields: (OBArray *)fields
{
	for (GameField *field in fields)
	{
		[field setAlpha: alpha.unsignedLongValue];
		[_dirtyFields addObject: field];
	}

	[self redraw];
}

-(VOID) queueSpawnAnimation: (OBArray *)fields
{
	ULONG alphaStep = 0xFFFFFFFF / 4;
	LONG i;

	for (i = 1; i < 4; i++)
	{
		OBNumber *step = [OBNumber numberWithUnsignedLong: alphaStep * i];
		[_queue addObject: [OBPerform performSelector: @selector(setAlpha:fields:) target: self withObject: step withObject: fields]];
	}
	[_queue addObject: [OBPerform performSelector: @selector(setAlpha:fields:) target: self withObject: [OBNumber numberWithUnsignedLong: 0xFFFFFFFF] withObject: fields]];
}

-(VOID) restoreFieldsStateFrom: (SavedGame *)sg
{
	[sg loadFieldsState: _fields];
	[self redraw: MADF_DRAWOBJECT];

	[sg loadNextItems: _nextItems];
	[(GameWindow *)self.windowObject setNextItems: _nextItems];
}

-(VOID) setScore: (ULONG)value
{
	_score = value;
	[(GameWindow *)self.windowObject updateScore];
}

@end
