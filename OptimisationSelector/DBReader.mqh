//+------------------------------------------------------------------+
//|                                                 SqliteReader.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Sqlite3/SqliteManager.mqh>
#include <Sqlite3/SqliteReader.mqh>
#include <History manager/ReportCreator.mqh>
#include <WinApi/Mutex.mqh>
#include "DataKeeper.mqh"
//+------------------------------------------------------------------+
//| Структура - Хранит в сеюе i-тый срез графика Buy And Hold        |
//+------------------------------------------------------------------+
struct BuyAndHoldChart_item
  {
   ProfitDrawdown    total,oneLot;
   datetime          DT;
  };
//+------------------------------------------------------------------+
//| Структура - хранит в себе характеристику определенного параметра |
//+------------------------------------------------------------------+
struct ParamType_item
  {
   DataTypes         paramType;
   string            paramName;
  };
//+------------------------------------------------------------------+
//| Структура - хранит в себе оценочные коэфиценты                   |
//+------------------------------------------------------------------+
struct Coef_item
  {
   double            PL,DD,averagePL,averageDD,averageProfit,profitFactor,recoveryFactor,sharpRatio,altman_Z_Score;
   double            VaR_absolute_90,VaR_absolute_95,VaR_absolute_99,VaR_growth_90,VaR_growth_95,VaR_growth_99;
   double            winCoef,customCoef;
  };
//+------------------------------------------------------------------+
//| Структура - Хранит параметры робота, таймфрейм оптимизации       |
//| А также оценочные коэфиценты                                     |
//+------------------------------------------------------------------+
struct CoefData_item
  {
   CDataKeeper       params[];
   ENUM_TIMEFRAMES   TF;
   long              ID;
   double            balance;
   Coef_item         total,oneLot;
  };
//+------------------------------------------------------------------+
//| Класс считывающий данные из базы                                 |
//+------------------------------------------------------------------+
class CDBReader
  {
public:
   void              Connect(string DBPath);//Метод - подкллючающийся к базе

   bool              getBuyAndHold(BuyAndHoldChart_item &data[],bool isForvard);//Метод считывающий историю Buy And Hold 
   bool              getTraidingHistory(DealDetales &data[],long ID,bool isForvard);//Метод считывающий наторгованную роботом историю 
   bool              getRobotParams(CoefData_item &data[],bool isForvard);//Метод считывающий параметры робота и коэфиценты

private:
   CSqliteManager    dbManager; // Менеджер базы данных 
   string            DBPath; // Путь к базе

   bool              getParamTypes(ParamType_item &data[]);// Считывает типы входных параметров и их имена.
  };
//+------------------------------------------------------------------+
//| Подключение                                                      |
//+------------------------------------------------------------------+
void CDBReader::Connect(string _DBPath)
  {
   CMutexSync sync; // сам объект синронизации 
   if(!sync.Create(getMutexName(_DBPath))) { Print(Symbol()+" MutexSync create ERROR!"); return; }
   CMutexLock lock(sync,(DWORD)INFINITE); // лочим участок в этих скобках

   dbManager.Disconnect(); // Отключаемся если ранее были подключены
   dbManager.Connect(_DBPath,SQLITE_OPEN_READONLY|SQLITE_OPEN_NOMUTEX|SQLITE_OPEN_SHAREDCACHE,NULL); //Подключаемся по вновь переданному пути
   this.DBPath=_DBPath;// Сохраняем путь
  }
