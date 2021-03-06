//+------------------------------------------------------------------+
//|                                                  ShortReport.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "ReportCreator.mqh"
//+------------------------------------------------------------------+
//| File writer                                                      |
//+------------------------------------------------------------------+
void writer(string fileName,string headder,string row)
  {
   bool isFile=FileIsExist(fileName,FILE_COMMON); // Флаг существует ли файл
   int file_handle=FileOpen(fileName,FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON|FILE_SHARE_WRITE|FILE_SHARE_READ); // Открываем файл
   if(file_handle) // Если файл открылся
     {
      FileSeek(file_handle,0,SEEK_END); // Перемещаем курсор в конец файла
      if(!isFile) // Еси это новосозданный фай - пишем заголовок
         FileWrite(file_handle,headder);
      FileWrite(file_handle,row); // Пишем сообщение
      FileClose(file_handle); // Закрываем файл
     }
  }

#define WRITE_BOT_PARAM(fileName,param) writer(fileName,"",#param+";"+(string)param);

//+------------------------------------------------------------------+
//| History saver                                                    |
//+------------------------------------------------------------------+
void SaveReportToFile(string fileName,CCCM *_comission_manager,datetime from = 0, datetime to = 0)
  {
   if(FileIsExist(fileName,FILE_COMMON))
     {
      FileDelete(fileName,FILE_COMMON);
     }

   if(to == 0)
      to = TimeCurrent();

   DealDetales history[];
   CDealHistoryGetter dealGetter(_comission_manager);
   dealGetter.getDealsDetales(history,from,to);

   if(ArraySize(history)==0)
      return;

   CReportCreator reportCreator(_comission_manager);
   reportCreator.Create(history,0);

   TotalResult totalResult;
   reportCreator.GetTotalResult(totalResult);
   PL_detales pl_detales;
   reportCreator.GetPL_detales(pl_detales);

   int total= ArraySize(history);
   for(int i=0; i<total; i++)
     {
      writer(fileName,
             "Symbol;DT open;Day open;DT close;Day close;Volume;Long/Short;Price in;Price out;PL for one lot;PL for deal;Open comment;Close comment;",
             history[i].symbol+";"+
             TimeToString(history[i].DT_open) + ";" +
             EnumToString(history[i].day_open) + ";" +
             TimeToString(history[i].DT_close) + ";" +
             TimeToString(history[i].day_close) + ";" +
             DoubleToString(history[i].volume)+";"+
             (history[i].isLong ? "Long" : "Short")+";"+
             DoubleToString(history[i].price_in) + ";" +
             DoubleToString(history[i].price_out) + ";" +
             DoubleToString(history[i].pl_oneLot) + ";" +
             DoubleToString(history[i].pl_forDeal) + ";" +
             history[i].open_comment + ";" +
             history[i].close_comment + ";");
     }

   writer(fileName,"","===========================================================================================================================================");
   writer(fileName,"","PL;"+DoubleToString(totalResult.total.PL)+";");
   int total_trades=pl_detales.total.profit.orders+pl_detales.total.drawdown.orders;
   writer(fileName,"","Total trdes;"+IntegerToString(total_trades));
   writer(fileName,"","Consecutive wins;"+IntegerToString(pl_detales.total.profit.dealsInARow));
   writer(fileName,"","Consecutive DD;"+IntegerToString(pl_detales.total.drawdown.dealsInARow));
   writer(fileName,"","Recovery factor;"+DoubleToString(totalResult.total.recoveryFactor)+";");
   writer(fileName,"","Profit factor;"+DoubleToString(totalResult.total.profitFactor)+";");
   double payoff=MathAbs(totalResult.total.averageProfit/totalResult.total.averageDD);
   writer(fileName,"","Payoff;"+DoubleToString(payoff)+";");
   writer(fileName,"","Drawвown by pl;"+DoubleToString(totalResult.total.maxDrawdown.byPL)+";");
  }
//+------------------------------------------------------------------+
