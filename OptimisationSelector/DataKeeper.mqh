//+------------------------------------------------------------------+
//|                                                   DataKeeper.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Типы входных данных параметра робота                             |
//+------------------------------------------------------------------+
enum DataTypes
  {
   Type_INTEGER,// int
   Type_REAL,// double, float
   Type_Text // string
  };
//+------------------------------------------------------------------+
//| Результат сравнения двух CDataKeeper                             |
//+------------------------------------------------------------------+
enum CoefCompareResult
  {
   Coef_Different,// разные типы данных или же имена переменных
   Coef_Equal,// переменные равны
   Coef_Less, // переменная текущая меньше чем переданная
   Coef_More // переменная текущая большечем переданная
  };
//+---------------------------------------------------------------------+
//| Класс который зранит в себе один конкретный входной параметр робота.|
//| Может хранить в себе данные следующих типов : [int, double, string] |
//+---------------------------------------------------------------------+
class CDataKeeper
  {
public:
                     CDataKeeper(); // Конструктор
                     CDataKeeper(const CDataKeeper&other); // Конструктор копирования
                     CDataKeeper(string _variable_name,int _value); // Параметральный конструктор
                     CDataKeeper(string _variable_name,double _value); // Параметральный конструктор
                     CDataKeeper(string _variable_name,string _value); // Параметральный конструктор

   CoefCompareResult Compare(CDataKeeper &data); // Метод сравнения

   DataTypes         getType(){return variable_type;}; // Получуние типа данных
   string            getName(){return variable_name;}; // Получение имени параметра
   string            valueString(){return value_string;}; // Получение параметра
   int               valueInteger(){return value_int;}; // Получение параметра
   double            valueDouble(){return value_double;}; // Получение параметра
   string            ToString(); // Перевод любого параметра в строку. Если это строковый параметр, то к строке добавляются с обеих сторон одинарные ковычки <<'>>

private:
   string            variable_name,value_string; // имя переменной и строковая переменная
   int               value_int; // интовая переменная
   double            value_double; // Double переменная
   DataTypes         variable_type; // Тип переменной

   int compareDouble(double x,double y) // Сравнение типов Double с точностью до 10 знака
     {
      double diff=NormalizeDouble(x-y,10);
      if(diff>0) return 1;
      else if(diff<0) return -1;
      else return 0;
     }
  };
//+------------------------------------------------------------------+
//| Значение переменной ввиде строки                                 |
//+------------------------------------------------------------------+
string CDataKeeper::ToString()
  {
   switch(variable_type)
     {
      case Type_INTEGER : return IntegerToString(value_int); break;
      case Type_REAL : return DoubleToString(value_double); break;
      case Type_Text : return "'"+value_string+"'"; break;
      default: return "''";break;
     }
  }
//+------------------------------------------------------------------+
//| Уонструктор параметральный                                       |
//+------------------------------------------------------------------+
CDataKeeper::CDataKeeper(string _variable_name,string _value)
  {
   this.variable_name=_variable_name;
   this.value_string=_value;
   variable_type=Type_Text;
  };
//+------------------------------------------------------------------+
//| Уонструктор параметральный                                       |
//+------------------------------------------------------------------+
CDataKeeper::CDataKeeper(string _variable_name,double _value)
  {
   this.variable_name=_variable_name;
   this.value_double=_value;
   variable_type=Type_REAL;
  };
//+------------------------------------------------------------------+
//| Уонструктор параметральный                                       |
//+------------------------------------------------------------------+
CDataKeeper::CDataKeeper(string _variable_name,int _value)
  {
   this.variable_name=_variable_name;
   this.value_int=_value;
   variable_type = Type_INTEGER;
  };
//+------------------------------------------------------------------+
//| Уонструктор копирования                                          |
//+------------------------------------------------------------------+
CDataKeeper::CDataKeeper(const CDataKeeper&other)
  {
   variable_name= other.variable_name;
   variable_type= other.variable_type;
   value_int=other.value_int;
   value_double = other.value_double;
   value_string = other.value_string;
  }
//+------------------------------------------------------------------+
//| Уонструктор по умолчанию                                         |
//+------------------------------------------------------------------+
CDataKeeper::CDataKeeper()
  {
   variable_name = NULL;
   variable_type = NULL;
   value_int=NULL;
   value_double = NULL;
   value_string = NULL;
  }
//+------------------------------------------------------------------+
//| Функция получения имени Мьютекса исходя из пути к файлу с базой  |
//+------------------------------------------------------------------+
string getMutexName(const string name)
  {
   string s=name;
   StringReplace(s,"\\","_sep_");
   StringReplace(s,"/","_sep_");
   char arr[];
   StringToCharArray(s,arr);
   int n=0;
   for(int i=0;i<ArraySize(arr);i++)
     {
      n+=(int)arr[i];
     }
   return("Local\\mutex_"+IntegerToString(n));
  }
//+------------------------------------------------------------------+
//| Сравнение текущего параметра с переданным                        |
//+------------------------------------------------------------------+
CoefCompareResult CDataKeeper::Compare(CDataKeeper &data)
  {
   CoefCompareResult ans=Coef_Different;

   if(StringCompare(this. variable_name,data.getName())==0 && 
      this.variable_type==data.getType()) // Сравнение имени и типов
     {
      switch(this.variable_type) // Сравнение значений
        {
         case Type_INTEGER :
            ans=(this.value_int==data.valueInteger() ? Coef_Equal :(this.value_int>data.valueInteger() ? Coef_More : Coef_Less));
            break;
         case Type_REAL :
            ans=(compareDouble(this.value_double,data.valueDouble())==0 ? Coef_Equal :(compareDouble(this.value_double,data.valueDouble())>0 ? Coef_More : Coef_Less));
            break;
         case Type_Text :
            ans=(StringCompare(this.value_string,data.valueString())==0 ? Coef_Equal :(StringCompare(this.value_string,data.valueString())>0 ? Coef_More : Coef_Less));
            break;
        }
     }
   return ans;
  }
//+------------------------------------------------------------------+