//+------------------------------------------------------------------+
//| Получение истории Buy and Hold                                   |
//+------------------------------------------------------------------+
bool CDBReader::getBuyAndHold(BuyAndHoldChart_item &data[],bool isForvard)
  {
   CMutexSync sync; // сам объект синронизации 
   if(!sync.Create(getMutexName(DBPath))) { Print(Symbol()+" MutexSync create ERROR!"); return false; }
   CMutexLock lock(sync,(DWORD)INFINITE); // лочим участок в этих скобках

   ArrayFree(data);
   CStatement stmt(dbManager.Create_statement("SELECT Time,PL_total,PL_oneLot,DD_total,DD_oneLot FROM BuyAndHold WHERE isForvard = "+(isForvard ? "1" : "0")+" ORDER BY Time;")); // Формируем запрос
   CSqliteReader reader(stmt.get()); // Создаем ридер

   while(reader.Read()) // Читаем пока есть строки
     {
      BuyAndHoldChart_item item;
      item.DT=(datetime)reader.GetInt64(0);
      item.total.Profit=reader.GetDouble(1);
      item.total.Drawdown= reader.GetDouble(3);
      item.oneLot.Profit = reader.GetDouble(2);
      item.oneLot.Drawdown=reader.GetDouble(4);

      int s=ArraySize(data);
      ArrayResize(data,s+1,s+1);
      data[s]=item; // сохраняем строки
     }

   return ArraySize(data) > 0;
  }
//+------------------------------------------------------------------+
//| Получение типов параметров                                       |
//+------------------------------------------------------------------+
bool CDBReader::getParamTypes(ParamType_item &data[])
  {
   CMutexSync sync; // сам объект синронизации 
   if(!sync.Create(getMutexName(DBPath))) { Print(Symbol()+" MutexSync create ERROR!"); return false; }
   CMutexLock lock(sync,(DWORD)INFINITE); // лочим участок в этих скобках

   ArrayFree(data); // Освобождаем массив
   CStatement stmt(dbManager.Create_statement("SELECT * FROM ParamsType;")); // Создаем запрос
   CSqliteReader reader(stmt.get()); // Создаем ридер

   while(reader.Read()) // Читаем пока есть строки и заполняем данные
     {
      ParamType_item item;
      item.paramName = reader.GetText(0);
      item.paramType = (DataTypes)reader.GetInt64(1);

      int s=ArraySize(data);
      ArrayResize(data,s+1,s+1);
      data[s]=item;
     }

   return ArraySize(data)>0; // Проверяем пустой ли массив
  }
//+------------------------------------------------------------------+
//| Загрузка торговой истории                                        |
//+------------------------------------------------------------------+
bool CDBReader::getTraidingHistory(DealDetales &data[],long ID,bool isForvard)
  {
   CMutexSync sync; // сам объект синронизации 
   if(!sync.Create(getMutexName(DBPath))) { Print(Symbol()+" MutexSync create ERROR!"); return false; }
   CMutexLock lock(sync,(DWORD)INFINITE); // лочим участок в этих скобках

   ArrayFree(data);
   CStatement stmt(dbManager.Create_statement("SELECT Symbol,DT_open,Day_open,DT_close,"+
                   "Day_close,Volume,isLong,Price_in,Price_out,PL_oneLot,PL_forDeal,"+
                   "OpenComment,CloseComment FROM TradingHistory WHERE ID = "+IntegerToString(ID)+
                   " AND isForvard = "+(isForvard ? "1" : "0")+";")); // Формируем запрос
   CSqliteReader reader(stmt.get()); // Создаем ридер

   while(reader.Read()) // Читаем пока есть строки и добавляем в массив
     {
      DealDetales item;
      item.DT_close= (datetime)reader.GetInt64(3);
      item.DT_open = (datetime)reader.GetInt64(1);
      item.close_comment=reader.GetText(12);
      item.day_close= (ENUM_DAY_OF_WEEK)reader.GetInt64(4);
      item.day_open = (ENUM_DAY_OF_WEEK)reader.GetInt64(2);
      item.isLong=(reader.GetInt64(6)==1);
      item.open_comment=reader.GetText(11);
      item.pl_forDeal=reader.GetDouble(10);
      item.pl_oneLot=reader.GetDouble(9);
      item.price_in=reader.GetDouble(7);
      item.price_out=reader.GetDouble(8);
      item.symbol=reader.GetText(0);
      item.volume=reader.GetDouble(5);

      int s=ArraySize(data);
      ArrayResize(data,s+1,s+1);
      data[s]=item;
     }

   return ArraySize(data) > 0;
  }
