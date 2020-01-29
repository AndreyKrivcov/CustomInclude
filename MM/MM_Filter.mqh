//+------------------------------------------------------------------+
//|                                                    MM_Filter.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "MMBase.mqh"
#include <Trade/Trade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Working_Hours
  {
   H_10 = 10,
   H_11 = 11,
   H_12 = 12,
   H_13 = 13,
   H_14 = 14,
   H_15 = 15,
   H_16 = 16,
   H_17 = 17,
   H_18 = 18,
   H_19 = 19,
   H_20 = 20,
   H_21 = 21,
   H_22 = 22,
   H_23 = 23
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMM_Filter
  {
private:

   MMBase           *mm;
   CTrade            trade;

   bool              do_trade,do_calculations;
   datetime          resume_trading_date;
   ENUM_DAY_OF_WEEK  non_working_days[];
   Working_Hours     work_from,work_to;

   bool              is_position();

   void              stop_trade(long date_type);

   void              check_daily_loose_or_profit_conduction();
   void              check_weekly_loose_cond();
   void              check_monthly_loose_cond();

   void              resume_trading();

public:
                     CMM_Filter(MMBase *_mm,ENUM_DAY_OF_WEEK &_non_working_days[],Working_Hours _work_from,Working_Hours _work_to);
                    ~CMM_Filter(void);

   void              do_check();
   bool              is_trade_enable();

  };
//+------------------------------------------------------------------+
CMM_Filter::CMM_Filter(MMBase *_mm,
                       ENUM_DAY_OF_WEEK &_non_working_days[],
                       Working_Hours _work_from,
                       Working_Hours _work_to) :mm(_mm),
                       do_trade(true),
                       resume_trading_date(0),
                       work_from(_work_from),
                       work_to(_work_to),
                       do_calculations(true)
  {
   if(mm==NULL)
     {
      Print("Money manager is ull");
      ExpertRemove();
     }
   ArrayCopy(non_working_days,_non_working_days);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMM_Filter::~CMM_Filter(void)
  {
   delete mm;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMM_Filter::is_trade_enable(void)
  {
   datetime DT=MARKET_TIME;
   MqlDateTime _DT;
   TimeToStruct(DT,_DT);

   bool wd_cond=true;
   bool wh_cond=(_DT.hour >= (int)work_from && _DT.hour <= (int)work_to);

   int total=ArraySize(non_working_days);
   if(total>0)
     {
      for(int i=0;i<total;i++)
        {
         if(non_working_days[i]==(ENUM_DAY_OF_WEEK)_DT.day_of_week)
           {
            wd_cond=false;
            break;
           }
        }
     }
   return (do_trade && wd_cond && wh_cond);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMM_Filter::is_position(void)
  {
   string symb[];
   mm.get_Symb(symb);
   int total= ArraySize(symb);
   for(int i=0;i<total;i++)
     {
      if(PositionSelect(symb[i]))
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMM_Filter::do_check(void)
  {

   resume_trading();

   bool _is_position=is_position();
   mm.Calculate(do_calculations,_is_position);

   if(!_is_position)
     {
      if(!do_trade)
         return;

      if(mm.TotalLooseCond())
        {
         stop_trade(SECONDS_A_YEAR);
         Comment("Total loose conduction was achived");
         Print("Total loose conduction was achived");
         ExpertRemove();
        }
     }
   else if(!do_calculations)
     {
      do_calculations=true;
     }

   check_daily_loose_or_profit_conduction();
   check_weekly_loose_cond();
   check_monthly_loose_cond();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMM_Filter::resume_trading(void)
  {
   if(do_trade)
      return;

   Comment("Trade will be enabled at "+TimeToString(resume_trading_date));

   datetime DT=MARKET_TIME;
   if(DT>resume_trading_date)
     {
      do_trade=true;
      Comment("");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMM_Filter::stop_trade(long date_type)
  {
   do_trade=false;
   string symb[];
   mm.get_Symb(symb);

#ifdef _DEBUG_
   Print("Close all");
#endif

   int total= ArraySize(symb);
   for(int i=0;i<total;i++)
     {
      if(PositionSelect(symb[i]))
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
#ifdef _DEBUG_
            Print("Sell "+symb[i]);
#else
            trade.Sell(PositionGetDouble(POSITION_VOLUME),symb[i]);
#endif
           }
         else
           {
#ifdef _DEBUG_
            Print("Buy "+symb[i]);
#else
            trade.Buy(PositionGetDouble(POSITION_VOLUME),symb[i]);
#endif
           }
        }
     }

   datetime DT=MARKET_TIME;
   resume_trading_date=(DT+(datetime)date_type);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMM_Filter::check_daily_loose_or_profit_conduction(void)
  {
   if(!do_trade)
      return;

   bool is_daily_profit=mm.DailyProfitCond();
   bool is_daily_loose = mm.DailyLooseCond();
   if(is_daily_loose || is_daily_profit)
     {
      stop_trade(SECONDS_A_DAY);
      if(is_daily_profit)
        {
         MqlDateTime DT;
         TimeToStruct(resume_trading_date,DT);
         DT.hour=10;
         resume_trading_date=StructToTime(DT);

         mm.Reset(Reset_Daily_Profit);
        }

      if(is_daily_loose)
         mm.Reset(Reset_Daily_Loose);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMM_Filter::check_weekly_loose_cond(void)
  {
   if(!do_trade)
      return;

   if(mm.WeeklyLooseCond())
     {
      stop_trade(SECONDS_A_WEEK);
      mm.Reset(Reset_Weekly);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMM_Filter::check_monthly_loose_cond(void)
  {
   if(!do_trade)
      return;

   if(mm.MonthlyLooseCond())
     {
      stop_trade(SECONDS_A_MONTH);
      mm.Reset(Reset_Monthly);
     }
  }
//+------------------------------------------------------------------+
