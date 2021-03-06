//+------------------------------------------------------------------+
//|                                                          IMM.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#define SECONDS_A_YEAR 31536000
#define SECONDS_A_MONTH 2678400
#define SECONDS_A_WEEK 604800
#define SECONDS_A_DAY 86400
#define MARKET_TIME TimeCurrent()
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Reset_Type
  {
   Reset_Daily_Profit,
   Reset_Daily_Loose,
   Reset_Weekly,
   Reset_Monthly
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MMBase
  {
protected:
   string            SymbArray[];
   datetime          StartDT;

public:
                     MMBase(string &_SymbArr[],datetime _StartDT);
   virtual          ~MMBase(void);

   void              get_Symb(string &arr[]);

   virtual void      Calculate(bool &do_calculations,bool is_position_now)=0;

   virtual bool      DailyLooseCond()=0;
   virtual bool      DailyProfitCond()=0;
   virtual bool      WeeklyLooseCond()=0;
   virtual bool      MonthlyLooseCond()=0;
   virtual bool      TotalLooseCond()=0;
   virtual void      Reset(Reset_Type type)=0;
  };
//+------------------------------------------------------------------+

MMBase::MMBase(string &_SymbArr[],datetime _StartDT) : StartDT(_StartDT)
  {
   ArrayCopy(SymbArray,_SymbArr);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MMBase::~MMBase(void)
  {
   ArrayRemove(SymbArray,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MMBase::get_Symb(string &arr[])
  {
   ArrayCopy(arr,SymbArray);
  }
//+------------------------------------------------------------------+
