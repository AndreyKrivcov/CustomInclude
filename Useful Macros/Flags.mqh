//+------------------------------------------------------------------+
//|                                                        Flags.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#ifndef USEFUL_MACROS_FLAGS
#define USEFUL_MACROS_FLAGS

#define ON_FLAG(flag,value) flag |= value
#define OFF_FLAG(flag,value) flag &= ~value
#define CHECK_FLAG(flag,value) (value&flag)==value

#define FLAGS
//+------------------------------------------------------------------+
