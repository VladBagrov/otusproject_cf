//////////////////////////////////////////////////////////////////////////////// 
// Переменные
// 

//@skip-check module-structure-var-in-region
&НаКлиенте
Перем АдресТоваровВХранилище; 

&НаКлиенте
Перем ИдентификаторЗамераПроведение, ИдентификаторЗамераПроведениеНеНужнаРегистрацияОшибки;

//////////////////////////////////////////////////////////////////////////////// 
// ПРОЦЕДУРЫ И ФУНКЦИИ 
// 

// Функция возвращает цену определенного товара на дату согласно виду цены
// 
// Параметры: 
//  Дата   – Дата – дата, на которую определяется цена. 
//  Товар  – СправочникСсылка.Товары – товар, цена которого определяется. 
//  ВидЦен – СправочникСсылка.ВидыЦен – вид цены. 
// 
// Возвращаемое значение: 
//  Число - Цена товара на определенную дату, согласно виду цены.
&НаСервереБезКонтекста
Функция ПолучитьЦенуТовара(Дата, Товар, ВидЦен)
	ЦенаТовара = РегистрыСведений.ЦеныТоваров.ПолучитьПоследнее(
		Дата, Новый Структура("Товар, ВидЦен", Товар, ВидЦен));
	Возврат ЦенаТовара.Цена;
КонецФункции

// Функция возвращает вид цены для указанного покупателя
// 
// Параметры: 
//  Покупатель – СправочникСсылка.Контрагенты – контрагент. 
// 
// Возвращаемое значение: 
//  СправочникСсылка.ВидыЦен - Вид цены для указанного покупателя.
&НаСервереБезКонтекста
Функция ПолучитьВидЦенПокупателя(Покупатель)
	Запрос = Новый Запрос();
	Запрос.Текст = "ВЫБРАТЬ ВидЦен ИЗ Справочник.Контрагенты ГДЕ Ссылка = &Покупатель";
	Запрос.УстановитьПараметр("Покупатель", Покупатель);
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.ВидЦен;
	КонецЕсли;
	Возврат Справочники.ВидыЦен.ПустаяСсылка();
КонецФункции

// Функция определяет услуга это или нет
&НаСервереБезКонтекста
Функция ЭтоУслуга(Товар)
	
	Возврат ?(Товар.Вид = Перечисления.ВидыТоваров.Услуга, Истина, Ложь);
	
КонецФункции

// Процедура устанавливает цены товаров и вычисляет суммы по каждой строке
// табличной части Товары.
// 
// Параметры: 
//  Нет.
// 
// Возвращаемое значение: 
//  Нет.
&НаСервере
Процедура ПересчитатьЦеныИСуммыТоваров(ПересчитатьДляВсехТоваров)
	Запрос = Новый Запрос();
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЦеныТоваровСрезПоследних.Цена,
	               |	ЦеныТоваровСрезПоследних.Товар
	               |ИЗ
	               |	РегистрСведений.ЦеныТоваров.СрезПоследних(
	               |		,
	               |		ВидЦен = &ВидЦены
	               |			И Товар В (&Товары)) КАК ЦеныТоваровСрезПоследних";
	Запрос.УстановитьПараметр("ВидЦены", Объект.ВидЦен);
	Товары = Новый Массив();
	Для каждого Стр Из Объект.Товары Цикл 
		Товары.Добавить(Стр.Товар);
	КонецЦикла;
	Запрос.УстановитьПараметр("Товары", Товары);
	
	ТЗЦены = Запрос.Выполнить().Выгрузить();
	ТЗЦены.Индексы.Добавить("Товар");
	Для каждого Стр Из Объект.Товары Цикл 
		Если Стр.Цена = 0 ИЛИ ПересчитатьДляВсехТоваров Тогда
			ЦенаТовара = ТЗЦены.Найти(Стр.Товар, "Товар");
			Если ЦенаТовара <> Неопределено Тогда
				Стр.Цена = ЦенаТовара.Цена;
			Иначе 	
				Стр.Цена = 0;
			КонецЕсли;
		КонецЕсли;	
		Стр.Сумма = Стр.Цена * Стр.Количество;
		Стр.СуммаИзменена = Ложь;
		Стр.ЭтоУслуга = ЭтоУслуга(Стр.Товар);
	КонецЦикла;
КонецПроцедуры

