/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#import <mui/MUIFramework.h>

@interface Application : MUIApplication

@property (nonatomic, readonly) OBString *executablePath;

-(VOID) about;

@end
