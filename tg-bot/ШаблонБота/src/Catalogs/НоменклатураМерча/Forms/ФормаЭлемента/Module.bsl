
&НаКлиенте
Процедура ФотоНажатие(Элемент, СтандартнаяОбработка)
	ПараметрыДиалога = Новый ПараметрыДиалогаПомещенияФайлов;
	ПараметрыДиалога.МножественныйВыбор = Ложь;
	ПараметрыДиалога.Заголовок = НСтр("ru = 'Выберите файл'; en = 'Select file'");
   	ПараметрыДиалога.Фильтр = НСтр("ru = 'Картинка'; en = 'Picture'") + " (*.jpg)|*.jpg|";
	
    ЗавершениеОбратныйВызов = Новый ОписаниеОповещения("ЗавершениеОбратныйВызов", ЭтотОбъект);
    ПрогрессОбратныйВызов = Новый ОписаниеОповещения("ПрогрессОбратныйВызов", ЭтотОбъект);
    ПередНачаломОбратныйВызов = Новый ОписаниеОповещения("ПередНачаломОбратныйВызов", ЭтотОбъект);
    НачатьПомещениеФайлаНаСервер(ЗавершениеОбратныйВызов, ПрогрессОбратныйВызов, ПередНачаломОбратныйВызов,, ПараметрыДиалога, ЭтаФорма.УникальныйИдентификатор);
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	//отображение картинки при открытии формы справочника
	Фото = ПоместитьВоВременноеХранилище(ТекущийОбъект.Картинка.Получить());

	//устанавливаем автомасштаб для картинки
	Элементы.Фото.РазмерКартинки = РазмерКартинки.АвтоРазмер;
КонецПроцедуры


&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	Если ЗначениеЗаполнено(Фото) Тогда
		ТекущийОбъект.Картинка = Новый ХранилищеЗначения(ПолучитьИзВременногоХранилища(Фото));
	КонецЕсли;
КонецПроцедуры


#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗавершениеОбратныйВызов(ОписаниеПомещенногоФайла, ДополнительныеПараметры) Экспорт

	Если ОписаниеПомещенногоФайла = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Фото = ОписаниеПомещенногоФайла.Адрес;
	
	Модифицированность = Истина;

КонецПроцедуры

&НаКлиенте
Процедура ПрогрессОбратныйВызов(ПомещаемыйФайл, Помещено, ОтказОтПомещенияФайла, ДополнительныеПараметры) Экспорт

	ТекстСообщения = СтрШаблон(НСтр("ru = 'Загрузка файла %1'; en = 'Uploading file %1'"), ПомещаемыйФайл.Имя);
	РазмерФайла = СтрШаблон(Нстр("ru = 'Размер файла %1 байт'; en = 'File size %1 bytes'"), ПомещаемыйФайл.Размер());
	
	Состояние(ТекстСообщения, Помещено, РазмерФайла, БиблиотекаКартинок.Документ);

КонецПроцедуры

&НаКлиенте
Процедура ПередНачаломОбратныйВызов(ПомещаемыйФайл, ОтказОтПомещенияФайла, ДополнительныеПараметры) Экспорт

	МегабайтВБайтах = 1000000;
	Если ПомещаемыйФайл.Размер() > МегабайтВБайтах * 10 Тогда
		ОтказОтПомещенияФайла = Истина;
		ТекстСообщения = СтрШаблон(НСтр("ru = 'Отказ. Загружаемый файл «%1» имеет размер более 10 мегабайт';
		|en = 'Failure. The uploaded file «%1» is larger than 10 megabyte'"), ПомещаемыйФайл.Имя);
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = ТекстСообщения;
		Сообщение.Сообщить();
		ОтказОтПомещенияФайла = Истина;
		
		//ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,,,, ОтказОтПомещенияФайла);
	Иначе
		ПоказатьОповещениеПользователя(НСтр("ru = 'Загрузка файла'; en = 'Uploading file'"),, ПомещаемыйФайл.Имя);
	КонецЕсли;  

КонецПроцедуры

#КонецОбласти