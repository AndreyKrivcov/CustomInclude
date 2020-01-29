//+------------------------------------------------------------------+
//|                                                SqliteManager.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "sqlite_amalgmation.mqh"
#include <WinApi/strcpy.mqh>
#include <WinApi/memcpy.mqh>
#include <WinApi/strlen.mqh>
typedef bool(*statement_callback)(sqlite3_stmt_p64); // коллбек выполняемый при исполнение запроса в случае успеха возвращает true
//+------------------------------------------------------------------+
//| Класс запроса к базе                                             |
//+------------------------------------------------------------------+
class CStatement
  {
public:
                     CStatement(){stmt=NULL;} // пустой конструктор
                     CStatement(sqlite3_stmt_p64 _stmt){this.stmt=_stmt;} // Конструктор с параметром - указатель на стейтмент
                    ~CStatement(void){if(stmt!=NULL)Sqlite3_finalize(stmt);} // Деструктор
   sqlite3_stmt_p64 get(){return stmt;} // Полечить указатель на стейтмент
   void              set(sqlite3_stmt_p64 _stmt); // Установка указателя на стейтмент

   bool              Execute(statement_callback callback=NULL); // Исполнение стейтмента
   bool              Parameter(int index,const long value); // Добавление параметра
   bool              Parameter(int index,const double value); // Добавление параметра
   bool              Parameter(int index,const string value); // Добавление параметра

private:
   sqlite3_stmt_p64  stmt;
  };
//+------------------------------------------------------------------+
//| Класс соединения и управление базой                              |
//+------------------------------------------------------------------+
class CSqliteManager
  {
public:
                     CSqliteManager(){db=NULL;} // Пустой конструктор
                     CSqliteManager(string dbName); // Передается имя
                     CSqliteManager(string dbName,int flags,string zVfs); // Передается имя и флаги соединения
                     CSqliteManager(CSqliteManager  &other) { db=other.db; } // Конструктор копирования
                    ~CSqliteManager(){Disconnect();};// Деструктор

   void              Disconnect(); // Отключение от базы
   bool              Connect(string dbName,int flags,string zVfs); // Параметральное подключение к базе
   bool              Connect(string dbName); // Подключение к базе по имени

   void operator=(CSqliteManager  &other){db=other.db;}// Оператор присвоения

   sqlite3_p64 DB() { return db; }; // Получение указателя на базу

   sqlite3_stmt_p64  Create_statement(const string sql); // Создать стейтмент
   bool              Execute(string sql); // Исполнить команду
   void              Execute(string  sql,int &result_code,string &errMsg); // Исполнить команду и выдать код ошибки и сообщение ошибки

   void              BeginTransaction(); // Начало транзакции
   void              RollbackTransaction(); // Откат транзакции
   void              CommitTransaction(); // Подтверждение транзакции

private:
   sqlite3_p64       db; // База

   void stringToUtf8(const string strToConvert,// Строка, которую необходимо преобразовать в массив в кодировке utf-8
                     uchar &utf8[],// Массив в кодировке utf-8, в который будет помещена преобразованная строка strToConvert
                     const bool untilTerminator=true)
     {    // Количество символов, которые будут скопированы в массив utf8 и соот-но преобразованны в кодировку utf-8
      //---
      int count=untilTerminator ? -1 : StringLen(strToConvert);
      StringToCharArray(strToConvert,utf8,0,count,CP_UTF8);
     }
  };
//+------------------------------------------------------------------+
//| Отключение                                                       |
//+------------------------------------------------------------------+
void CSqliteManager::Disconnect(void)
  {
   if(db!=NULL)
     {
      int n=0;
      if((n=Sqlite3_close(db))==SQLITE_OK)
        {
         this.db=NULL;
         Print("Database disconnected");
        }
      else printErrorStatus(n);
     }
  }
//+------------------------------------------------------------------+
//| Подключение                                                      |
//+------------------------------------------------------------------+
bool CSqliteManager::Connect(string dbName)
  {
   Disconnect();
   uchar name[];
   stringToUtf8(dbName,name); // Получение верного имени

   int rc=Sqlite3_open(name,db); // Подключение

   bool ans=true;

   if(rc!=SQLITE_OK) // Если ошибка
     {
      ans=false;
      printErrorStatus(rc);
      db=NULL;
     }
   else
      Print("Database connected");
   return ans;
  }
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CSqliteManager::CSqliteManager(string dbName)
  {
   Connect(dbName);
  }
//+------------------------------------------------------------------+
//| Подключение параметральное                                       |
//+------------------------------------------------------------------+
bool CSqliteManager::Connect(string dbName,int flags,string zVfs)
  {
   Disconnect();
   uchar name[],_zVfs[];
   stringToUtf8(dbName,name); // Получение имени
   StringToCharArray(zVfs,_zVfs); // Флаги

   int rc=Sqlite3_open_v2(name,db,flags,_zVfs); // подключение

   bool ans=true;
   if(rc!=SQLITE_OK) // Если ошибка
     {
      ans=false;
      printErrorStatus(rc);
      db=NULL;
     }
   else
      Print("Database connected");
   return ans;
  }
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CSqliteManager::CSqliteManager(string dbName,int flags,string zVfs)
  {
   Connect(dbName,flags,zVfs);
  }
