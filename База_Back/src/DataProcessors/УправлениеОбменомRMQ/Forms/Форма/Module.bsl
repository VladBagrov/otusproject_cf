&НаСервере
Перем КлиентКомпоненты;


&НаСервере
Процедура ПроверитьПодключениеНаСервере() 
	
	Если РаботаСRMQ.ПроверитьПодключениеПоНастройкамПодключения(Объект.НастройкаПодключения) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Компонента подключена. Соединение успешно.";
		Сообщение.Сообщить();
	Иначе
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Соединение не установлено.";
		Сообщение.Сообщить();
	КонецЕсли;	
		
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьПодключение(Команда)
	
	ПроверитьПодключениеНаСервере(); 
	
КонецПроцедуры

&НаСервере
Процедура ВыполнитьОтправкуНаСервере()
	
	НастройкаПодключения = ?(ЗначениеЗаполнено(Объект.НастройкаПодключения), Объект.НастройкаПодключения, Неопределено);
	
	Если РаботаСRMQ.ВыполнитьОтправкуСообщенийПоНастройкамПодключения(НастройкаПодключения) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Сообщения обмена успешно отправлены.";
		Сообщение.Сообщить();
	Иначе
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Были ошибки отправки.";
		Сообщение.Сообщить();
	КонецЕсли;	
		
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьОтправку(Команда)
	ВыполнитьОтправкуНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПрочитатьСообщенияНаСервере()  
	
	Если РаботаСRMQ.ВыполнитьПолучениеСообщенийПоНастройкамПодключения(Объект.НастройкаПодключения) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Сообщения обмена успешно получены.";
		Сообщение.Сообщить();
	Иначе
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Были ошибки получения.";
		Сообщение.Сообщить();
	КонецЕсли;	
		
КонецПроцедуры

&НаКлиенте
Процедура ПрочитатьСообщения(Команда)
	ПрочитатьСообщенияНаСервере();
КонецПроцедуры
