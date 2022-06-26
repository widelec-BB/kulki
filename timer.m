/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <ob/OBFramework.h>
#import "timer.h"

@implementation Timer
{
	ULONG _timerStart, _timerDiff;
	BOOL _started;
	OBScheduledTimer *_tickTimer;
	MUIText *_text;
}

-(id) init
{
	MUIText *label = [MUIText textWithContents: OBL(@"Time:", @"Label for string with time passed")];
	MUIText *txt = [MUIText textWithContents: @"00:00"];

	label.preParse = @"\33r";
	label.weight = 0;

	if ((self = [super initHorizontalWithObjects: label, txt, nil]))
	{
		_text = txt;
	}
	return self;
}

-(VOID) start
{
	struct timeval current;

	[OBSystemTime getUpTime: &current];

	_timerStart = current.tv_secs;
	_timerDiff = 0;
	_text.contents = @"00:00";
	_started = YES;
}

-(VOID) pause
{
	struct timeval current;

	[OBSystemTime getUpTime: &current];

	_timerDiff += current.tv_secs - _timerStart;
}

-(VOID) resume
{
	struct timeval current;

	[OBSystemTime getUpTime: &current];

	_timerStart = current.tv_secs;
}

-(VOID) stop
{
	_started = NO;
}

-(VOID) tick
{
	struct timeval current;
	ULONG elapsed;

	if (!_started)
		return;

	[OBSystemTime getUpTime: &current];

	elapsed = current.tv_secs - _timerStart + _timerDiff;

	_text.contents = [OBString stringWithFormat: @"%02u:%02u", elapsed / 60, elapsed % 60];
}

-(BOOL) setup
{
	BOOL result = [super setup];

	if(result)
	{
		OBPerform *tick = [OBPerform performSelector: @selector(tick) target: self];

		_tickTimer = [[OBScheduledTimer alloc] initWithInterval: 1.f perform: tick repeats: YES];
		[_tickTimer startOnRunLoop: [OBRunLoop mainRunLoop]];
	}

	return result;
}

-(VOID) cleanup
{
	[_tickTimer invalidate];
	_tickTimer = nil;
	[super cleanup];
}

@end
