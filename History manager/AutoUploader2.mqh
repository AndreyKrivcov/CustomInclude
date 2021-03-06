//+------------------------------------------------------------------+
//|                                                  AutoLoader2.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "UploadersEntities.mqh"

input bool close_terminal_after_finishing_optimisation = false; // MetaTrader Auto Optimiser param (must be false if you run it  from terminal)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CAutoUploader2
  {
private:
                     CAutoUploader2() {}

   static CCCM       comission_manager;
   static datetime   From,Till;

   static TCustomFilter on_tester;
   static TCallback on_tick,
          on_tester_deinit;
   static TOnTesterInit on_tester_init;

   static string     frame_name;
   static long       frame_id;
   static string     file_name;

   static bool       FillInData(Data &data);
   static void       UploadData(const Data &data, double custom_coef, const BotParams &params[], bool is_appent_to_collection);
   static void       CheckRetMessage(string er);
public:

   static void       OnTick();
   static double     OnTester();
   static int        OnTesterInit();
   static void       OnTesterDeinit();

   static void       SetUploadingFileName(string name);
   static void       SetCallback(TCallback callback, ENUM_CALLBACK_TYPE type);
   static void       SetCustomCoefCallback(TCustomFilter custom_filter_callback);
   static void       SetOnTesterInit(TOnTesterInit on_tester_init_callback);

   static void       AddComission(string symbol,double comission,double shift);
   static double     GetComission(string symbol,double price,double volume);
   static void       RemoveComission(string symbol);
  };

