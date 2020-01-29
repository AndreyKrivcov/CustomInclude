//+------------------------------------------------------------------+
//|                                                     Settings.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <CustomInclude/CustomGeneric/GenericSorter.mqh>
#include "MainSettings.mqh"

namespace CustomSymbol
{


class CRatesComparer : public ICustomComparer<MqlRates>
  {
public:
   int               Compare(MqlRates &x,MqlRates &y);
  };
class CTicksComparer : public ICustomComparer<MqlTick>
  {
public:
   int               Compare(MqlTick &x,MqlTick &y);
  };

//+------------------------------------------------------------------+
//| Symbol settings                                                  |
//+------------------------------------------------------------------+
class CSettings
  {
private:
   MqlRates          rates[];
   MqlTick           ticks[];

   CRatesComparer    rates_comparer;
   CTicksComparer    ticks_comparer;
   CGenericSorter    sorter;
public:
                     CSettings();

   CMainSettings     MainSettings;

   void              Set(const MqlRates& data[]);
   void              Set(const MqlTick& data[]);

   void              Get(MqlRates &data[]);
   void              Get(MqlTick &data[]);

   void              Clear();
   void              ClearRates();
   void              ClearTicks();

  };


int CRatesComparer::Compare(MqlRates &x,MqlRates &y)
  {
   if(x.time == y.time)
      return 0;
   else
      return(x.time > y.time ? 1 : -1);
  }
int CTicksComparer::Compare(MqlTick &x,MqlTick &y)
  {
   if(x.time_msc == y.time_msc)
      return 0;
   else
      return(x.time_msc > y.time_msc ? 1 : -1);
  }

CSettings::CSettings(void)
  {
   sorter.Method(Sort_Ascending);
  }

void CSettings::Set(const MqlRates &data[])
  {
   int s= ArraySize(rates);
   ArrayCopy(rates,data,s);
  }
void CSettings::Set(const MqlTick &data[])
  {
   int s= ArraySize(ticks);
   ArrayCopy(ticks,data,s);
  }

void CSettings::Get(MqlRates &data[])
  {
   ArrayFree(data);
   ArrayCopy(data,rates);

   sorter.QuickSort<MqlRates>(data,&rates_comparer,ArraySize(data));
  }
void CSettings::Get(MqlTick &data[])
  {
   ArrayFree(data);
   ArrayCopy(data,ticks);

   sorter.QuickSort<MqlTick>(data,&ticks_comparer,ArraySize(data));
  }

void CSettings::Clear(void)
  {
   ClearRates();
   ClearTicks();
   MainSettings.Clear();
  }
void CSettings::ClearRates(void)
  {
   ArrayFree(rates);
  }
void CSettings::ClearTicks(void)
  {
   ArrayFree(ticks);
  }

}
//+------------------------------------------------------------------+
