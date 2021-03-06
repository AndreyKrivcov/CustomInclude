//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "ICustomComparer.mqh"
//+------------------------------------------------------------------+
//| E-num со стилем сортировки                                       |
//+------------------------------------------------------------------+
enum SortMethod
  {
   Sort_Ascending,//По возрастанию
   Sort_Descendingly//По убыванию
  };
//+------------------------------------------------------------------+
//| Класс сортирующий переданный тип данных                          |
//+------------------------------------------------------------------+
class CGenericSorter
  {
public:
   // Конструктор поумолчанию
                     CGenericSorter() {method=Sort_Descendingly;}
   // Сортирующий метод
   template<typename T>
   void              Sort(T &out[],ICustomComparer<T>*comparer)
   {
      int j=0;
      int total=ArraySize(out);
      for(int i=0; i<total; i++)
        {
         j=i;
         for(int k=i; k<total; k++)
           {
            int cmp=comparer.Compare(out[j],out[k]);
            bool cond=false;
            if(cmp!=0 && cmp!=1 && cmp!=-1)
               continue;
            else
              {
               if(method==Sort_Ascending)
                  cond=cmp>=0;
               else
                  cond=cmp<=0;
              }
            if(cond)
              {
               j=k;
              }
           }
         T tmp=out[i];
         out[i]=out[j];
         out[j]=tmp;
        }
   }
   template<typename T>
   void              QuickSort(T &out[], ICustomComparer<T>*comparer, int len)
   {
      int const lenD = len;
      T pivot;
      int ind = lenD/2;
      int i,j = 0,k = 0;
      if(lenD>1)
        {
         T L[];
         ArrayResize(L,lenD);
         T R[];
         ArrayResize(R,lenD);
         pivot = out[ind];
         for(i=0; i<lenD; i++)
           {
            if(i!=ind)
              {
               int cond = comparer.Compare(out[i],pivot);
               if((method == Sort_Ascending ? cond<=0 : cond >=0))
                 {
                  L[j] = out[i];
                  j++;
                 }
               else
                 {
                  R[k] = out[i];
                  k++;
                 }
              }
           }
         QuickSort(L,comparer,j);
         QuickSort(R,comparer,k);
         for(int cnt=0; cnt<lenD; cnt++)
           {
            if(cnt<j)
              {
               out[cnt] = L[cnt];;
              }
            else
               if(cnt==j)
                 {
                  out[cnt] = pivot;
                 }
               else
                 {
                  out[cnt] = R[cnt-(j+1)];
                 }
           }
        }
   }

   // Выбор способа сортировки
   void              Method(SortMethod _method) {method=_method;}
   // Получение способа сортировки
   SortMethod        Method() {return method;}
private:
   // Способ сортировки
   SortMethod        method;
  };
//+------------------------------------------------------------------+
//| Сортирующий метод                                                |
//| был заимствован с сайта:                                         |
//| https://function-x.ru/cpp_algoritmy_sortirovki.html              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