datetime CAutoUploader2::From = 0;
datetime CAutoUploader2::Till = 0;
TCustomFilter CAutoUploader2::on_tester = EmptyCustomCoefCallback;
TCallback CAutoUploader2::on_tick = EmptyCallback;
TOnTesterInit CAutoUploader2::on_tester_init = EmptyOnTesterInit;
TCallback CAutoUploader2::on_tester_deinit = EmptyCallback;
CCCM CAutoUploader2::comission_manager;
string CAutoUploader2::frame_name = "AutoOptomiserFrame";
long CAutoUploader2::frame_id = 1;
string CAutoUploader2::file_name = MQLInfoString(MQL_PROGRAM_NAME)+"_Report.xml";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAutoUploader2::OnTick(void)
  {
   if(MQLInfoInteger(MQL_OPTIMIZATION)==1 ||
      MQLInfoInteger(MQL_TESTER)==1)
     {
      if(From == 0)
         From = iTime(_Symbol,PERIOD_M1,0);
      Till=iTime(_Symbol,PERIOD_M1,0);
     }

   on_tick();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CAutoUploader2::OnTester(void)
  {
   double ret = on_tester();

   Data data[1];
   if(!FillInData(data[0]))
      return ret;

   if(MQLInfoInteger(MQL_OPTIMIZATION)==1)
     {
      if(!FrameAdd(frame_name, frame_id, ret, data))
         Print(GetLastError());
     }
   else
      if(MQLInfoInteger(MQL_TESTER)==1)
        {
         BotParams params[];
         UploadData(data[0], ret, params,false);
        }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CAutoUploader2::OnTesterInit(void) { return on_tester_init(); }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAutoUploader2::OnTesterDeinit(void)
  {
   ResetLastError();
   if(FrameFilter(frame_name,frame_id))
     {
      ulong pass;
      string name;
      long id;
      double coef_value;
      Data data[];

      while(FrameNext(pass,name,id,coef_value,data))
        {
         string parameters_list[];
         uint params_count;
         BotParams params[];
         if(FrameInputs(pass,parameters_list,params_count))
           {
            for(uint i=0; i<params_count; i++)
              {
               string arr[];
               StringSplit(parameters_list[i],'=',arr);
               BotParams item;
               item.name = arr[0];
               item.value = arr[1];
               ADD_TO_ARR(params,item);
              }
           }
         else
            Print("Can`t get params");

         UploadData(data[0], coef_value, params, true);
        }

      CheckRetMessage(ReportWriter::WriteReportData(get_path_to_expert(),
                      CharArrayToString(data[0].currency),
                      data[0].balance,
                      data[0].laverage,
                      TerminalInfoString(TERMINAL_COMMONDATA_PATH)+"\\"+file_name));
     }
   else
     {
      Print("Can`t select apropriate frames. Error code = " + IntegerToString(GetLastError()));
      ResetLastError();
     }
   on_tester_deinit();

   if(close_terminal_after_finishing_optimisation)
     {
      if(!TerminalClose(0))
        {
         Print("===================================");
         Print("Can`t close terminal from OnTesterDeinit error number: " +
               IntegerToString(GetLastError()) +
               " Close it by hands");
         Print("===================================");
        }
     }
   ExpertRemove();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAutoUploader2::SetCallback(TCallback callback,ENUM_CALLBACK_TYPE type)
  {
   if(type == ENUM_CALLBACK_TYPE::CB_ON_TICK)
      on_tick = callback;
   else
      on_tester_deinit = callback;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAutoUploader2::SetCustomCoefCallback(TCustomFilter custom_filter_callback)
  {
   on_tester = custom_filter_callback;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAutoUploader2::SetOnTesterInit(TOnTesterInit on_tester_init_callback)
  {
   on_tester_init = on_tester_init_callback;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAutoUploader2::AddComission(string symbol,double comission,double shift)
  {
   comission_manager.add(symbol,comission,shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CAutoUploader2::GetComission(string symbol,double price,double volume)
  {
   return comission_manager.get(symbol,price,volume);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAutoUploader2::RemoveComission(string symbol)
  {
   comission_manager.remove(symbol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAutoUploader2::FillInData(Data &data)
  {
   CReportCreator report_manager(&comission_manager);

   if(!report_manager.Create())
     {
      Print("##################################");
      Print("Can`t create report");
      Print("###################################");
      return false;
     }

   TotalResult totalResult;
   report_manager.GetTotalResult(totalResult);
   PL_detales pl_detales;
   report_manager.GetPL_detales(pl_detales);
   DailyPL pl;
   report_manager.GetDailyPL(CALC_FOR_OPEN,AVERAGE_DATA,pl);

   data.tf = (int)Period();
   data.laverage = (int)AccountInfoInteger(ACCOUNT_LEVERAGE);
   data.totalTrades = pl_detales.total.profit.orders+pl_detales.total.drawdown.orders;
   data.totalProfitTrades = pl_detales.total.profit.orders;
   data.totalLooseTrades = pl_detales.total.drawdown.orders;
   data.consecutiveWins = pl_detales.total.profit.dealsInARow;
   data.consequtiveLoose = pl_detales.total.drawdown.dealsInARow;
   data.numberProfitTrades_mn = pl.Mn.numTrades_profit;
   data.numberProfitTrades_tu = pl.Tu.numTrades_profit;
   data.numberProfitTrades_we = pl.We.numTrades_profit;
   data.numberProfitTrades_th = pl.Th.numTrades_profit;
   data.numberProfitTrades_fr = pl.Fr.numTrades_profit;
   data.numberLooseTrades_mn = pl.Mn.numTrades_drawdown;
   data.numberLooseTrades_tu = pl.Tu.numTrades_drawdown;
   data.numberLooseTrades_we = pl.We.numTrades_drawdown;
   data.numberLooseTrades_th = pl.Th.numTrades_drawdown;
   data.numberLooseTrades_fr = pl.Fr.numTrades_drawdown;
   data.startDT = (ulong)From;
   data.finishDT = (ulong)Till;
   data.payoff = (totalResult.total.averageDD==0 ? 0 : MathAbs(totalResult.total.averageProfit/totalResult.total.averageDD));
   data.profitFactor = totalResult.total.profitFactor;
   data.averageProfitFactor = GetAverageCoef(CoefChartType::_ProfitFactor_chart, report_manager);
   data.recoveryFactor = totalResult.total.recoveryFactor;
   data.averageRecoveryFactor = GetAverageCoef(CoefChartType::_RecoveryFactor_chart, report_manager);
   data.pl = totalResult.total.PL;
   data.dd = totalResult.total.maxDrawdown.byPL;
   data.altmanZScore = totalResult.total.altman_Z_Score;
   data.var_90 = totalResult.total.VaR_absolute.VAR_90;
   data.var_95 = totalResult.total.VaR_absolute.VAR_95;
   data.var_99 = totalResult.total.VaR_absolute.VAR_99;
   data.mx = totalResult.total.VaR_absolute.Mx;
   data.std = totalResult.total.VaR_absolute.Std;
   data.max_profit = pl_detales.total.profit.totalResult;
   data.max_dd = pl_detales.total.drawdown.totalResult;
   data.averagePl_mn = pl.Mn.Profit;
   data.averagePl_tu = pl.Tu.Profit;
   data.averagePl_we = pl.We.Profit;
   data.averagePl_th = pl.Th.Profit;
   data.averagePl_fr = pl.Fr.Profit;
   data.averageDd_mn = pl.Mn.Drawdown;
   data.averageDd_tu = pl.Tu.Drawdown;
   data.averageDd_we = pl.We.Drawdown;
   data.averageDd_th = pl.Th.Drawdown;
   data.averageDd_fr = pl.Fr.Drawdown;
   data.balance = report_manager.GetBalance();
   StringToCharArray(AccountInfoString(ACCOUNT_CURRENCY),data.currency);

   report_manager.Clear();

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAutoUploader2::UploadData(const Data &data, double custom_coef, const BotParams &params[], bool is_appent_to_collection)
  {
   int total = ArraySize(params);
   for(int i=0; i<total; i++)
      ReportWriter::AppendBotParam(params[i].name,params[i].value);

   ReportWriter::AppendMainCoef(custom_coef,data.payoff,data.profitFactor,data.averageProfitFactor,
                                data.recoveryFactor,data.averageRecoveryFactor,data.totalTrades,
                                data.pl,data.dd,data.altmanZScore);
   ReportWriter::AppendVaR(data.var_90,data.var_95,data.var_99,data.mx,data.std);
   ReportWriter::AppendMaxPLDD(data.max_profit,data.max_dd,
                               data.totalProfitTrades,data.totalLooseTrades,
                               data.consecutiveWins,data.consequtiveLoose);
   ReportWriter::AppendDay(MONDAY,data.averagePl_mn,data.averageDd_mn,
                           data.numberProfitTrades_mn,data.numberLooseTrades_mn);
   ReportWriter::AppendDay(TUESDAY,data.averagePl_tu,data.averageDd_tu,
                           data.numberProfitTrades_tu,data.numberLooseTrades_tu);
   ReportWriter::AppendDay(WEDNESDAY,data.averagePl_we,data.averageDd_we,
                           data.numberProfitTrades_we,data.numberLooseTrades_we);
   ReportWriter::AppendDay(THURSDAY,data.averagePl_th,data.averageDd_th,
                           data.numberProfitTrades_th,data.numberLooseTrades_th);
   ReportWriter::AppendDay(FRIDAY,data.averagePl_fr,data.averageDd_fr,
                           data.numberProfitTrades_fr,data.numberLooseTrades_fr);

   if(is_appent_to_collection)
     {
      ReportWriter::AppendToReportData(_Symbol,
                                       data.tf,
                                       data.startDT,
                                       data.finishDT);

      return;
     }

   CheckRetMessage(ReportWriter::Write(get_path_to_expert(),
                                       CharArrayToString(data.currency),
                                       data.balance,
                                       data.laverage,
                                       TerminalInfoString(TERMINAL_COMMONDATA_PATH)+"\\"+file_name,
                                       _Symbol,
                                       data.tf,
                                       data.startDT,
                                       data.finishDT));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAutoUploader2::CheckRetMessage(string er)
  {
   if(StringCompare(er,"")!=0)
     {
      Print("##################################");
      Print("Error while creating (*.xml) report file:");
      Print("_________________________________________");
      Print(er);
      Print("###################################");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAutoUploader2::SetUploadingFileName(string name)
  {
   file_name = name;
  }
//+------------------------------------------------------------------+

#ifndef CUSTOM_ON_TESTER
double OnTester() { return CAutoUploader2::OnTester(); }
#endif

#ifndef CUSTOM_ON_TESTER_INIT
int OnTesterInit() { return CAutoUploader2::OnTesterInit(); }
#endif

#ifndef CUSTOM_ON_TESTER_DEINIT
void OnTesterDeinit() { CAutoUploader2::OnTesterDeinit(); }
#endif

#ifndef CUSTOM_ON_TICK
void OnTick() { CAutoUploader2::OnTick(); }
#endif
//+------------------------------------------------------------------+