// Функция помещает список товаров во временное хранилище и возвращает адрес 
&НаСервере
Функция ПоместитьТоварыВХранилище() 
	Возврат ПоместитьВоВременноеХранилище(Объект.Товары.Выгрузить(,"Товар,Цена,Количество"), УникальныйИдентификатор);
КонецФункции	

// Функция восстанавливает список товаров из временного хранилища
&НаСервере
Процедура ПолучитьТоварыИзХранилища(АдресТоваровВХранилище)
	Объект.Товары.Загрузить(ПолучитьИзВременногоХранилища(АдресТоваровВХранилище));
	ПересчитатьЦеныИСуммыТоваров(Ложь);   
КонецПроцедуры	


// Функция возвращает ссылку на текущую строку в списке товаров 
// 
// Параметры: 
//  Нет. 
// 
// Возвращаемое значение: 
//  СправочникСсылка.Товары - Текущий товар в списке.
&НаКлиенте
Функция ПолучитьТекущуюСтрокуТовары()
	Возврат Элементы.Товары.ТекущиеДанные;
КонецФункции

// Процедура вычисляет дополнительные данные строки документа
&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьДополнительныеДанныеСтроки(Строка)
	
	Строка.СуммаИзменена = Строка.Сумма <> Строка.Количество * Строка.Цена;
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////// 
// ОБРАБОТЧИКИ СОБЫТИЙ 
// 

&НаКлиенте
Процедура ТоварыТоварПриИзменении(Элемент)
	Стр = ПолучитьТекущуюСтрокуТовары();
	Стр.ЭтоУслуга = ЭтоУслуга(Стр.Товар);
	Стр.Цена = ПолучитьЦенуТовара(Объект.Дата, Стр.Товар, Объект.ВидЦен);
	Стр.Количество = ?(Стр.ЭтоУслуга ИЛИ Стр.Количество = 0, 1, Стр.Количество);
	Стр.Сумма = Стр.Количество * Стр.Цена;
	ЗаполнитьДополнительныеДанныеСтроки(Стр);
КонецПроцедуры

&НаКлиенте
Процедура ПокупательПриИзменении(Элемент)
	ВидЦен = ПолучитьВидЦенПокупателя(Объект.Покупатель);
	Если Объект.ВидЦен <> ВидЦен Тогда
		Объект.ВидЦен = ВидЦен;
		Если Объект.Товары.Количество() > 0 Тогда
			ПересчитатьЦеныИСуммыТоваров(Истина);
		КонецЕсли;	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ВидЦенПриИзменении(Элемент)
	Если Объект.Товары.Количество() > 0 Тогда
		ПересчитатьЦеныИСуммыТоваров(Истина);
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаПриИзменении(Элемент)
	Стр = ПолучитьТекущуюСтрокуТовары();
	Стр.Сумма = Стр.Количество * Стр.Цена;
	ЗаполнитьДополнительныеДанныеСтроки(Стр);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыКоличествоПриИзменении(Элемент) 
	Стр = ПолучитьТекущуюСтрокуТовары();
	Стр.Сумма = Стр.Количество * Стр.Цена;
	ЗаполнитьДополнительныеДанныеСтроки(Стр);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыСуммаПриИзменении(Элемент)
	Стр = ПолучитьТекущуюСтрокуТовары();
	ЗаполнитьДополнительныеДанныеСтроки(Стр);
КонецПроцедуры

// Обработчик команды подбора
&НаКлиенте
Процедура КомандаПодбор()
#Если МобильныйКлиент Тогда
	Имя = "ОбщаяФорма.ФормаПодбораМобильная";
#Иначе
	Имя = "ОбщаяФорма.ФормаПодбора";
#КонецЕсли
	АдресТоваровВХранилище = ПоместитьТоварыВХранилище();
	ПараметрыПодбора = Новый Структура("АдресТоваровДокумента, ВидЦен, Склад", АдресТоваровВХранилище, Объект.ВидЦен, Объект.Склад);
	ФормаПодбора = ОткрытьФорму(Имя, ПараметрыПодбора, ЭтотОбъект);
КонецПроцедуры

&НаСервере
Процедура ПересчитатьНаСервере()
	Документ = РеквизитФормыВЗначение("Объект");
	Документ.Пересчитать();
	ЗначениеВРеквизитФормы(Документ, "Объект");
	
	Для каждого Стр Из Объект.Товары Цикл
		
		ЗаполнитьДополнительныеДанныеСтроки(Стр);
		
	КонецЦикла
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьВыполнить()
	ПересчитатьНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ОформитьДоставкуВыполнить()
	ПараметрыДоставки = Новый Структура("ДатаДокумента,Документ", Объект.Дата, Объект.Ссылка);
	ОткрытьФорму("Документ.РасходТовара.Форма.ОформлениеДоставки", ПараметрыДоставки);