//+------------------------------------------------------------------+
//| Получение параметровробота                                       |
//+------------------------------------------------------------------+
bool CDBReader::getRobotParams(CoefData_item &data[],bool isForvard)
  {
   CMutexSync sync; // сам объект синронизации 
   if(!sync.Create(getMutexName(DBPath))) { Print(Symbol()+" MutexSync create ERROR!"); return false; }
   CMutexLock lock(sync,(DWORD)INFINITE); // лочим участок в этих скобках

   ArrayFree(data);
   ParamType_item params[];
   if(getParamTypes(params)) // Получение типов параметров и из имен
     {
      int params_size=ArraySize(params);
      string query="SELECT ID,TF,InitalBalance";
      for(int i=0;i<params_size;i++)
         query+=","+params[i].paramName;
      query+=" FROM OptimisationParams;"; // Запрос на получение параметров
      CStatement stmt(dbManager.Create_statement(query));
      CSqliteReader reader(stmt.get());

      while(reader.Read()) // Читаем ответ от базы построчно и заполняем параметры
        {
         CoefData_item item;
         item.ID = reader.GetInt64(0);
         item.TF = (ENUM_TIMEFRAMES)reader.GetInt64(1);
         item.balance=reader.GetDouble(2);
         ArrayResize(item.params,params_size);
         // Цикл по самим параметрам
         for(int i=0;i<params_size;i++)
           {
            switch(params[i].paramType)
              {
               case Type_INTEGER :
                 {
                  CDataKeeper _item(params[i].paramName,(int)reader.GetInt64(i+3));
                  item.params[i]=_item;
                 }
               break;
               case Type_REAL:
                 {
                  CDataKeeper _item(params[i].paramName,reader.GetDouble(i+3));
                  item.params[i]=_item;
                 }
               break;
               case Type_Text :
                 {
                  CDataKeeper _item(params[i].paramName,reader.GetText(i+3));
                  item.params[i]=_item;
                 }
               break;
              }
           }

         string query_2="SELECT * FROM ParamsCoefitients WHERE  ID = "+IntegerToString(item.ID)+" AND isForvard = "+(isForvard ? "1":"0")+";"; // Запрос на получение коэфицентов
         CStatement stmt_2(dbManager.Create_statement(query_2));
         CSqliteReader reader_2(stmt_2.get());

         bool isValue=false;
         while(reader_2.Read()) // Читаем построчно и заполняем коэфиценты
           {
            if(!isValue) isValue=true;
            Coef_item item_coef;
            item_coef.DD = reader_2.GetDouble(4);
            item_coef.PL = reader_2.GetDouble(3);
            item_coef.VaR_absolute_90 = reader_2.GetDouble(12);
            item_coef.VaR_absolute_95 = reader_2.GetDouble(13);
            item_coef.VaR_absolute_99 = reader_2.GetDouble(14);
            item_coef.VaR_growth_90 = reader_2.GetDouble(15);
            item_coef.VaR_growth_95 = reader_2.GetDouble(16);
            item_coef.VaR_growth_99 = reader_2.GetDouble(17);
            item_coef.altman_Z_Score= reader_2.GetDouble(11);
            item_coef.averageDD = reader_2.GetDouble(6);
            item_coef.averagePL = reader_2.GetDouble(5);
            item_coef.averageProfit=reader_2.GetDouble(7);
            item_coef.customCoef=reader_2.GetDouble(19);
            item_coef.profitFactor=reader_2.GetDouble(8);
            item_coef.recoveryFactor=reader_2.GetDouble(9);
            item_coef.sharpRatio=reader_2.GetDouble(10);
            item_coef.winCoef=reader_2.GetDouble(18);

            if(reader_2.GetInt64(2)==1)
               item.oneLot=item_coef;
            else
               item.total=item_coef;
           }
           int _rows;
         if(!isValue)
         {
         _rows = reader_2.FieldsCount();
         }

         if(isValue) // Если были получены оценочные коэфиценты для данного ID - то созраняем из в массив.
           {
            int s=ArraySize(data);
            ArrayResize(data,s+1,s+1);
            data[s]=item;
           }
        }
     }

   return ArraySize(data) > 0;
  }
//+------------------------------------------------------------------+
