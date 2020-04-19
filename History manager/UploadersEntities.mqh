//+------------------------------------------------------------------+
//|                                            UploadersEntities.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "ReportCreator.mqh"

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

enum ENUM_CALLBACK_TYPE
  {
   CB_ON_TICK,
   CB_ON_TESTER_DEINIT
  };

struct Data
  {
   int tf,
       laverage,
       totalTrades,
       totalProfitTrades,
       totalLooseTrades,
       consecutiveWins,
       consequtiveLoose,
       numberProfitTrades_mn,
       numberProfitTrades_tu,
       numberProfitTrades_we,
       numberProfitTrades_th,
       numberProfitTrades_fr,
       numberLooseTrades_mn,
       numberLooseTrades_tu,
       numberLooseTrades_we,
       numberLooseTrades_th,
       numberLooseTrades_fr;
   ulong startDT,
         finishDT;
   double payoff,
          profitFactor,
          averageProfitFactor,
          recoveryFactor,
          averageRecoveryFactor,
          pl,
          dd,
          altmanZScore,
          var_90,
          var_95,
          var_99,
          mx,
          std,
          max_profit,
          max_dd,
          averagePl_mn,
          averagePl_tu,
          averagePl_we,
          averagePl_th,
          averagePl_fr,
          averageDd_mn,
          averageDd_tu,
          averageDd_we,
          averageDd_th,
          averageDd_fr,
          balance;
   char              symbol[100];
  };
//+------------------------------------------------------------------+
