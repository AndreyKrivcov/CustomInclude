//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include "Settings.mqh"

namespace CustomSymbol
{

//+------------------------------------------------------------------+
//| Custom symbol                                                    |
//+------------------------------------------------------------------+
class CCustomSymbol
  {
private:


   void              CopyMarginRate(string symbol);
   bool              CopySession(string symbol, bool is_trade_session, ENUM_DAY_OF_WEEK day, CSessionData &out_sessions_keeper);//
   bool              CopySession(string symbol, bool is_trade_session, CSessionData &out_sessions_keeper);
   bool              SetSession(const CSessionData &data, ENUM_DAY_OF_WEEK day, bool is_trading_session);
   bool              SetSession(bool is_trading_session,const CSessionData &data);
   bool              ReplaceSettings();//
public:
                     CCustomSymbol(string symbol);//

   CSettings         settings;

   const string      CustomSymbol;

   bool              CopyMainSettingsFrom(string symbol);// Clear last MainSettings before copy
   bool              CopyTicksFrom(string symbol, ulong from_msc, ulong to_msc);//
   bool              CopyRatesFrom(string symbol, datetime from, datetime to);//

   bool              AddMarketBook(const MqlBookInfo &book[]);
   bool              AddTicks(const MqlTick &ticks[]);

   bool              Delete();
   bool              DeleteRates(datetime from, datetime to);
   bool              DeleteTicks(ulong from_msc, ulong to_msc);

   bool              Create(bool add_rates, bool add_ticks);//
   bool              Replace(bool replace_rates, bool replace_ticks, bool replace_settings);//
   bool              LoadSymbolSettings(bool load_rates, bool load_ticks);//

   bool              IsSymbolExists();//
   bool              IsSymbolInMarketWatch();//

