
Процедура ПередЗаписью(Отказ)
	
	Наименование = СтрШаблон("%1 (%2)", Контрагент.Наименование, НомерКарты);
	
КонецПроцедуры

Процедура ПриУстановкеНовогоКода(СтандартнаяОбработка, Префикс)
	
	ПрефиксБазы = Константы.отусПрефикс.Получить();
	Если ЗначениеЗаполнено(ПрефиксБазы) Тогда
		Префикс = ПрефиксБазы;
	КонецЕсли;	

КонецПроцедуры