КонецПроцедуры

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)
	
	ПараметрыОпций = Новый Структура("Организация", Объект.Организация);
	УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыОпций);
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

	Если Параметры.Ключ.Пустая() Тогда 
		
		ПараметрыОпций = Новый Структура("Организация", Объект.Организация);
		УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыОпций);
		
	КонецЕсли;
	
	Для каждого Стр Из Объект.Товары Цикл
		
		ЗаполнитьДополнительныеДанныеСтроки(Стр);
		
	КонецЦикла;
	
КонецПроцедуры 

// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
    ПодключаемыеКомандыКлиент.НачатьВыполнениеКоманды(ЭтотОбъект, Команда, Объект);
КонецПроцедуры
&НаКлиенте
Процедура Подключаемый_ПродолжитьВыполнениеКомандыНаСервере(ПараметрыВыполнения, ДополнительныеПараметры) Экспорт
    ВыполнитьКомандуНаСервере(ПараметрыВыполнения);
КонецПроцедуры
&НаСервере
Процедура ВыполнитьКомандуНаСервере(ПараметрыВыполнения)
    ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВыполнения, Объект);
КонецПроцедуры
&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
    ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)

	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	ПараметрыОпций = Новый Структура("Организация", Объект.Организация);
	УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыОпций);

	Для каждого Стр Из Объект.Товары Цикл
		
		ЗаполнитьДополнительныеДанныеСтроки(Стр);
		Стр.ЭтоУслуга = ЭтоУслуга(Стр.Товар);
		
	КонецЦикла
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	ПараметрыОпций = Новый Структура("Организация", Объект.Организация);
	УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыОпций);
	
	Для каждого Стр Из Объект.Товары Цикл
		
		ЗаполнитьДополнительныеДанныеСтроки(Стр);
		
	КонецЦикла
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьПодбор() Экспорт
	
	ПолучитьТоварыИзХранилища(АдресТоваровВХранилище);  
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаЗаписиНового(НовыйОбъект, Источник, СтандартнаяОбработка)
	Если ТипЗнч(НовыйОбъект) = Тип("СправочникСсылка.Контрагенты") Тогда
		Объект.Покупатель = НовыйОбъект;
		ВидЦен = ПолучитьВидЦенПокупателя(Объект.Покупатель);
		Если Объект.ВидЦен <> ВидЦен Тогда
			Объект.ВидЦен = ВидЦен;
			Если Объект.Товары.Количество() > 0 Тогда
				ПересчитатьЦеныИСуммыТоваров(Истина);
			КонецЕсли;	
		КонецЕсли;
		ТекущийЭлемент = Элементы.Покупатель;
	КонецЕсли;
КонецПроцедуры

// otus project >>>
&НаКлиенте
Процедура НайтиКарту(Команда)
	
	Подсказка = "Введите номер телефона";
	Оповещение = Новый ОписаниеОповещения("ПослеВводаНомераТелефона", ЭтотОбъект, Параметры);
	ПоказатьВводСтроки(Оповещение, "", Подсказка, 0, Истина);
	
КонецПроцедуры 

&НаКлиенте
Процедура ПослеВводаНомераТелефона(Строка, Параметры) Экспорт
	
    Если НЕ Строка = Неопределено Тогда
        ДанныеКарта = НайтиКартуСервер(Строка);
		
		Объект.отусВиртуальнаяКарта = ДанныеКарта.Карта; 
		Объект.Покупатель = ДанныеКарта.Контрагент; 
		БалансКарты = ДанныеКарта.Баланс;
		
		Элементы.ДекорацияБалансКарты.Заголовок = СтрШаблон("Баланс карты: %1", ДанныеКарта.Баланс);
		
    КонецЕсли;
    
КонецПроцедуры

&НаСервереБезКонтекста
Функция НайтиКартуСервер(НомерТелефона) 
	
	ЭтоФронт = Константы.отусЭтоФронтОфис.Получить();
	
	Если ЭтоФронт Тогда
		Возврат отусБонуснаяСистемаСервер.НайтиКартуHTTPСервис(НомерТелефона);
	Иначе	
		Возврат Справочники.отусВиртуальныеКарты.НайтиКарту(НомерТелефона);		
	КонецЕсли;	
	
