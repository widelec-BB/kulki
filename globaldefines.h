/*
 * Copyright (c) 2022 Filip "widelec-BB" Maryjanski, BlaBla group.
 * All rights reserved.
 * Distributed under the terms of the MIT License.
 */

#if DEBUG
#include <clib/debug_protos.h>
#define tprintf(template, ...) KPrintF((CONST_STRPTR)APP_TITLE " " __FILE__ " %d: " template, __LINE__ , ##__VA_ARGS__)
#define ENTER(...) KPrintF((CONST_STRPTR)APP_TITLE " enters: %s\n", __PRETTY_FUNCTION__)
#define LEAVE(...) KPrintF((CONST_STRPTR)APP_TITLE " leaves: %s\n", __PRETTY_FUNCTION__)
#define strd(x)(((STRPTR)x) ? (STRPTR)(x) : (STRPTR)"NULL")
#else
#define tprintf(...)
#define ENTER(...)
#define LEAVE(...)
#define strd(x)
#endif

#define TO_STRING(x) #x
#define MACRO_TO_STRING(x) TO_STRING(x)

#define APP_TITLE          "Kulki"
#define APP_AUTHOR         "Filip \"widelec-BB\" Maryjanski"

#define APP_CYEARS         "2022" //  " - "__YEAR__
#define APP_VER_MAJOR      1
#define APP_VER_MINOR      1
#define APP_VER_NO         MACRO_TO_STRING(APP_VER_MAJOR)"."MACRO_TO_STRING(APP_VER_MINOR)
#define APP_COPYRIGHT      APP_CYEARS " " APP_AUTHOR
#define APP_VERSION        "$VER: " APP_TITLE " " APP_VER_NO " (" __APP_DATE__ ") (c) " APP_COPYRIGHT

#define APP_SCREEN_TITLE   APP_TITLE " " APP_VER_NO " " __APP_DATE__

#define GAME_FIELDS_IN_LINE 9
