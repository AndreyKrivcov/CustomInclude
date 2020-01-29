//+------------------------------------------------------------------+
//|                                               CustomComparer.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
interface ICustomComparer
  {
//--- compares two values and returns a value indicating whether one is less than, equal to, or greater than the other
   int       Compare(T &x,T &y);
  };
//+------------------------------------------------------------------+
