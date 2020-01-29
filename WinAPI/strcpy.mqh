//+------------------------------------------------------------------+
//|                                                             User |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006-2014"
#property version   "1.00"

#import "msvcrt.dll"
int strcpy(uchar &dst[],int src);
long strcpy(uchar &dst[],long src);
int strcpy(ushort &dst[],int src);
long strcpy(ushort &dst[],long src);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long strcpy(uchar &dst[],long src)
  {
   if(_IsX64)
      return(msvcrt::strcpy(dst,src));
   else
      return(msvcrt::strcpy(dst,(int)src));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long strcpy(ushort &dst[],long src)
  {
   if(_IsX64)
      return(msvcrt::strcpy(dst,src));
   else
      return(msvcrt::strcpy(dst,(int)src));
  }
//+------------------------------------------------------------------+