//+------------------------------------------------------------------+
//| Создание запроса                                                 |
//+------------------------------------------------------------------+
sqlite3_stmt_p64 CSqliteManager::Create_statement(const string sql)
  {
   sqlite3_stmt_p64 stmt=NULL;
   PTRPTR64 ptr=NULL;

   uchar sql_s[];
   StringToCharArray(sql,sql_s);
   int rc=Sqlite3_prepare_v2(db,
                             sql_s,ArraySize(sql_s),
                             stmt,ptr); // Получение указателя на запрос
   if(rc!=SQLITE_OK) // Если ошибка
     {
      stmt=NULL;
      printErrorStatus(rc);
     }

   return stmt;
  }
//+------------------------------------------------------------------+
//| Исполнение запроса                                               |
//+------------------------------------------------------------------+
bool CSqliteManager::Execute(string sql)
  {
   int rc=0;
   string s;
   Execute(sql,rc,s);
   if(s!=NULL)
      Print(s);
   return rc == SQLITE_OK;
  }
//+------------------------------------------------------------------+
//| Исполнение запроса                                               |
//+------------------------------------------------------------------+
void CSqliteManager::Execute(string sql,int &result_code,string &errMsg)
  {
   uchar sql_s[];
   StringToCharArray(sql,sql_s);
   PTRPTR64 ptr=NULL;
   result_code=Sqlite3_exec(db,sql_s,0,0,ptr);
   if(ptr!=NULL)
     {
      uchar arr_s[];
      ArrayResize(arr_s,strlen(ptr));
      strcpy(arr_s,ptr);
      errMsg=CharArrayToString(arr_s);
     }
  }
//+------------------------------------------------------------------+
//| Функция исполняющая коллбек во время чтения базы                 |
//+------------------------------------------------------------------+
bool step_next(int rc,bool &ans,statement_callback callback,sqlite3_stmt_p64 stmt)
  {
   if(!ans)ans=true;
   if(rc==SQLITE_OK || rc==SQLITE_DONE)
      return false;
   else if(rc==SQLITE_ROW)
     {
      if(callback)
         return callback(stmt); // Исполнение коллбека если таковой был передан
     }
   else
     {
      ans=false;
      printErrorStatus(rc);
     }
   return false;
  };
//+------------------------------------------------------------------+
//| Исполнение запроса                                               |
//+------------------------------------------------------------------+
bool CStatement::Execute(statement_callback callback)
  {
   bool ans = false;
   if(stmt != NULL)
     {
      while(step_next(Sqlite3_step(stmt),ans,callback,stmt)); // Цикл читающий построчно результат ответа базы и исполнящий коллбек
     }
   int rc = Sqlite3_reset(stmt);
   if(rc != SQLITE_OK)
      printErrorStatus(rc);
   return ans;
  }
//+------------------------------------------------------------------+
//| Вставка параметратипа long                                       |
//+------------------------------------------------------------------+
bool CStatement::Parameter(int index,const long value)
  {
   if(stmt!=NULL)
     {
      int rc=Sqlite3_bind_int64(stmt,index,value);
      return rc == SQLITE_OK;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
//| Вставка параметра типа double                                    |
//+------------------------------------------------------------------+
bool CStatement::Parameter(int index,const double value)
  {
   if(stmt!=NULL)
     {
      int rc=Sqlite3_bind_double(stmt,index,value);
      return rc == SQLITE_OK;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
//| Вставка параметра типа string                                    |
//+------------------------------------------------------------------+
bool CStatement::Parameter(int index,const string value)
  {
   if(stmt!=NULL)
     {
      uchar value_arr[];
      StringToCharArray(value,value_arr);

      char arr[];
      StringToCharArray(value,arr);

      int rc=Sqlite3_bind_text(stmt,index,
                               arr,ArraySize(value_arr)-1,
                               SQLITE_TRANSIENT);

      return rc == SQLITE_OK;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CStatement::set(long _stmt)
  {
 //  if(this.stmt!=NULL)Sqlite3_finalize(this.stmt); // Завершение прошлого стейтмента
   this.stmt=_stmt;
  }
//+------------------------------------------------------------------+
//| Начало транзакции                                                |
//+------------------------------------------------------------------+
void CSqliteManager::BeginTransaction()
  {
   if(db!=NULL)
      Execute("BEGIN TRANSACTION;");
  }
//+------------------------------------------------------------------+
//| Отмена транзакции                                                |
//+------------------------------------------------------------------+
void CSqliteManager::RollbackTransaction()
  {
   if(db!=NULL)
      Execute("ROLLBACK TRANSACTION;");
  }
//+------------------------------------------------------------------+
//| Подтверждение транзакции                                         |
//+------------------------------------------------------------------+
void CSqliteManager::CommitTransaction()
  {
   if(db!=NULL)
      Execute("COMMIT TRANSACTION;");
  }
//+------------------------------------------------------------------+
