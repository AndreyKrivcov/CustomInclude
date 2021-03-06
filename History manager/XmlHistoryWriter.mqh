//+------------------------------------------------------------------+
//|                                             XmlHistoryWriter.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "UploadersEntities.mqh"

//+------------------------------------------------------------------+
//| Класс - обертка для методов импортируемыхиз dll C#.              |
//+------------------------------------------------------------------+
class CXmlHistoryWriter
  {
private:
   const string      _path_to_file,_mutex_name;
   CReportCreator    _report_manager;
   TCustomFilter     custom_filter;

   void              append_bot_params(const BotParams  &params[]);//
   void              append_main_coef(PL_detales &pl_detales,
                                      TotalResult &totalResult);//
   //double            get_average_coef(CoefChartType type);
   void              insert_day(PLDrawdown &day,ENUM_DAY_OF_WEEK day);//
   void              append_days_pl();//

public:
                     CXmlHistoryWriter(string file_name,string mutex_name,
                     CCCM *_comission_manager, TCustomFilter filter);//
                     CXmlHistoryWriter(string mutex_name,CCCM *_comission_manager, TCustomFilter filter);
                    ~CXmlHistoryWriter(void) {_report_manager.Clear();} //

   void              Write(const BotParams &params[],datetime start_test,datetime end_test);//
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Конструктоыр                                                      |
//+------------------------------------------------------------------+
CXmlHistoryWriter::CXmlHistoryWriter(string file_name,
                                     string mutex_name,
                                     CCCM *_comission_manager,
                                     TCustomFilter filter) : _mutex_name(mutex_name),
   _path_to_file(TerminalInfoString(TERMINAL_COMMONDATA_PATH)+"\\"+file_name),
   _report_manager(_comission_manager),
   custom_filter(filter)
  {
  }
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CXmlHistoryWriter::CXmlHistoryWriter(string mutex_name,
                                     CCCM *_comission_manager,
                                     TCustomFilter filter) : _mutex_name(mutex_name),
   _path_to_file(TerminalInfoString(TERMINAL_COMMONDATA_PATH)+"\\"+MQLInfoString(MQL_PROGRAM_NAME)+"_"+"Report.xml"),
   _report_manager(_comission_manager),
   custom_filter(filter)
  {
  }

//+------------------------------------------------------------------+
//| МЕтод пишущий данные в файыл                                      |
//+------------------------------------------------------------------+
void CXmlHistoryWriter::Write(const BotParams &params[],datetime start_test,datetime end_test)
  {
   if(!_report_manager.Create())
     {
      Print("##################################");
      Print("Can`t create report:");
      Print("###################################");
      return;
     }
   TotalResult totalResult;
   _report_manager.GetTotalResult(totalResult);
   PL_detales pl_detales;
   _report_manager.GetPL_detales(pl_detales);

   append_bot_params(params);
   append_main_coef(pl_detales,totalResult);

   ReportWriter::AppendVaR(totalResult.total.VaR_absolute.VAR_90,
                           totalResult.total.VaR_absolute.VAR_95,
                           totalResult.total.VaR_absolute.VAR_99,
                           totalResult.total.VaR_absolute.Mx,
                           totalResult.total.VaR_absolute.Std);

   ReportWriter::AppendMaxPLDD(pl_detales.total.profit.totalResult,
                               pl_detales.total.drawdown.totalResult,
                               pl_detales.total.profit.orders,
                               pl_detales.total.drawdown.orders,
                               pl_detales.total.profit.dealsInARow,
                               pl_detales.total.drawdown.dealsInARow);
   append_days_pl();

   string error_msg=ReportWriter::MutexWriter(_mutex_name,get_path_to_expert(),AccountInfoString(ACCOUNT_CURRENCY),
                    _report_manager.GetBalance(),
                    (int)AccountInfoInteger(ACCOUNT_LEVERAGE),
                    _path_to_file,
                    _Symbol,(int)Period(),
                    start_test,
                    end_test);
   if(StringCompare(error_msg,"")!=0)
     {
      Print("##################################");
      Print("Error while creating (*.xml) report file:");
      Print("_________________________________________");
      Print(error_msg);
      Print("###################################");
     }
  }
//+------------------------------------------------------------------+
//| Метод добавляющий параметры роботов                                                                 |
//+------------------------------------------------------------------+
void CXmlHistoryWriter::append_bot_params(const BotParams &params[])
  {

   int total= ArraySize(params);
   for(int i=0; i<total; i++)
     {
      ReportWriter::AppendBotParam(params[i].name,params[i].value);
     }
  }
//+------------------------------------------------------------------+
//| Метод добавляющий основняе коэффициенты                          |
//+------------------------------------------------------------------+
void CXmlHistoryWriter::append_main_coef(PL_detales &pl_detales,TotalResult &totalResult)
  {
   double payoff=(totalResult.total.averageDD==0 ? 0 :MathAbs(totalResult.total.averageProfit/totalResult.total.averageDD));
   int total_trades=pl_detales.total.profit.orders+pl_detales.total.drawdown.orders;

   ReportWriter::AppendMainCoef(custom_filter(),
                                payoff,
                                totalResult.total.profitFactor,
                                GetAverageCoef(_ProfitFactor_chart,_report_manager),
                                totalResult.total.recoveryFactor,
                                GetAverageCoef(_RecoveryFactor_chart,_report_manager),
                                total_trades,
                                totalResult.total.PL,
                                totalResult.total.maxDrawdown.byPL,
                                totalResult.total.altman_Z_Score);
  }
//+------------------------------------------------------------------+
//| Метод добавляющий переданный день                                |
//+------------------------------------------------------------------+
void CXmlHistoryWriter::insert_day(PLDrawdown &params,ENUM_DAY_OF_WEEK day)
  {
   ReportWriter::AppendDay((int)day,
                           params.Profit,
                           params.Drawdown,
                           params.numTrades_profit,
                           params.numTrades_drawdown);
  }
//+------------------------------------------------------------------+
//| Метод добавляющий дни                                            |
//+------------------------------------------------------------------+
void CXmlHistoryWriter::append_days_pl(void)
  {
   DailyPL pl;
   _report_manager.GetDailyPL(CALC_FOR_OPEN,AVERAGE_DATA,pl);

   insert_day(pl.Mn,MONDAY);
   insert_day(pl.Tu,TUESDAY);
   insert_day(pl.We,WEDNESDAY);
   insert_day(pl.Th,THURSDAY);
   insert_day(pl.Fr,FRIDAY);
  }
//+------------------------------------------------------------------+
