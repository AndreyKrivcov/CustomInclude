//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "MMBase.mqh"
#include <CustomInclude/History manager/DealHistoryGetter.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct DD_Levels
  {
   double Daily_Loose,
   Daily_Profit,
   Weekly_Loose,
   Monthly_Loose,
   Total_Loose;
  };
//+------------------------------------------------------------------+
class CMM_Absolute_DD : public MMBase
  {
private:
   DD_Levels         lvl_etalone;
   DD_Levels         lvl_current;

   int               total_symbols;
   ENUM_DAY_OF_WEEK  day;
   datetime          week_start;
   int               month;

   bool              check_symbol(const DealKeeper &deal);
   double            get_pl(const DealKeeper &deal);

   datetime          get_mn(datetime DT);
   datetime          get_mn(const MqlDateTime &DT);

   void              daily_calculate(datetime DT,bool is_position);
   void              weekly_calculation(datetime DT,double pl);
   void              monthly_calculation(datetime DT,double pl);

   CDealHistoryGetter deals_getter;
public:
                     CMM_Absolute_DD(string &_SymbArr[],datetime _StartDT,DD_Levels &_lvl,CCCM *_comission_manager) : MMBase(_SymbArr,_StartDT),
                                                                                                                          deals_getter(_comission_manager)
     {
      lvl_etalone=_lvl;
      total_symbols=ArraySize(_SymbArr);
      ZeroMemory(lvl_current);

      MqlDateTime DT;
      TimeToStruct(MARKET_TIME,DT);
      day=(ENUM_DAY_OF_WEEK)DT.day_of_week;
      month=DT.mon;
      week_start=get_mn(DT);
     }

   void              Calculate(bool &do_calculations,bool is_position_now) final;

   bool      DailyLooseCond() final {return (lvl_etalone.Daily_Loose == 0 ? false : lvl_current.Daily_Loose >= lvl_etalone.Daily_Loose);};
   bool      DailyProfitCond() final{return (lvl_etalone.Daily_Profit == 0 ? false : lvl_current.Daily_Profit >= lvl_etalone.Daily_Profit);};
   bool      WeeklyLooseCond()final{return(lvl_etalone.Weekly_Loose==0 ? false : lvl_current.Weekly_Loose>=lvl_etalone.Weekly_Loose);};
   bool      MonthlyLooseCond()final{return(lvl_etalone.Monthly_Loose==0 ? false : lvl_current.Monthly_Loose>=lvl_etalone.Monthly_Loose);};
   bool      TotalLooseCond()final{return(lvl_etalone.Total_Loose==0 ? false : lvl_current.Total_Loose>=lvl_etalone.Total_Loose);};

   void              Reset(Reset_Type type) final;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMM_Absolute_DD::Reset(Reset_Type type)
  {
   switch(type)
     {
      case Reset_Daily_Profit :
         lvl_current.Daily_Profit=0;
         break;
      case Reset_Daily_Loose :
         lvl_current.Daily_Loose=0;
         break;
      case Reset_Weekly :
         lvl_current.Weekly_Loose=0;
         break;
      case Reset_Monthly :
         lvl_current.Monthly_Loose=0;
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMM_Absolute_DD::daily_calculate(datetime DT,bool is_position)
  {
   MqlDateTime TimeStruct;
   TimeToStruct(DT,TimeStruct);

   if(day!=(ENUM_DAY_OF_WEEK)TimeStruct.day_of_week)
     {
      lvl_current.Daily_Loose=0;
      lvl_current.Daily_Profit=0;
     }
   day=(ENUM_DAY_OF_WEEK)TimeStruct.day_of_week;

   if(!is_position)
      return;

   double pl=0;
   for(int i=0;i<total_symbols;i++)
     {
      if(PositionSelect(SymbArray[i]))
         pl+=PositionGetDouble(POSITION_PROFIT);
     }
   lvl_current.Daily_Profit=pl;
   lvl_current.Daily_Loose=(-pl);

   if(lvl_current.Daily_Loose < 0)
      lvl_current.Daily_Loose=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMM_Absolute_DD::weekly_calculation(datetime DT,double pl)
  {
   if(DT<week_start)
      return;

   if((DT-week_start)>SECONDS_A_WEEK)
     {
      week_start=get_mn(DT);
      lvl_current.Weekly_Loose=0;
     }
   lvl_current.Weekly_Loose+=(-pl);

   if(lvl_current.Weekly_Loose < 0)
      lvl_current.Weekly_Loose=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMM_Absolute_DD::monthly_calculation(datetime DT,double pl)
  {
   MqlDateTime TimeStruct;
   TimeToStruct(DT,TimeStruct);
   if(TimeStruct.mon<month)
      return;

   if(TimeStruct.mon>month)
     {
      month=TimeStruct.mon;
      lvl_current.Monthly_Loose=0;
     }
   lvl_current.Monthly_Loose+=(-pl);

   if(lvl_current.Monthly_Loose < 0)
      lvl_current.Monthly_Loose=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CMM_Absolute_DD::get_mn(datetime DT)
  {
   MqlDateTime TimeStruct;
   TimeToStruct(DT,TimeStruct);
   return get_mn(TimeStruct);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CMM_Absolute_DD::get_mn(const MqlDateTime &DT)
  {
   MqlDateTime TimeStruct=DT;

   TimeStruct.hour= 10;
   TimeStruct.min = 0;
   TimeStruct.sec = 0;

   if(TimeStruct.day_of_week==SUNDAY)
      TimeStruct.day-=6;
   else
      TimeStruct.day-=(TimeStruct.day_of_week-MONDAY);

   if(TimeStruct.day<=0)
     {
      int n=MathAbs(TimeStruct.day);

      if(TimeStruct.mon==1)
        {
         TimeStruct.mon=12;
         TimeStruct.year-=1;
        }
      else
         TimeStruct.mon-=1;

      for(int i=31;i>=28;i--)
        {
         TimeStruct.day=i-n;
         datetime _DT=StructToTime(TimeStruct);
         TimeToStruct(_DT,TimeStruct);

         if((ENUM_DAY_OF_WEEK)TimeStruct.day_of_week!=MONDAY)
            continue;

         break;
        }
     }

   return StructToTime(TimeStruct);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMM_Absolute_DD::check_symbol(const DealKeeper &deal)
  {
   for(int i=0;i<total_symbols;i++)
     {
      if(StringCompare(deal.symbol,SymbArray[i])==0)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMM_Absolute_DD::get_pl(const DealKeeper &deal)
  {
   int total = ArraySize(deal.deals);
   double pl = 0;
   for(int i=0;i<total;i++)
     {
      pl+=deal.deals[i].profit;
     }
   return pl;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMM_Absolute_DD::Calculate(bool &do_calculations,bool is_position_now)
  {

   datetime DT_now=MARKET_TIME;

// calculate daily countesr for active positions
   daily_calculate(DT_now,is_position_now);

#ifdef _SHOW_MM_COMMENTS_
   Comment("Start Time : "+TimeToString(StartDT)+"\n"+
           "DT now : "+TimeToString(DT_now)+"\n"+
           "do_calculations = "+(do_calculations ? "true" : "false")+"\n"+
           "======================================="+"\n"+
           "Daily Profit = "+ DoubleToString(lvl_current.Daily_Profit) + "\n" +
           "Daily Loose = " + DoubleToString(lvl_current.Daily_Loose) + "\n" +
           "Weekly Loose = "+ DoubleToString(lvl_current.Weekly_Loose) + "\n" +
           "Monthly Loose = "+DoubleToString(lvl_current.Monthly_Loose)+ "\n"+
           "Total Loose = "+DoubleToString(lvl_current.Total_Loose));
#endif

   if(!do_calculations || is_position_now) // check togle
      return;

   if(DT_now<=StartDT) // check date conduction
      return;

// get deals for the selected period
   DealKeeper deals[];
   if(!deals_getter.getHistory(deals,StartDT,DT_now))
      return;

// Increase counters
   int total=ArraySize(deals);
   for(int i=0;i<total;i++)
     {
      if(!check_symbol(deals[i])) // check symbol
         continue;

      // get pl for the position
      double pl=get_pl(deals[i]);

      // increase counters
      weekly_calculation(deals[i].DT_max,pl);
      monthly_calculation(deals[i].DT_max,pl);

      lvl_current.Total_Loose+=(-pl);
      if(lvl_current.Total_Loose < 0)
         lvl_current.Total_Loose=0;
     }

// set new start time
   StartDT=deals[ArraySize(deals)-1].DT_max+60; // current DT + 1 minute
   do_calculations=false; // off calculation togle for a wile
  }
//+------------------------------------------------------------------+
