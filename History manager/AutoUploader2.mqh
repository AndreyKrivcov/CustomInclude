//+------------------------------------------------------------------+
//|                                                  AutoLoader2.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "UploadersEntities.mqh"

#define DWORD unsigned long
#import "Kernel32.dll"
DWORD GetCurrentProcessId();
#import

input bool close_terminal_after_finishing_optimisation = false; // MetaTrader Auto Optimiser param (don`t change it)

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
   static string     tougle_file_name;

   static bool       FillInData(Data &data);
   static void       UploadData(const Data &data, const BotParams &params[]);
public:

   static void       OnTick();
   static double     OnTester();
   static int        OnTesterInit();
   static void       OnTesterDeinit();

   static void       SetCallback(TCallback callback, ENUM_CALLBACK_TYPE type);
   static void       SetCustomCoefCallback(TCustomFilter custom_filter_callback);
   static void       SetOnTesterInit(TOnTesterInit on_tester_init_callback);

   static void       AddComission(string symbol,double comission,double shift);
   static double     GetComission(string symbol,double price,double volume);
   static void       RemoveComission(string symbol);
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EmptyCallback() {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EmptyCustomCoefCallback() {return 0;}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int EmptyOnTesterInit() {return(INIT_SUCCEEDED);}

datetime CAutoUploader2::From = 0;
datetime CAutoUploader2::Till = 0;
TCustomFilter CAutoUploader2::on_tester = EmptyCustomCoefCallback;
TCallback CAutoUploader2::on_tick = EmptyCallback;
TOnTesterInit CAutoUploader2::on_tester_init = EmptyOnTesterInit;
TCallback CAutoUploader2::on_tester_deinit = EmptyCallback;
CCCM CAutoUploader2::comission_manager;
string CAutoUploader2::frame_name = "AutoOptomiserFrame";
long CAutoUploader2::frame_id = 1;
string CAutoUploader2::tougle_file_name = "AutoOptimiserTougle";

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
     {
      BotParams params[];
      UploadData(data[0], params);
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
   if(FrameFilter(frame_name,frame_id))
     {
      ulong pass;
      string name;
      long id;
      double coef_value;
      Data data[];

      while(FrameNext(pass,name,id,coef_value,data))
        {
         string     parameters_list[];
         uint params_count;
         BotParams params[];
         if(FrameInputs(pass,parameters_list,params_count))
           {
            for(uint i=0; i<params_count; i++)
              {
               string arr[];
               StringSplit(parameters_list[i],';',arr);
               BotParams item;
               item.name = arr[0];
               item.value = arr[1];
               ADD_TO_ARR(params,item);
              }
           }
         else
            Print("Can`t get params");

         UploadData(data[0],params);
        }
     }
   else
      Print(GetLastError());

   on_tester_deinit();

   if(close_terminal_after_finishing_optimisation)
     {
      Print("Close terminal from OnDTesterDeinit");
      TerminalClose(0);
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
      Print("Can`t create report:");
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
   data.numberProfitTrades_th = pl.Tu.numTrades_profit;
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
   StringToCharArray(_Symbol,data.symbol);

   report_manager.Clear();

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAutoUploader2::UploadData(const Data &data, const BotParams &params[])
  {

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
