
&НаСервере
Функция СохранитьНаСервере()
	
	Карта = Неопределено;
			
	Если Не ЗначениеЗаполнено(Справочники.отусВиртуальныеКарты.НайтиКарту(Телефон).Карта) Тогда  
		Попытка
			НачатьТранзакцию();
			Контрагент = Справочники.Контрагенты.СоздатьЭлемент();
			Контрагент.Родитель = Справочники.Контрагенты.НайтиПоНаименованию("Физ лица"); 
			Контрагент.Фамилия = Фамилия;
			Контрагент.Имя = Имя; 
			Контрагент.Наименование = СтрШаблон("%1 %2", Фамилия, Имя);
			Контрагент.ВидЦен = Справочники.ВидыЦен.НайтиПоНаименованию("Розничная");
			Контрагент.Телефон = Телефон;
			
			Контрагент.Записать();
			
			НоваяКарта = Справочники.отусВиртуальныеКарты.СоздатьЭлемент();
			НоваяКарта.Контрагент = Контрагент.Ссылка;
			НоваяКарта.НомерКарты = Телефон;
			НоваяКарта.Наименование = СтрШаблон("%1 (%2)", Контрагент.Наименование, НоваяКарта.НомерКарты); 
			НоваяКарта.ПодарочныйСертификат = ПодарочныйСертификат;
			НоваяКарта.Сумма = Сумма;
			НоваяКарта.Записать();
			
			ЗафиксироватьТранзакцию(); 
			
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = "Карта создана";
			Сообщение.Сообщить();
			
			Карта = НоваяКарта.Ссылка;
		Исключение
			ОтменитьТранзакцию(); 
			
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = "Ошибка создания карты";
			Сообщение.Сообщить();
		КонецПопытки;
	Иначе
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = СтрШаблон("На телефон %1 уже зарегистрирована виртуальная карта", Телефон);
		Сообщение.Сообщить();
	КонецЕсли;
	
	Возврат Карта;
	
КонецФункции

&НаКлиенте
Процедура Сохранить(Команда)
	Карта = СохранитьНаСервере();
	
	ДанныеЗакрытия = Новый Структура;
	ДанныеЗакрытия.Вставить("ПодарочныйСертификат");
	ДанныеЗакрытия.Вставить("Сумма");
	ДанныеЗакрытия.Вставить("Карта", Карта);
	
	ЗаполнитьЗначенияСвойств(ДанныеЗакрытия, ЭтотОбъект);

	Если ЗначениеЗаполнено(Карта) Тогда
		Закрыть(ДанныеЗакрытия);
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ПодарочныйСертификатПриИзменении(Элемент)
	
	Если ПодарочныйСертификат Тогда
		Элементы.Сумма.Видимость = Истина;
	КонецЕсли;	
		
	
КонецПроцедуры
