
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

    ЗаполнитьОбъектыДляВыгрузки(Метаданные.Справочники, "Справочник");	
	ЗаполнитьОбъектыДляВыгрузки(Метаданные.Документы, "Документ"); 
	ЗаполнитьОбъектыДляВыгрузки(Метаданные.РегистрыСведений, "РегистрСведений");
		
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		ИмяОбъекта = СтрРазделить(Объект.Объект, ".")[1];
		
		Если СтрНайти(Объект.Объект, "Документ") <> 0 Тогда
			ПолноеИмя = СтрШаблон("Документ.%1", ИмяОбъекта);
			Реквизиты = Метаданные.НайтиПоПолномуИмени(ПолноеИмя).Реквизиты;
 		ИначеЕсли СтрНайти(Объект.Объект, "Справочник") <> 0 Тогда
			ПолноеИмя = СтрШаблон("Справочник.%1", ИмяОбъекта); 
			Реквизиты = Метаданные.НайтиПоПолномуИмени(ПолноеИмя).Реквизиты;
		Иначе
			ПолноеИмя = СтрШаблон("РегистрСведений.%1", ИмяОбъекта);
			Реквизиты = Метаданные.НайтиПоПолномуИмени(ПолноеИмя).Измерения;
        КонецЕсли;	
				
		СтандартныеРеквизиты = Метаданные.НайтиПоПолномуИмени(ПолноеИмя).СтандартныеРеквизиты; 
		Для каждого ТекРеквизит Из СтандартныеРеквизиты Цикл
			Элементы.Таблица1Реквизит.СписокВыбора.Добавить(ТекРеквизит.Имя); 	
		КонецЦикла; 
		
		Для каждого ТекРеквизит Из Реквизиты Цикл
			Элементы.Таблица1Реквизит.СписокВыбора.Добавить(ТекРеквизит.Имя); 	
		КонецЦикла;

	КонецЕсли;	
	
КонецПроцедуры  


&НаСервере
Процедура ЗаполнитьОбъектыДляВыгрузки(МетаданныеОбъекты, ТипОбъекта)
	
	Для каждого ТекДокумент Из МетаданныеОбъекты Цикл
		Если СтрНайти(ТипОбъекта, "Регистр") <> 0 Тогда  
			Элементы.Объект.СписокВыбора.Добавить(СтрШаблон("%1.%2", ТипОбъекта, ТекДокумент.Имя));	
		Иначе	
			Элементы.Объект.СписокВыбора.Добавить(СтрШаблон("%1Объект.%2", ТипОбъекта, ТекДокумент.Имя));
		КонецЕсли;	
	КонецЦикла;
	
КонецПроцедуры	

&НаКлиенте
Процедура Таблица1РеквизитПриИзменении(Элемент)
	
	ТекДанные = Элементы.Реквизиты.ТекущиеДанные;
	Таблица1РеквизитПриИзмененииСервер(ТекДанные.Реквизит);
	
КонецПроцедуры  

&НаСервере
Процедура Таблица1РеквизитПриИзмененииСервер(Реквизит)
	
	ИмяОбъекта = СтрРазделить(Объект.Объект, ".")[1];

	Если СтрНайти(Объект.Объект, "Документ") <> 0 Тогда
		ПолноеИмя = СтрШаблон("Документ.%1", ИмяОбъекта);
	ИначеЕсли СтрНайти(Объект.Объект, "Справочник") <> 0 Тогда
		ПолноеИмя = СтрШаблон("Справочник.%1", ИмяОбъекта); 
	Иначе
		ПолноеИмя = СтрШаблон("РегистрСведений.%1", ИмяОбъекта);
	КонецЕсли;
	
	ТекРеквизит = ЭтоСтандартныйРеквизит(ПолноеИмя, Реквизит);
	
	Если ТекРеквизит = Неопределено Тогда
		Если СтрНайти(Объект.Объект, "Регистр") <> 0 Тогда  
			ТекРеквизит = Метаданные.НайтиПоПолномуИмени(ПолноеИмя).Измерения.Найти(Реквизит);
		Иначе	
			ТекРеквизит = Метаданные.НайтиПоПолномуИмени(ПолноеИмя).Реквизиты.Найти(Реквизит);
		КонецЕсли; 
	КонецЕсли;	
	
	ТипРеквизита = ТекРеквизит.Тип;
	
	Элементы.Таблица1Значение.ОграничениеТипа = ТипРеквизита;
	
КонецПроцедуры	 

Функция ЭтоСтандартныйРеквизит(ПолноеИмя, Реквизит)
	
	СтандартныеРеквизиты = Метаданные.НайтиПоПолномуИмени(ПолноеИмя).СтандартныеРеквизиты;
	Для каждого СтРеквизит Из СтандартныеРеквизиты Цикл
		Если СтРеквизит.Имя = Реквизит Тогда
			
			Возврат СтРеквизит;
			
		КонецЕсли;	
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции	
