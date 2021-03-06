//+------------------------------------------------------------------+
//|                                            UploadersEntities.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "ReportCreator.mqh"
#import "ReportManager.dll"

//+------------------------------------------------------------------+
//| Структура хранящая данные по входным параметрам                  |
//+------------------------------------------------------------------+
struct BotParams
  {
   string            name,value;
  };

// Добавление нового значения к динамичесому массиву
#define ADD_TO_ARR(arr, value) \
{\
   int s = ArraySize(arr);\
   ArrayResize(arr,s+1,s+1);\
   arr[s] = value;\
}

// добавление нового параметра робота к динамическому массиву параметрв
#define APPEND_BOT_PARAM(Var,BotParamArr) \
{\
   BotParams param;\
   param.name = #Var;\
   param.value = (string)Var;\
   \
   ADD_TO_ARR(BotParamArr,param);\
}

//+------------------------------------------------------------------+
//| Функция копирующая список массивов                               |
//+------------------------------------------------------------------+
void CopyBotParams(BotParams &dest[], const BotParams &src[])
  {
   int total = ArraySize(src);
   for(int i=0; i<total; i++)
     {
      ADD_TO_ARR(dest,src[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetAverageCoef(CoefChartType type, CReportCreator &report_manager)
  {
   CoefChart_item coef_chart[];
   report_manager.GetCoefChart(false,type,coef_chart);

   double ans= 0;
   int total = ArraySize(coef_chart);
   for(int i=0; i<total; i++)
      ans+=coef_chart[i].coef;

   ArrayFree(coef_chart);
   return (ans/(double)total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_path_to_expert(void)
  {
   string arr[];
   StringSplit(MQLInfoString(MQL_PROGRAM_PATH),'\\',arr);
   string relative_dir=NULL;

   int total= ArraySize(arr);
   bool save= false;
   for(int i=0; i<total; i++)
     {
      if(save)
        {
         if(relative_dir== NULL)
            relative_dir=arr[i];
         else
            relative_dir+="\\"+arr[i];
        }

      if(StringCompare("Experts",arr[i])==0)
         save=true;
     }

   return relative_dir;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
typedef void(*TCallback)();
typedef double(*TCustomFilter)();
typedef int (*TOnTesterInit)();


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

enum ENUM_CALLBACK_TYPE
  {
   CB_ON_TICK,
   CB_ON_TESTER_DEINIT
  };

struct Data
  {
   int tf, // ReportItem.TF
       laverage, // ReportReader.Laverage
       totalTrades, // ReportItem.OptimisationCoefficients.TotalTrades
       totalProfitTrades, // ReportItem.OptimisationCoefficients.MaxPLDD.Profit.TotalTrades
       totalLooseTrades, // ReportItem.OptimisationCoefficients.MaxPLDD.DD.TotalTrades
       consecutiveWins, // ReportItem.OptimisationCoefficients.MaxPLDD.Profit.ConsecutivesTrades
       consequtiveLoose, // ReportItem.OptimisationCoefficients.MaxPLDD.DD.ConsecutivesTrades
       numberProfitTrades_mn, // ReportItem.OptimisationCoefficients.TradingDays[Mn].Profit.Trades
       numberProfitTrades_tu, // ReportItem.OptimisationCoefficients.TradingDays[Tu].Profit.Trades
       numberProfitTrades_we, // ReportItem.OptimisationCoefficients.TradingDays[We].Profit.Trades
       numberProfitTrades_th, // ReportItem.OptimisationCoefficients.TradingDays[Th].Profit.Trades
       numberProfitTrades_fr, // ReportItem.OptimisationCoefficients.TradingDays[Fr].Profit.Trades
       numberLooseTrades_mn, // ReportItem.OptimisationCoefficients.TradingDays[Mn].DD.Trades
       numberLooseTrades_tu, // ReportItem.OptimisationCoefficients.TradingDays[Tu].DD.Trades
       numberLooseTrades_we, // ReportItem.OptimisationCoefficients.TradingDays[We].DD.Trades
       numberLooseTrades_th, // ReportItem.OptimisationCoefficients.TradingDays[Th].DD.Trades
       numberLooseTrades_fr; // ReportItem.OptimisationCoefficients.TradingDays[Fr].DD.Trades
   ulong startDT, // ReportItem.DateBorders.From
         finishDT; // ReportItem.DateBorders.Till
   double payoff, // ReportItem.OptimisationCoefficients.Payoff
          profitFactor, // ReportItem.OptimisationCoefficients.ProfitFactor
          averageProfitFactor, // ReportItem.OptimisationCoefficients.AverageProfitFactor
          recoveryFactor, // ReportItem.OptimisationCoefficients.RecoveryFactor
          averageRecoveryFactor, // ReportItem.OptimisationCoefficients.AverageRecoveryFactor
          pl, // ReportItem.OptimisationCoefficients.PL
          dd, // ReportItem.OptimisationCoefficients.DD
          altmanZScore, // ReportItem.OptimisationCoefficients.AltmanZScore
          var_90, // ReportItem.OptimisationCoefficients.VaR.Q_90
          var_95, // ReportItem.OptimisationCoefficients.VaR.Q_95
          var_99, // ReportItem.OptimisationCoefficients.VaR.Q_99
          mx, // ReportItem.OptimisationCoefficients.VaR.Mx
          std, // ReportItem.OptimisationCoefficients.VaR.Std
          max_profit, // ReportItem.OptimisationCoefficients.MaxPLDD.Profit.Value
          max_dd, // ReportItem.OptimisationCoefficients.MaxPLDD.DD.Value
          averagePl_mn, // ReportItem.OptimisationCoefficients.TradingDays[Mn].Profit.Value
          averagePl_tu, // ReportItem.OptimisationCoefficients.TradingDays[Tu].Profit.Value
          averagePl_we, // ReportItem.OptimisationCoefficients.TradingDays[We].Profit.Value
          averagePl_th, // ReportItem.OptimisationCoefficients.TradingDays[Th].Profit.Value
          averagePl_fr, // ReportItem.OptimisationCoefficients.TradingDays[Fr].Profit.Value
          averageDd_mn, // ReportItem.OptimisationCoefficients.TradingDays[Mn].DD.Value
          averageDd_tu, // ReportItem.OptimisationCoefficients.TradingDays[Tu].DD.Value
          averageDd_we, // ReportItem.OptimisationCoefficients.TradingDays[We].DD.Value
          averageDd_th, // ReportItem.OptimisationCoefficients.TradingDays[Th].DD.Value
          averageDd_fr, // ReportItem.OptimisationCoefficients.TradingDays[Fr].DD.Value
          balance; // ReportReader.Balance
   char              currency[100];
  };
//+------------------------------------------------------------------+
