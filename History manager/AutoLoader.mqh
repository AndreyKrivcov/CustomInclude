//+------------------------------------------------------------------+
//|                                                   AutoLoader.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "XmlHistoryWriter.mqh"

//+------------------------------------------------------------------+
//| Класс выгружающий отчет в XML формате                            |
//| автоматически по завершению тестирования.                        |
//+------------------------------------------------------------------+
class CAutoUploader
  {
private:

   datetime          From,Till; // даты начала и завершения тестирования
   CCCM              *comission_manager; // Менеджер комиссий
   BotParams         params[]; // Список параметров
   string            mutexName; // Имя мьютекса
   TCustomFilter     custom_filter;

public:
                     CAutoUploader(CCCM *comission_manager, string mutexName, BotParams &params[], 
                                   TCustomFilter filter);
                     CAutoUploader(CCCM *comission_manager, string mutexName, BotParams &params[]);
   virtual          ~CAutoUploader(void);

   virtual void      OnTick(); // Подсчет дат начала и завершения тестирования

  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Метод подсчитывающий даты началаи завершения                     |
//| процесса тестирования                                            |
//+------------------------------------------------------------------+
void CAutoUploader::OnTick(void)
  {
   if(MQLInfoInteger(MQL_OPTIMIZATION)==1 ||
      MQLInfoInteger(MQL_TESTER)==1)
     {
      if(From == 0)
         From = iTime(_Symbol,PERIOD_M1,0);
      Till=iTime(_Symbol,PERIOD_M1,0);
     }
  }

//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CAutoUploader::CAutoUploader(CCCM *_comission_manager,string _mutexName,BotParams &_params[], TCustomFilter filter) : comission_manager(_comission_manager),
   mutexName(_mutexName),
   From(0),
   Till(0),
   custom_filter(filter)
  {
   CopyBotParams(params,_params);
  }
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CAutoUploader::CAutoUploader(CCCM *_comission_manager,string _mutexName,BotParams &_params[]) : comission_manager(_comission_manager),
   mutexName(_mutexName),
   From(0),
   Till(0),
   custom_filter(EmptyCustomCoefCallback)
  {
   CopyBotParams(params,_params);
  }
//+------------------------------------------------------------------+
//| Деструктор                                                       |
//+------------------------------------------------------------------+
CAutoUploader::~CAutoUploader(void)
  {
   if(MQLInfoInteger(MQL_OPTIMIZATION)==1 ||
      MQLInfoInteger(MQL_TESTER)==1)
     {
      CXmlHistoryWriter historyWriter(mutexName,
                                      comission_manager,
                                      custom_filter);

      historyWriter.Write(params,From,Till);
     }
  }
//+------------------------------------------------------------------+
