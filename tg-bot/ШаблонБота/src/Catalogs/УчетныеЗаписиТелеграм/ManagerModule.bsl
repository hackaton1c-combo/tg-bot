
#Область ПрограммныйИнтерфейс

Функция НоваяУчетнаяЗапись(ДанныеПользователя) Экспорт
	
	Идентификатор = XMLСтрока(ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ДанныеПользователя, "id"));
	Имя = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ДанныеПользователя, "first_name");
	Фамилия = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ДанныеПользователя, "last_name");
	ИмяПользователя = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ДанныеПользователя, "username");
	
	ЭлементыПредставления = Новый Массив;
	
	Если ЗначениеЗаполнено(Имя) Тогда
		ЭлементыПредставления.Добавить(Имя);
	КонецЕсли;
	Если ЗначениеЗаполнено(Фамилия) Тогда
		ЭлементыПредставления.Добавить(Фамилия);
	КонецЕсли;	
	
	Если ЗначениеЗаполнено(ИмяПользователя) Тогда
		Если ЭлементыПредставления.Количество() = 0 Тогда
			ЭлементыПредставления.Добавить(ИмяПользователя);
		Иначе
			ЭлементыПредставления.Добавить("(" + ИмяПользователя + ")");
		КонецЕсли;
	КонецЕсли;	
	
	Представление = СтрСоединить(ЭлементыПредставления, " ");
	
	СпрОбъект = СоздатьЭлемент();
	СпрОбъект.Наименование = Представление;
	СпрОбъект.Код = Идентификатор;
	СпрОбъект.Записать();
	
	Возврат СпрОбъект.Ссылка;		
	
КонецФункции

Процедура СвязатьУчетнуюЗаписьСФизЛицом(УчетнаяЗапись, ФизЛицо) Экспорт
	
	СпрОбъект = УчетнаяЗапись.ПолучитьОбъект();
	СпрОбъект.ФизическоеЛицо = ФизЛицо;
	СпрОбъект.Записать();
	
КонецПроцедуры

Функция ИдентификаторыУчетныхЗаписейФизЛица(ФизЛицо) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	УчетныеЗаписиТелеграм.Код
	|ИЗ
	|	Справочник.УчетныеЗаписиТелеграм КАК УчетныеЗаписиТелеграм
	|ГДЕ
	|	УчетныеЗаписиТелеграм.ФизическоеЛицо = &ФизическоеЛицо";
	
	Запрос.УстановитьПараметр("ФизическоеЛицо", ФизЛицо);
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Код");
	
КонецФункции

#КонецОбласти