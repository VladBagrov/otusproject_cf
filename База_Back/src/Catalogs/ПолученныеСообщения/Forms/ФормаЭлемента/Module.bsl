
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		ТекстСообщения = РаботаСRMQ.ПолучитьJSONСообщенияСправочника(Объект.Ссылка);
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьСообщениеНаСервере()
	
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		РаботаСRMQ.ПрочитатьJSONОбъекта(Объект.ИмяОчереди, Объект.ТекстСообщения);  
	Иначе
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Необходимо записать элемент справочника.";
		Сообщение.Сообщить();
	КонецЕсли;	

КонецПроцедуры

&НаКлиенте
Процедура ОбработатьСообщение(Команда)
	ОбработатьСообщениеНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	ПередЗаписьюСервер(ТекстСообщения);
	
КонецПроцедуры    

&НаСервере
Процедура ПередЗаписьюСервер(ТекстСообщения)
	
	ТекОбъект = РеквизитФормыВЗначение("Объект");
	ТекОбъект.ЗаписатьТекстСообщения(ТекстСообщения);
	ЗначениеВРеквизитФормы(ТекОбъект, "Объект");
	
КонецПроцедуры	