   void              Clear(); // отчищает данные переданные в этот класс, но сам класс все еще остается ассоциирован с символом указанным в конструкторе
  };

//======================================================================================================

CCustomSymbol::CCustomSymbol(string symbol) : CustomSymbol(symbol) {}

void CCustomSymbol::CopyMarginRate(string symbol)
  {
   double inital_rate,maintance_rate;

#define COPY_MARGIN_RATE(property) \
   if(SymbolInfoMarginRate(symbol,property,inital_rate,maintance_rate))\
      settings.MainSettings.SetMarginRate(property,inital_rate,maintance_rate);

//==========================================================================================

   COPY_MARGIN_RATE(ORDER_TYPE_BUY)
   COPY_MARGIN_RATE(ORDER_TYPE_SELL)
   COPY_MARGIN_RATE(ORDER_TYPE_BUY_LIMIT)
   COPY_MARGIN_RATE(ORDER_TYPE_SELL_LIMIT)
   COPY_MARGIN_RATE(ORDER_TYPE_BUY_STOP)
   COPY_MARGIN_RATE(ORDER_TYPE_SELL_STOP)
   COPY_MARGIN_RATE(ORDER_TYPE_BUY_STOP_LIMIT)
   COPY_MARGIN_RATE(ORDER_TYPE_SELL_STOP_LIMIT)
   COPY_MARGIN_RATE(ORDER_TYPE_CLOSE_BY)
  }

bool CCustomSymbol::CopySession(string symbol,bool is_trade_session,ENUM_DAY_OF_WEEK day,CSessionData &out_sessions_keeper)
  {
   int session_index = 0;
   datetime from,to;

   while((is_trade_session ? SymbolInfoSessionTrade(symbol,day,session_index,from,to) : SymbolInfoSessionQuote(symbol,day,session_index,from,to)))
     {
      SSessionData data;
      data.from = from;
      data.to = to;
      data.index = session_index;

      out_sessions_keeper.Set(day,data);

      session_index++;
     }

   return (session_index > 0);
  }

bool CCustomSymbol::CopySession(string symbol,bool is_trade_session,CSessionData &out_sessions_keeper)
  {
   if(!CopySession(symbol,is_trade_session,MONDAY,out_sessions_keeper))
      return false;
   if(!CopySession(symbol,is_trade_session,TUESDAY,out_sessions_keeper))
      return false;
   if(!CopySession(symbol,is_trade_session,WEDNESDAY,out_sessions_keeper))
      return false;
   if(!CopySession(symbol,is_trade_session,THURSDAY,out_sessions_keeper))
      return false;
   if(!CopySession(symbol,is_trade_session,FRIDAY,out_sessions_keeper))
      return false;
   if(!CopySession(symbol,is_trade_session,SATURDAY,out_sessions_keeper))
      return false;
   if(!CopySession(symbol,is_trade_session,SUNDAY,out_sessions_keeper))
      return false;

   return true;
  }

bool CCustomSymbol::CopyMainSettingsFrom(string symbol)
  {
// Integer
   long integer_tmp;
#define COPY_INTEGER(property,value_to_replace,convert_to) \
if(!SymbolInfoInteger(symbol,property,integer_tmp))\
   return false;\
else\
   value_to_replace = (convert_to)integer_tmp;

// Double
   double double_tmp;
#define COPY_DOUBLE(property,value_to_replace) \
if(!SymbolInfoDouble(symbol,property,double_tmp))\
   return false;\
else\
   value_to_replace = double_tmp;

// String
   string string_tmp;
#define COPY_STRING(property,value_to_replace) \
if(!SymbolInfoString(symbol,property,string_tmp))\
   return false;\
else\
   value_to_replace = string_tmp;

//==========================================================================================

   settings.MainSettings.Clear();

   CopyMarginRate(symbol);

   if(!CopySession(symbol,true,settings.MainSettings.session_trade))
      return false;
   if(!CopySession(symbol,false,settings.MainSettings.session_quotes))
      return false;

   COPY_INTEGER(SYMBOL_BACKGROUND_COLOR,settings.MainSettings.background_color,color)
   COPY_INTEGER(SYMBOL_CHART_MODE,settings.MainSettings.chart_mode,ENUM_SYMBOL_CHART_MODE)
   COPY_INTEGER(SYMBOL_DIGITS,settings.MainSettings.digits,int)
   COPY_INTEGER(SYMBOL_SPREAD,settings.MainSettings.spread,int)
   COPY_INTEGER(SYMBOL_SPREAD_FLOAT,settings.MainSettings.spread_float,bool)
   COPY_INTEGER(SYMBOL_TICKS_BOOKDEPTH,settings.MainSettings.market_book_ticks,int)
   COPY_INTEGER(SYMBOL_TRADE_CALC_MODE,settings.MainSettings.calc_mode,ENUM_SYMBOL_CALC_MODE)
   COPY_INTEGER(SYMBOL_TRADE_MODE,settings.MainSettings.trade_mode,ENUM_SYMBOL_TRADE_MODE)
   COPY_INTEGER(SYMBOL_START_TIME,settings.MainSettings.start_time,datetime)
   COPY_INTEGER(SYMBOL_EXPIRATION_TIME,settings.MainSettings.expiration_time,datetime)
   COPY_INTEGER(SYMBOL_TRADE_STOPS_LEVEL,settings.MainSettings.stops_indentation,int)
   COPY_INTEGER(SYMBOL_TRADE_FREEZE_LEVEL,settings.MainSettings.freeze_level,int)
   COPY_INTEGER(SYMBOL_TRADE_EXEMODE,settings.MainSettings.execution_mode,ENUM_SYMBOL_TRADE_EXECUTION)
   COPY_INTEGER(SYMBOL_SWAP_MODE,settings.MainSettings.swap_mode,ENUM_SYMBOL_SWAP_MODE)
   COPY_INTEGER(SYMBOL_SWAP_ROLLOVER3DAYS,settings.MainSettings.swap_rollover_3_days,ENUM_DAY_OF_WEEK)
   COPY_INTEGER(SYMBOL_MARGIN_HEDGED_USE_LEG,settings.MainSettings.margin_hedged_use_leg,bool)
   COPY_INTEGER(SYMBOL_EXPIRATION_MODE,settings.MainSettings.expiration_mode,int)
   COPY_INTEGER(SYMBOL_FILLING_MODE,settings.MainSettings.filling_mode,int)
   COPY_INTEGER(SYMBOL_ORDER_MODE,settings.MainSettings.order_mode,int)
   COPY_INTEGER(SYMBOL_ORDER_GTC_MODE,settings.MainSettings.GTC_mode,ENUM_SYMBOL_ORDER_GTC_MODE)
   COPY_INTEGER(SYMBOL_OPTION_MODE,settings.MainSettings.option_mode,ENUM_SYMBOL_OPTION_MODE)
   COPY_INTEGER(SYMBOL_OPTION_RIGHT,settings.MainSettings.option_right,ENUM_SYMBOL_OPTION_RIGHT)

   COPY_DOUBLE(SYMBOL_OPTION_STRIKE,settings.MainSettings.option_strike);
   COPY_DOUBLE(SYMBOL_POINT,settings.MainSettings.point);
   COPY_DOUBLE(SYMBOL_TRADE_TICK_VALUE,settings.MainSettings.tick_value);
   COPY_DOUBLE(SYMBOL_TRADE_TICK_SIZE,settings.MainSettings.tick_size);
   COPY_DOUBLE(SYMBOL_TRADE_CONTRACT_SIZE,settings.MainSettings.contract_size);
   COPY_DOUBLE(SYMBOL_TRADE_ACCRUED_INTEREST,settings.MainSettings.accrued_interest);
   COPY_DOUBLE(SYMBOL_TRADE_FACE_VALUE,settings.MainSettings.face_value);
   COPY_DOUBLE(SYMBOL_TRADE_LIQUIDITY_RATE,settings.MainSettings.liquidity_rate);
   COPY_DOUBLE(SYMBOL_VOLUME_MIN,settings.MainSettings.volume_min);
   COPY_DOUBLE(SYMBOL_VOLUME_MAX,settings.MainSettings.volume_max);
   COPY_DOUBLE(SYMBOL_VOLUME_STEP,settings.MainSettings.volume_step);
   COPY_DOUBLE(SYMBOL_VOLUME_LIMIT,settings.MainSettings.volume_limit);
   COPY_DOUBLE(SYMBOL_SWAP_LONG,settings.MainSettings.swap_long);
   COPY_DOUBLE(SYMBOL_SWAP_SHORT,settings.MainSettings.swap_short);
   COPY_DOUBLE(SYMBOL_SESSION_PRICE_LIMIT_MIN,settings.MainSettings.session_price_limit_min);
   COPY_DOUBLE(SYMBOL_SESSION_PRICE_LIMIT_MAX,settings.MainSettings.session_price_limit_max);
   COPY_DOUBLE(SYMBOL_MARGIN_HEDGED,settings.MainSettings.margin_hedged);

   COPY_STRING(SYMBOL_BASIS,settings.MainSettings.underlying);
   COPY_STRING(SYMBOL_CURRENCY_BASE,settings.MainSettings.underlying_currency);
   COPY_STRING(SYMBOL_CURRENCY_PROFIT,settings.MainSettings.profit_currency);
   COPY_STRING(SYMBOL_CURRENCY_MARGIN,settings.MainSettings.margin_currency);
   COPY_STRING(SYMBOL_DESCRIPTION,settings.MainSettings.description);
   COPY_STRING(SYMBOL_FORMULA,settings.MainSettings.formula);
   COPY_STRING(SYMBOL_ISIN,settings.MainSettings.ISIN);
   COPY_STRING(SYMBOL_PAGE,settings.MainSettings.page);
   COPY_STRING(SYMBOL_PATH,settings.MainSettings.path);

   return true;
  }

bool CCustomSymbol::CopyRatesFrom(string symbol,datetime from,datetime to)
  {
   settings.ClearRates();
   MqlRates rates[];
   if(CopyRates(symbol,PERIOD_M1,from,to,rates)<=0)
      return false;
   settings.Set(rates);

   return true;
  }
bool CCustomSymbol::CopyTicksFrom(string symbol,ulong from_msc,ulong to_msc)
  {
   settings.ClearTicks();
   MqlTick ticks[];
   if(CopyTicksRange(symbol,ticks,COPY_TICKS_ALL,from_msc,to_msc)<=0)
      return false;
   settings.Set(ticks);

   return true;
  }

bool CCustomSymbol::AddMarketBook(const MqlBookInfo &book[]) {return CustomBookAdd(CustomSymbol,book);}
bool CCustomSymbol::AddTicks(const MqlTick &ticks[]) {return (CustomTicksAdd(CustomSymbol,ticks) != -1);}

bool CCustomSymbol::Delete() {return CustomSymbolDelete(CustomSymbol);}
bool CCustomSymbol::DeleteRates(datetime from,datetime to) {return (CustomRatesDelete(CustomSymbol,from,to) != -1);}
bool CCustomSymbol::DeleteTicks(ulong from_msc,ulong to_msc) {return (CustomTicksDelete(CustomSymbol,from_msc, to_msc) != -1);}

bool CCustomSymbol::Create(bool add_rates, bool add_ticks)
  {
   if(!CustomSymbolCreate(CustomSymbol,settings.MainSettings.path,settings.MainSettings.underlying) && !Replace(true,true,true))
      return false;

   if(!Replace(add_rates,add_ticks,true))
     {
      Delete();
      return false;
     }

   return true;
  }
bool CCustomSymbol::Replace(bool replace_rates, bool replace_ticks, bool replace_settings)
  {
   if(replace_settings && !ReplaceSettings())
      return false;
   if(replace_rates)
     {
      MqlRates rates[];
      settings.Get(rates);
      int total = ArraySize(rates);

      if(total == 0 || (total > 0 && CustomRatesUpdate(CustomSymbol,rates) == -1))
         return false;
     }
   if(replace_ticks)
     {
      MqlTick ticks[];
      settings.Get(ticks);
      int total = ArraySize(ticks);

      if(total == 0 || (total > 0 && CustomTicksReplace(CustomSymbol,ticks[0].time_msc,ticks[total-1].time_msc,ticks)==-1))
         return false;
     }

   return true;
  }
bool CCustomSymbol::LoadSymbolSettings(bool load_rates,bool load_ticks)
  {
   if(!IsSymbolExists())
      return false;
   if(!CopyMainSettingsFrom(CustomSymbol))
      return false;
   if(load_ticks && !CopyTicksFrom(CustomSymbol,0,TimeCurrent()*1000))
      return false;
   if(load_rates && !CopyRatesFrom(CustomSymbol,0,TimeCurrent()))
      return false;

   return true;
  }
bool CCustomSymbol::IsSymbolExists(void) {return SymbolInfoInteger(CustomSymbol,SYMBOL_EXIST)==1;}
bool CCustomSymbol::IsSymbolInMarketWatch(void) {return SymbolInfoInteger(CustomSymbol,SYMBOL_SELECT)==1;}

void CCustomSymbol::Clear(void) {settings.Clear();}

bool CCustomSymbol::SetSession(const CSessionData &data,ENUM_DAY_OF_WEEK day, bool is_trading_session)
  {
   SSessionData session_data[];
   int total = data.Get(day,session_data);
   for(int i=0; i<total; i++)
     {
      if(!(is_trading_session ?
           CustomSymbolSetSessionTrade(CustomSymbol,day,session_data[i].index,session_data[i].from,session_data[i].to) :
           CustomSymbolSetSessionQuote(CustomSymbol,day,session_data[i].index,session_data[i].from,session_data[i].to)))
        {
         return false;
        }
     }

   return true;
  }

bool CCustomSymbol::SetSession(bool is_trading_session,const CSessionData &data)
  {
   if(!SetSession(data,MONDAY,is_trading_session))
      return false;
   if(!SetSession(data,TUESDAY,is_trading_session))
      return false;
   if(!SetSession(data,WEDNESDAY,is_trading_session))
      return false;
   if(!SetSession(data,THURSDAY,is_trading_session))
      return false;
   if(!SetSession(data,FRIDAY,is_trading_session))
      return false;
   if(!SetSession(data,SATURDAY,is_trading_session))
      return false;
   if(!SetSession(data,SUNDAY,is_trading_session))
      return false;

   return true;
  }

bool CCustomSymbol::ReplaceSettings(void)
  {
   SMarginRate margin_rate[];
   int total = settings.MainSettings.GetMarginRate(margin_rate);
   for(int i=0; i<total; i++)
     {
      if(!CustomSymbolSetMarginRate(CustomSymbol,margin_rate[i].order_type,
                                    margin_rate[i].inital_margin,
                                    margin_rate[i].maintance_margin))
        {
         return false;
        }
     }

   if(!SetSession(true,settings.MainSettings.session_trade))
      return false;
   if(!SetSession(false,settings.MainSettings.session_quotes))
      return false;

   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_BACKGROUND_COLOR,settings.MainSettings.background_color))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_CHART_MODE,settings.MainSettings.chart_mode))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_DIGITS,settings.MainSettings.digits))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_SPREAD,settings.MainSettings.spread))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_SPREAD_FLOAT,settings.MainSettings.spread_float))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_TICKS_BOOKDEPTH,settings.MainSettings.market_book_ticks))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_TRADE_CALC_MODE,settings.MainSettings.calc_mode))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_TRADE_MODE,settings.MainSettings.trade_mode))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_START_TIME,settings.MainSettings.start_time))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_EXPIRATION_TIME,settings.MainSettings.expiration_time))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_TRADE_STOPS_LEVEL,settings.MainSettings.stops_indentation))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_TRADE_FREEZE_LEVEL,settings.MainSettings.freeze_level))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_TRADE_EXEMODE,settings.MainSettings.execution_mode))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_SWAP_MODE,settings.MainSettings.swap_mode))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_SWAP_ROLLOVER3DAYS,settings.MainSettings.swap_rollover_3_days))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_MARGIN_HEDGED_USE_LEG,settings.MainSettings.margin_hedged_use_leg))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_EXPIRATION_MODE,settings.MainSettings.expiration_mode.Get()))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_FILLING_MODE,settings.MainSettings.filling_mode.Get()))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_ORDER_MODE,settings.MainSettings.order_mode.Get()))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_ORDER_GTC_MODE,settings.MainSettings.GTC_mode))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_OPTION_MODE,settings.MainSettings.option_mode))
      return false;
   if(!CustomSymbolSetInteger(CustomSymbol,SYMBOL_OPTION_RIGHT,settings.MainSettings.option_right))
      return false;

   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_OPTION_STRIKE,settings.MainSettings.option_strike))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_POINT,settings.MainSettings.point))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_TRADE_TICK_VALUE,settings.MainSettings.tick_value))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_TRADE_TICK_SIZE,settings.MainSettings.tick_size))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_TRADE_CONTRACT_SIZE,settings.MainSettings.contract_size))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_TRADE_ACCRUED_INTEREST,settings.MainSettings.accrued_interest))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_TRADE_FACE_VALUE,settings.MainSettings.face_value))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_TRADE_LIQUIDITY_RATE,settings.MainSettings.liquidity_rate))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_VOLUME_LIMIT,settings.MainSettings.volume_limit))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_VOLUME_MAX,settings.MainSettings.volume_max))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_VOLUME_MIN,settings.MainSettings.volume_min))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_VOLUME_STEP,settings.MainSettings.volume_step))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_SWAP_LONG,settings.MainSettings.swap_long))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_SWAP_SHORT,settings.MainSettings.swap_short))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_SESSION_PRICE_LIMIT_MIN,settings.MainSettings.session_price_limit_min))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_SESSION_PRICE_LIMIT_MAX,settings.MainSettings.session_price_limit_max))
      return false;
   if(!CustomSymbolSetDouble(CustomSymbol,SYMBOL_MARGIN_HEDGED,settings.MainSettings.margin_hedged))
      return false;

   if(!CustomSymbolSetString(CustomSymbol,SYMBOL_BASIS,settings.MainSettings.underlying))
      return false;
   if(!CustomSymbolSetString(CustomSymbol,SYMBOL_CURRENCY_BASE,settings.MainSettings.underlying_currency))
      return false;
   if(!CustomSymbolSetString(CustomSymbol,SYMBOL_CURRENCY_PROFIT,settings.MainSettings.profit_currency))
      return false;
   if(!CustomSymbolSetString(CustomSymbol,SYMBOL_CURRENCY_MARGIN,settings.MainSettings.margin_currency))
      return false;
   if(!CustomSymbolSetString(CustomSymbol,SYMBOL_DESCRIPTION,settings.MainSettings.description))
      return false;
   if(!CustomSymbolSetString(CustomSymbol,SYMBOL_FORMULA,settings.MainSettings.formula))
      return false;
   if(!CustomSymbolSetString(CustomSymbol,SYMBOL_ISIN,settings.MainSettings.ISIN))
      return false;
   if(!CustomSymbolSetString(CustomSymbol,SYMBOL_PAGE,settings.MainSettings.page))
      return false;
   if(!CustomSymbolSetString(CustomSymbol,SYMBOL_PATH,settings.MainSettings.path))
      return false;

   return true;
  }

//==========================================================================================


//==========================================================================================

//==========================================================================================

//==========================================================================================

//==========================================================================================


//==========================================================================================

//==========================================================================================
}
//+------------------------------------------------------------------+
