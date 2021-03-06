//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "ShortReport.mqh"

//+------------------------------------------------------------------+
//| Добавление к строке нового значения и разделителя                |
//+------------------------------------------------------------------+
void AddRow(string item, string &str)
  {
   str += (item + ";");
  }

//+------------------------------------------------------------------+
//| Запись отчета сделок                                             |
//+------------------------------------------------------------------+
void WriteDetalesReport(string fileName,CCCM *_comission_manager)
  {

// Удаляем старый файл
   if(FileIsExist(fileName,FILE_COMMON))
     {
      FileDelete(fileName,FILE_COMMON);
     }

// Получаем данные истории торгов
   CDealHistoryGetter dealGetter(_comission_manager);

   DealKeeper deals[];
   dealGetter.getHistory(deals,0,TimeCurrent());

   int total= ArraySize(deals);

// Создаем заголовки
   string headder = "Asset;From;To;Deal DT (Unix seconds); Deal DT (Unix miliseconds);"+
                    "ENUM_DEAL_TYPE;ENUM_DEAL_ENTRY;ENUM_DEAL_REASON;Volume;Price;Comission;"+
                    "Profit;Symbol;Comment";

// Цикл по позициям
   for(int i=0; i<total; i++)
     {
      DealKeeper selected = deals[i];
      string asset = selected.symbol;
      datetime from = selected.DT_min;
      datetime to = selected.DT_max;

      // Цикл по сделкам
      for(int j=0; j<ArraySize(selected.deals); j++)
        {
         string row;
         AddRow(asset,row);
         AddRow((string)from,row);
         AddRow((string)to,row);

         AddRow((string)selected.deals[j].DT,row);
         AddRow((string)selected.deals[j].DT_msc,row);
         AddRow(EnumToString(selected.deals[j].type),row);
         AddRow(EnumToString(selected.deals[j].entry),row);
         AddRow(EnumToString(selected.deals[j].reason),row);
         AddRow((string)selected.deals[j].volume,row);
         AddRow((string)selected.deals[j].price,row);
         AddRow((string)selected.deals[j].comission,row);
         AddRow((string)selected.deals[j].profit,row);
         AddRow(selected.deals[j].symbol,row);
         AddRow(selected.deals[j].comment,row);

         // Записываем результаты+
         writer(fileName,headder,row);

        }

      // Вставляем пробел
      writer(fileName,headder,"");
     }


  }
//+------------------------------------------------------------------+
