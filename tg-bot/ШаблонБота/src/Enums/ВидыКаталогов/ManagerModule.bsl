
Функция НайтиПоПредставлению(Представление) Экспорт
	
	Для Каждого ЗначениеПеречисления Из Метаданные.Перечисления.ВидыКаталогов.ЗначенияПеречисления Цикл
		Если ЗначениеПеречисления.Синоним = Представление Тогда
			Возврат Перечисления.ВидыКаталогов[ЗначениеПеречисления.Имя];
		КонецЕсли;
	КонецЦикла;
	
	Возврат Перечисления.ВидыКаталогов.ПустаяСсылка();
	
КонецФункции
