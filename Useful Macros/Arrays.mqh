//+------------------------------------------------------------------+
//|                                                       Arrays.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#ifndef USEFUL_MACROS_ARRAYS
#define USEFUL_MACROS_ARRAYS

#define ADD_TO_ARR(arr, value) \
{\
   int s = ArraySize(arr);\
   ArrayResize(arr,s+1,s+1);\
   arr[s] = value;\
}

#endif 
//+------------------------------------------------------------------+
