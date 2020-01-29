//+------------------------------------------------------------------+
//|                                                  SessionData.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Useful Macros/Arrays.mqh>

namespace CustomSymbol
{
//+------------------------------------------------------------------+
//| Session data item                                                |
//+------------------------------------------------------------------+
struct SSessionData
  {
   uint              index;
   datetime          from;
   datetime          to;
  };
//+------------------------------------------------------------------+
//| Session dta keeper                                               |
//+------------------------------------------------------------------+
class CSessionData
  {
   SSessionData monday[],
                tuesday[],
                wednsday[],
                thursday[],
                friday[],
                saturday[],
                sunday[];

   void              AddOrReplace(SSessionData &arr[], const SSessionData &data);

public:
   void              Set(ENUM_DAY_OF_WEEK day, const SSessionData &data);
   int               Get(ENUM_DAY_OF_WEEK day, SSessionData &data[]) const;

   void              Clear();
  };

void CSessionData::AddOrReplace(SSessionData &arr[],const SSessionData &data)
  {
   int total = ArraySize(arr);
   for(int i=0; i<total; i++)
     {
      if(arr[i].index == data.index)
        {
         arr[i] = data;
         return;
        }
     }

   ADD_TO_ARR(arr,data);
  }

void CSessionData::Set(ENUM_DAY_OF_WEEK day,const SSessionData &data)
  {
   switch(day)
     {
      case MONDAY :
         AddOrReplace(monday,data);
         break;
      case TUESDAY :
         AddOrReplace(tuesday,data);
         break;
      case WEDNESDAY :
         AddOrReplace(wednsday,data);
         break;
      case THURSDAY :
         AddOrReplace(thursday,data);
         break;
      case FRIDAY :
         AddOrReplace(friday,data);
         break;
      case SATURDAY :
         AddOrReplace(saturday,data);
         break;
      case SUNDAY :
         AddOrReplace(sunday,data);
         break;
     }
  }

int CSessionData::Get(ENUM_DAY_OF_WEEK day,SSessionData &data[]) const
  {
   ArrayFree(data);
   switch(day)
     {
      case MONDAY :
         ArrayCopy(data,monday);
         break;
      case TUESDAY :
         ArrayCopy(data,tuesday);
         break;
      case WEDNESDAY :
         ArrayCopy(data,wednsday);
         break;
      case THURSDAY :
         ArrayCopy(data,thursday);
         break;
      case FRIDAY :
         ArrayCopy(data,friday);
         break;
      case SATURDAY :
         ArrayCopy(data,saturday);
         break;
      case SUNDAY :
         ArrayCopy(data,sunday);
         break;
     }

   return ArraySize(data);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSessionData::Clear()
  {
   ArrayFree(monday);
   ArrayFree(tuesday);
   ArrayFree(wednsday);
   ArrayFree(thursday);
   ArrayFree(friday);
   ArrayFree(saturday);
   ArrayFree(sunday);
  }


}
//+------------------------------------------------------------------+