КонецФункции	

&НаКлиенте
Процедура отусВиртуальнаяКартаПриИзменении(Элемент)
	
	Если не ЗначениеЗаполнено(Объект.отусВиртуальнаяКарта) Тогда
		Элементы.ДекорацияБалансКарты.Заголовок = СтрШаблон("Баланс карты: %1", 0);	
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура НоваяКарта(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("НоваяКартаЗакрытие", ЭтотОбъект);
	ОткрытьФорму("ОбщаяФорма.отусНоваяКарта", , , , , , ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура НоваяКартаЗакрытие(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат.ПодарочныйСертификат Тогда  
		
		ДобавитьСертификатСервер(Результат);
		
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьСертификатСервер(Результат)    
	
	Объект.Товары.Очистить();
	
	НовыйТовар = Объект.Товары.Добавить();
	НовыйТовар.Товар = Справочники.Товары.НайтиПоНаименованию("Подарочный сертификат");
	НовыйТовар.Цена = Результат.Сумма;
	НовыйТовар.Количество = 1;
	НовыйТовар.Сумма = НовыйТовар.Цена * НовыйТовар.Количество;
		
КонецПроцедуры	

&НаСервере
Процедура СписатьБонусыНаСервере()
	
	Если БалансКарты > 0 Тогда 
		
		ДанныеКарты = Новый Структура;
		ДанныеКарты.Вставить("Карта", Объект.отусВиртуальнаяКарта);
		ДанныеКарты.Вставить("Сумма", БалансКарты);
		
		мКарты = Новый Массив;
		Мкарты.Добавить(ДанныеКарты); 
		
		Если Документы.ОтусСписаниеБонусов.СоздатьДокументСписания(Мкарты) Тогда
			
			Оплата = Объект.Оплата.Добавить();
			Оплата.СпособОплаты = ПредопределенноеЗначение("Справочник.отусСпособыОплат.Бонусы");
			Оплата.Сумма = БалансКарты;   
			
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст  = СтрШаблон("Списано %1 бонусов с карты", БалансКарты);
			Сообщение.Сообщить();

			Модифицированность = Истина;
		Иначе
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст  = СтрШаблон("Не удалось списать бонусы по виртуальной карте %1", Объект.отусВиртуальнаяКарта);
			Сообщение.Сообщить();
			
		КонецЕсли;
		
   КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СписатьБонусы(Команда)
	СписатьБонусыНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьНаличные(Команда)
	
	Наличные = ПредопределенноеЗначение("Справочник.отусСпособыОплат.Наличные"); 
	ДобавитьВидОплаты(Наличные);
	
КонецПроцедуры  

&НаКлиенте
Процедура ДобавитьВидОплаты(ВидОплаты)
	
	СуммаПродажи = Объект.Товары.Итог("Сумма");
	СуммаОплаты = Объект.Оплата.Итог("Сумма"); 
	
	Если СуммаПродажи > СуммаОплаты Тогда
		НоваяОплата = Объект.Оплата.Добавить();
		НоваяОплата.СпособОплаты = ВидОплаты;
		НоваяОплата.Сумма = СуммаПродажи - СуммаОплаты;
		Модифицированность = Истина;
	КонецЕсли;	

КонецПроцедуры	

&НаКлиенте
Процедура ЗаполнитьКартой(Команда)
	
	Наличные = ПредопределенноеЗначение("Справочник.отусСпособыОплат.БанковскаяКарта"); 
	ДобавитьВидОплаты(Наличные);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		ИдентификаторЗамераПроведение = ОценкаПроизводительностиКлиент.ЗамерВремени("ДокументПродажа");
		ИдентификаторЗамераПроведениеНеНужнаРегистрацияОшибки = ОценкаПроизводительностиКлиент.ЗамерВремени();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	ПодключаемыеКомандыКлиент.ПослеЗаписи(ЭтотОбъект, Объект, ПараметрыЗаписи);
	
	ОценкаПроизводительностиКлиент.УстановитьПризнакОшибкиЗамера(ИдентификаторЗамераПроведение, Ложь);
    
    ОценкаПроизводительностиКлиент.УстановитьКлючевуюОперациюЗамера(ИдентификаторЗамераПроведениеНеНужнаРегистрацияОшибки, "ДокументПродажаНеНужнаРегистрацияОшибки");
	
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
    ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
    // Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

// otus project <<<