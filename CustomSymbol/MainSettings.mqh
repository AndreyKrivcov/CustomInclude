//+------------------------------------------------------------------+
//|                                                 MainSettings.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <CustomInclude/Useful Macros/Flags.mqh>
#include "SessionData.mqh"

namespace CustomSymbol
{
//+------------------------------------------------------------------+
//| Margin rate item                                                 |
//+------------------------------------------------------------------+
struct SMarginRate
  {
   ENUM_ORDER_TYPE   order_type;
   double            inital_margin, maintance_margin;
  };
//+------------------------------------------------------------------+
//| Expiration mode flags                                            |
//+------------------------------------------------------------------+
class CExpirationMode
  {
private:
   int               mode;
public:
                     CExpirationMode();

   void              ExpirationGTC(bool toggle);
   void              ExpirationDay(bool toggle);
   void              ExpirationSpecified(bool toggle);
   void              ExpirationSpecifiedDay(bool toggle);

   bool              ExpirationGTC() const;
   bool              ExpirationDay() const;
   bool              ExpirationSpecified() const;
   bool              ExpirationSpecifiedDay() const;

   int               Get() const;
   void              SetAll();

   void              operator=(const int);
  };


CExpirationMode::CExpirationMode(void)
  {
   SetAll();
  }
void CExpirationMode::SetAll(void)
  {
   mode = SYMBOL_EXPIRATION_GTC|SYMBOL_EXPIRATION_DAY|SYMBOL_EXPIRATION_SPECIFIED|SYMBOL_EXPIRATION_SPECIFIED_DAY;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpirationMode::ExpirationGTC(bool toggle)
  {
   if(toggle)
      ON_FLAG(mode,SYMBOL_EXPIRATION_GTC);
   else
      OFF_FLAG(mode,SYMBOL_EXPIRATION_GTC);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpirationMode::ExpirationDay(bool toggle)
  {
   if(toggle)
      ON_FLAG(mode,SYMBOL_EXPIRATION_DAY);
   else
      OFF_FLAG(mode,SYMBOL_EXPIRATION_DAY);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpirationMode::ExpirationSpecified(bool toggle)
  {
   if(toggle)
      ON_FLAG(mode,SYMBOL_EXPIRATION_SPECIFIED);
   else
      OFF_FLAG(mode,SYMBOL_EXPIRATION_SPECIFIED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpirationMode::ExpirationSpecifiedDay(bool toggle)
  {
   if(toggle)
      ON_FLAG(mode,SYMBOL_EXPIRATION_SPECIFIED_DAY);
   else
      OFF_FLAG(mode,SYMBOL_EXPIRATION_SPECIFIED_DAY);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpirationMode::ExpirationGTC(void) const {return CHECK_FLAG(mode,SYMBOL_EXPIRATION_GTC);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpirationMode::ExpirationDay(void) const {return CHECK_FLAG(mode,SYMBOL_EXPIRATION_DAY);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpirationMode::ExpirationSpecified(void) const {return CHECK_FLAG(mode,SYMBOL_EXPIRATION_SPECIFIED);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpirationMode::ExpirationSpecifiedDay(void) const {return CHECK_FLAG(mode,SYMBOL_EXPIRATION_SPECIFIED_DAY);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CExpirationMode::Get(void) const {return mode;}

void CExpirationMode::operator=(const int _mode)
  {
   mode = _mode;
  }

//+------------------------------------------------------------------+
//| Filling mode flags                                               |
//+------------------------------------------------------------------+
class CFillingMode
  {
private:
   int               mode;
public:
                     CFillingMode();

   void              FOK(bool toggle);
   void              IOC(bool toggle);

   bool              FOK() const;
   bool              IOC() const;

   int               Get() const;
   void              SetAll();

   void              operator=(const int);
  };


CFillingMode::CFillingMode(void)
  {
   SetAll();
  }
void CFillingMode::SetAll(void)
  {
   mode = SYMBOL_FILLING_FOK|SYMBOL_FILLING_IOC;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFillingMode::FOK(bool toggle)
  {
   if(toggle)
      ON_FLAG(mode,SYMBOL_FILLING_FOK);
   else
      OFF_FLAG(mode,SYMBOL_FILLING_FOK);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFillingMode::IOC(bool toggle)
  {
   if(toggle)
      ON_FLAG(mode,SYMBOL_FILLING_IOC);
   else
      OFF_FLAG(mode,SYMBOL_FILLING_IOC);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CFillingMode::FOK(void) const {return CHECK_FLAG(mode,SYMBOL_FILLING_FOK);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CFillingMode::IOC(void) const {return CHECK_FLAG(mode,SYMBOL_FILLING_IOC);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CFillingMode::Get(void) const {return mode;}

void CFillingMode::operator=(const int _mode)
  {
   mode = _mode;
  }

//+------------------------------------------------------------------+
//| Order mode flags                                                 |
//+------------------------------------------------------------------+
class COrderMode
  {
private:
   int               mode;
public:
                     COrderMode();

   void              Market(bool toggle);
   void              Limit(bool toggle);
   void              Stop(bool toggle);
   void              StopLimit(bool toggle);
   void              SL(bool toggle);
   void              TP(bool toggle);
   void              CloseBy(bool toggle);

   bool              Market() const;
   bool              Limit() const;
   bool              Stop() const;
   bool              StopLimit() const;
   bool              SL() const;
   bool              TP() const;
   bool              CloseBy() const;

   int               Get() const;
   void              SetAll();

   void              operator=(const int);
  };


COrderMode::COrderMode(void)
  {
   SetAll();
  }
void COrderMode::SetAll(void)
  {
   mode=SYMBOL_ORDER_MARKET|SYMBOL_ORDER_LIMIT|SYMBOL_ORDER_STOP|SYMBOL_ORDER_STOP_LIMIT|SYMBOL_ORDER_SL|SYMBOL_ORDER_TP|SYMBOL_ORDER_CLOSEBY;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COrderMode::Market(bool toggle)
  {
   if(toggle)
      ON_FLAG(mode,SYMBOL_ORDER_MARKET);
   else
      OFF_FLAG(mode,SYMBOL_ORDER_MARKET);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COrderMode::Limit(bool toggle)
  {
   if(toggle)
      ON_FLAG(mode,SYMBOL_ORDER_LIMIT);
   else
      OFF_FLAG(mode,SYMBOL_ORDER_LIMIT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COrderMode::Stop(bool toggle)
  {
   if(toggle)
      ON_FLAG(mode,SYMBOL_ORDER_STOP);
   else
      OFF_FLAG(mode,SYMBOL_ORDER_STOP);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COrderMode::StopLimit(bool toggle)
  {
   if(toggle)
      ON_FLAG(mode,SYMBOL_ORDER_STOP_LIMIT);
   else
      OFF_FLAG(mode,SYMBOL_ORDER_STOP_LIMIT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COrderMode::SL(bool toggle)
  {
   if(toggle)
      ON_FLAG(mode,SYMBOL_ORDER_SL);
   else
      OFF_FLAG(mode,SYMBOL_ORDER_SL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COrderMode::TP(bool toggle)
  {
   if(toggle)
      ON_FLAG(mode,SYMBOL_ORDER_TP);
   else
      OFF_FLAG(mode,SYMBOL_ORDER_TP);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COrderMode::CloseBy(bool toggle)
  {
   if(toggle)
      ON_FLAG(mode,SYMBOL_ORDER_CLOSEBY);
   else
      OFF_FLAG(mode,SYMBOL_ORDER_CLOSEBY);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMode::Market(void) const {return CHECK_FLAG(mode,SYMBOL_ORDER_MARKET);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMode::Limit(void) const {return CHECK_FLAG(mode,SYMBOL_ORDER_LIMIT);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMode::Stop(void) const {return CHECK_FLAG(mode,SYMBOL_ORDER_STOP);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMode::StopLimit(void) const {return CHECK_FLAG(mode,SYMBOL_ORDER_STOP_LIMIT);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMode::SL(void) const {return CHECK_FLAG(mode,SYMBOL_ORDER_SL);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMode::TP(void) const {return CHECK_FLAG(mode,SYMBOL_ORDER_TP);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMode::CloseBy(void) const {return CHECK_FLAG(mode,SYMBOL_ORDER_CLOSEBY);}
//+------------------------------------------------------------------+
int COrderMode::Get(void) const {return mode;}

void COrderMode::operator=(const int _mode)
  {
   mode = _mode;
  }


//+------------------------------------------------------------------+
//| Symbol main settings                                             |
//+------------------------------------------------------------------+
class CMainSettings
  {
private:
   SMarginRate       margin_rates[];

   void              SetDefault();
public:
                     CMainSettings();

   void              SetMarginRate(ENUM_ORDER_TYPE order_type, double inital_margin, double maintance_margin);
   int               GetMarginRate(SMarginRate &data[]) const;

   void              Clear();

   CSessionData      session_trade,session_quotes;

   // Integer
   color             background_color; //SYMBOL_BACKGROUND_COLOR
   ENUM_SYMBOL_CHART_MODE chart_mode; //SYMBOL_CHART_MODE
   int               digits;//SYMBOL_DIGITS
   int               spread; //SYMBOL_SPREAD
   bool              spread_float; //SYMBOL_SPREAD_FLOAT
   int               market_book_ticks; //SYMBOL_TICKS_BOOKDEPTH
   ENUM_SYMBOL_CALC_MODE calc_mode; //SYMBOL_TRADE_CALC_MODE
   ENUM_SYMBOL_TRADE_MODE trade_mode; //SYMBOL_TRADE_MODE
   datetime          start_time; //SYMBOL_START_TIME
   datetime          expiration_time; //SYMBOL_EXPIRATION_TIME
   int               stops_indentation; //SYMBOL_TRADE_STOPS_LEVEL
   int               freeze_level; //SYMBOL_TRADE_FREEZE_LEVEL
   ENUM_SYMBOL_TRADE_EXECUTION execution_mode; //SYMBOL_TRADE_EXEMODE
   ENUM_SYMBOL_SWAP_MODE swap_mode; //SYMBOL_SWAP_MODE
   ENUM_DAY_OF_WEEK  swap_rollover_3_days; //SYMBOL_SWAP_ROLLOVER3DAYS
   bool              margin_hedged_use_leg;//SYMBOL_MARGIN_HEDGED_USE_LEG
   CExpirationMode   expiration_mode; //SYMBOL_EXPIRATION_MODE
   CFillingMode      filling_mode; //SYMBOL_FILLING_MODE
   COrderMode        order_mode; //SYMBOL_ORDER_MODE
   ENUM_SYMBOL_ORDER_GTC_MODE GTC_mode; //SYMBOL_ORDER_GTC_MODE
   ENUM_SYMBOL_OPTION_MODE option_mode; //SYMBOL_OPTION_MODE
   ENUM_SYMBOL_OPTION_RIGHT option_right; //SYMBOL_OPTION_RIGHT

   // Double
   double            option_strike; //SYMBOL_OPTION_STRIKE
   double            point; //SYMBOL_POINT
   double            tick_value; //SYMBOL_TRADE_TICK_VALUE
   double            tick_size; //SYMBOL_TRADE_TICK_SIZE
   double            contract_size; //SYMBOL_TRADE_CONTRACT_SIZE
   double            accrued_interest; //SYMBOL_TRADE_ACCRUED_INTEREST
   double            face_value; //SYMBOL_TRADE_FACE_VALUE
   double            liquidity_rate; //SYMBOL_TRADE_LIQUIDITY_RATE
   double            volume_min; //SYMBOL_VOLUME_MIN
   double            volume_max; // SYMBOL_VOLUME_MAX
   double            volume_step; // SYMBOL_VOLUME_STEP
   double            volume_limit; //SYMBOL_VOLUME_LIMIT
   double            swap_long; //SYMBOL_SWAP_LONG
   double            swap_short; //SYMBOL_SWAP_SHORT
   double            session_price_limit_min; //SYMBOL_SESSION_PRICE_LIMIT_MIN
   double            session_price_limit_max; //SYMBOL_SESSION_PRICE_LIMIT_MAX
   double            margin_hedged; //SYMBOL_MARGIN_HEDGED

   // String
   string            underlying; //SYMBOL_BASIS
   string            underlying_currency; //SYMBOL_CURRENCY_BASE
   string            profit_currency; //SYMBOL_CURRENCY_PROFIT
   string            margin_currency; //SYMBOL_CURRENCY_MARGIN
   string            description; //SYMBOL_DESCRIPTION
   string            formula; //SYMBOL_FORMULA
   string            ISIN; //SYMBOL_ISIN
   string            page; //SYMBOL_PAGE
   string            path; //SYMBOL_PATH
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMainSettings::CMainSettings(void)
  {
   SetDefault();
  }

void CMainSettings::SetMarginRate(ENUM_ORDER_TYPE order_type,double inital_margin,double maintance_margin)
  {
   SMarginRate marginRate;
   marginRate.inital_margin = inital_margin;
   marginRate.maintance_margin = maintance_margin;
   marginRate.order_type = order_type;

   int total = ArraySize(margin_rates);
   for(int i=0; i<total; i++)
     {
      if(margin_rates[i].order_type == order_type)
        {
         margin_rates[i] = marginRate;
         return;
        }
     }

   ADD_TO_ARR(margin_rates, marginRate);
  }
int CMainSettings::GetMarginRate(SMarginRate &data[]) const
  {
   ArrayFree(data);
   ArrayCopy(data,margin_rates);
   return ArraySize(data);
  }
void CMainSettings::Clear(void)
  {
   ArrayFree(margin_rates);
   session_trade.Clear();
   session_quotes.Clear();

   SetDefault();
  }

void CMainSettings::SetDefault(void)
  {
   background_color=clrWhite;
   chart_mode=SYMBOL_CHART_MODE_LAST;
   digits=0;
   spread=0;
   spread_float=true;
   market_book_ticks=20;
   calc_mode=SYMBOL_CALC_MODE_FOREX;
   trade_mode=SYMBOL_TRADE_MODE_DISABLED;
   start_time=0;
   expiration_time=0;
   stops_indentation=0;
   freeze_level=0;
   execution_mode=SYMBOL_TRADE_EXECUTION_REQUEST;
   swap_mode=SYMBOL_SWAP_MODE_DISABLED;
   swap_rollover_3_days=MONDAY;
   margin_hedged_use_leg=false;
   expiration_mode.SetAll();
   filling_mode.SetAll();
   order_mode.SetAll();
   GTC_mode=SYMBOL_ORDERS_GTC;
   option_mode=SYMBOL_OPTION_MODE_EUROPEAN;
   option_right=SYMBOL_OPTION_RIGHT_CALL;
   option_strike=0;
   point=0;
   tick_value=1;
   tick_size=0.0001;
   contract_size=0.01;
   accrued_interest=0;
   face_value=0;
   liquidity_rate=0;
   volume_min=0.00000001;
   volume_max=0.0000001;
   volume_step=0.00000001;
   volume_limit=0;
   swap_long=0;
   swap_short=0;
   session_price_limit_min=0;
   session_price_limit_max=0;
   margin_hedged=0;
   underlying="";
   underlying_currency="USD";
   profit_currency="USD";
   margin_currency="USD";
   description="";
   formula="";
   ISIN="";
   page="";
   path="";
  }


}
//+------------------------------------------------------------------+
