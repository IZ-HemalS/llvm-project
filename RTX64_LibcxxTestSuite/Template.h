//////////////////////////////////////////////////////////////////
//
// Copyright(c) 2018 IntervalZero, Inc. All rights reserved.
//
// Template.h - header file
//
//	This file was generated using the RTX64 Unit Test Wizard.
//
// User: owen
//
//////////////////////////////////////////////////////////////////

#pragma once
//This define will deprecate all unsupported Microsoft C-runtime functions when compiled under RTSS.
//If using this define, #include <rtapi.h> should remain below all windows headers
//#define UNDER_RTSS_UNSUPPORTED_CRT_APIS

#include <SDKDDKVer.h>

//#include <stdio.h>
//#include <string.h>
//#include <ctype.h>
//#include <conio.h>
//#include <stdlib.h>
//#include <math.h>
//#include <errno.h>
#include <windows.h>
#include <tchar.h>
#include <rtapi.h>


#ifdef _WIN64	// 64 BIT
#ifdef NDEBUG // RELEASE64
#ifdef UNDER_RTSS
TCHAR * TestStartStr = _T("Template [RELEASE64_RTSS] START");
TCHAR * TestEndStr = _T("Template [RELEASE64_RTSS] END");
#else
TCHAR * TestStartStr = _T("Template [RELEASE64_EXE] START");
TCHAR * TestEndStr = _T("Template [RELEASE64_EXE] END");
#endif 	
#else		// DEBUG64
#ifdef UNDER_RTSS
TCHAR * TestStartStr = _T("Template [DEBUG64_RTSS] START");
TCHAR * TestEndStr = _T("Template [DEBUG64_RTSS] END");
#else
TCHAR * TestStartStr = _T("Template [DEBUG64_EXE] START");
TCHAR * TestEndStr = _T("Template [DEBUG64_EXE] END");
#endif 
#endif
#else 			// 32 BIT
#ifdef NDEBUG // RELEASE32
#ifdef UNDER_RTSS
TCHAR * TestStartStr = _T("Template [RELEASE32_RTSS] START");
TCHAR * TestEndStr = _T("Template [RELEASE32_RTSS] END");
#else
TCHAR * TestStartStr = _T("Template [RELEASE32_EXE] START");
TCHAR * TestEndStr = _T("Template [RELEASE32_EXE] END");
#endif 	
#else		// DEBUG32
#ifdef UNDER_RTSS
TCHAR * TestStartStr = _T("Template [DEBUG32_RTSS] START");
TCHAR * TestEndStr = _T("Template [DEBUG32_RTSS] END");
#else
TCHAR * TestStartStr = _T("Template [DEBUG32_EXE] START");
TCHAR * TestEndStr = _T("Template [DEBUG32_EXE] END");
#endif 
#endif
#endif 
