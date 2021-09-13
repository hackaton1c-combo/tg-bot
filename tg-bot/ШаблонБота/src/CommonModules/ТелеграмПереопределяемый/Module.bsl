
#Область ПрограммныйИнтерфейс

Процедура ОбработатьСообщениеЧата(ТекстСообщения, 
	ТекстПредыдущегоСообщения, ФизическоеЛицо, УчетнаяЗапись, Ответ) Экспорт

	Если ТекстСообщения = "Баланс" Тогда
		Результат = РегистрыНакопления.БалансПользователя.БалансПользователяНаДату(ФизическоеЛицо);
		Ответ = Телеграм.НовыйОтветНаСообщение(УчетнаяЗапись, Результат.Сообщение);
	КонецЕсли;
	
	Если ТекстСообщения = "Бонусы" Тогда		
		ДополнительныеПараметры = Телеграм.НовыеДополнительныеПараметрыСообщенияФизЛицу();
		ДополнительныеПараметры.ПозицияМеню = Перечисления.ПозицииМеню.Бонусы;
		Ответ = Телеграм.НовыйОтветНаСообщение(УчетнаяЗапись, "Выберите действие с бонусами", ДополнительныеПараметры);
	КонецЕсли;
	
	Если ТекстСообщения = "Задания" Тогда		
		ДополнительныеПараметры = Телеграм.НовыеДополнительныеПараметрыСообщенияФизЛицу();
		ДополнительныеПараметры.ОтобразитьКаталог = Перечисления.ВидыКаталогов.Задачи;
		Ответ = Телеграм.НовыйОтветНаСообщение(УчетнаяЗапись, "", ДополнительныеПараметры);
	КонецЕсли;
	
	Если ТекстСообщения = "Сказать спасибо" Тогда
		ДополнительныеПараметры = Телеграм.НовыеДополнительныеПараметрыСообщенияФизЛицу();
		ДополнительныеПараметры.ОтобразитьКаталог = Перечисления.ВидыКаталогов.Сотрудники;
		Ответ = Телеграм.НовыйОтветНаСообщение(УчетнаяЗапись, 
			"Кому вы хотите сказать спасибо?", ДополнительныеПараметры);
	КонецЕсли;
		
	Если СтрНачинаетсяС(ТекстПредыдущегоСообщения, "Объект: Сотрудники") Тогда
		СтрокиСообщения = СтрРазделить(ТекстПредыдущегоСообщения, Символы.ПС);
		Если СтрокиСообщения.Количество() < 2 Тогда
			Возврат;
		КонецЕсли;
		ФизическоеЛицоПолучатель = Справочники.ФизическиеЛица.НайтиПоНаименованию(СтрокиСообщения[1], Истина);
		Если Не ЗначениеЗаполнено(ФизическоеЛицоПолучатель)
			Или ФизическоеЛицоПолучатель = ФизическоеЛицо Тогда
			Возврат;
		КонецЕсли;
		Документы.Спасибо.СказатьСпасибо(ФизическоеЛицо, ФизическоеЛицоПолучатель, ТекстСообщения);
		ШаблонОтвета = "Вы успешно сказали спасибо сотруднику ""%1""";
		ТекстОтвета = СтрШаблон(ШаблонОтвета, ФизическоеЛицоПолучатель);
		Ответ = Телеграм.НовыйОтветНаСообщение(УчетнаяЗапись, ТекстОтвета);
		ШаблонСообщенияПолучателю = "Вам сказали спасибо:
			|%1
			|Отправитель: %2";
		ТекстСообщенияПолучателю = СтрШаблон(ШаблонСообщенияПолучателю, ТекстСообщения, ФизическоеЛицо);
		Телеграм.ОтправитьСообщениеФизЛицу(ФизическоеЛицоПолучатель, ТекстСообщенияПолучателю);
	КонецЕсли;	
	
КонецПроцедуры

Процедура УстановитьКнопкиМеню(ПозицияМеню, Кнопки) Экспорт
		
	Если ПозицияМеню = Перечисления.ПозицииМеню.Старт Тогда
		Кнопки.Добавить("Сказать спасибо");
		Кнопки.Добавить("Задания");
		Кнопки.Добавить("Бонусы");
	КонецЕсли;	
	
	Если ПозицияМеню = Перечисления.ПозицииМеню.Бонусы Тогда
		Кнопки.Добавить("Баланс");
		Кнопки.Добавить("Каталог бонусов");
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриПолученииЭлементовКаталога(ЭлементыКаталога, ФизическоеЛицо, Каталог, СтрокаПоиска) Экспорт
	
	Если Каталог = Перечисления.ВидыКаталогов.Задачи Тогда
		ЭлементыКаталога = РегистрыСведений.КвестыПользователей.ПолучитьКвестыПользователя(ФизическоеЛицо);
	КонецЕсли;
	
	Если Каталог = Перечисления.ВидыКаталогов.Сотрудники Тогда
		ЭлементыКаталога = Справочники.ФизическиеЛица.ФизическиеЛицаКромеТекущего(ФизическоеЛицо);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриПолученииСсылкиНаОбъект(Каталог, Идентификатор, Ссылка) Экспорт
	
	УникальныйИдентификатор = Новый УникальныйИдентификатор(Идентификатор);
	
	Если Каталог = Перечисления.ВидыКаталогов.Задачи Тогда			
		Ссылка = Справочники.Квесты.ПолучитьСсылку(УникальныйИдентификатор);
	КонецЕсли;
	
	Если Каталог = Перечисления.ВидыКаталогов.Сотрудники Тогда			
		Ссылка = Справочники.ФизическиеЛица.ПолучитьСсылку(УникальныйИдентификатор);
	КонецЕсли;
		
КонецПроцедуры

Процедура ПриПолученииОписанияОбъекта(Ссылка, ОписаниеОбъекта) Экспорт
	
	Если ТипЗнч(Ссылка) = Тип("СправочникСсылка.Квесты") Тогда
		ОписаниеОбъекта = Справочники.Квесты.ОписаниеКвестаПоСсылке(Ссылка);
	КонецЕсли;
	
	Если ТипЗнч(Ссылка) = Тип("СправочникСсылка.ФизическиеЛица") Тогда
		
		ШаблонСообщения = "%1
			|В ответе на это сообщение напишите, за что вы говорите Спасибо";
		
		ОписаниеОбъекта.Сообщение = СтрШаблон(ШаблонСообщения, Ссылка);
		ОписаниеОбъекта.БыстрыйОтвет = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриОбработкеКомандыОбъекта(Ссылка, ИдентификаторКоманды, ТекстСообщения, Команды) Экспорт
	
	Если ТипЗнч(Ссылка) = Тип("СправочникСсылка.Квесты") Тогда
		Результат = Справочники.Квесты.ВыполнитьКоманду(Ссылка, ИдентификаторКоманды);
		ТекстСообщения = Результат.Сообщение;
		Команды = Результат.Команды;
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти