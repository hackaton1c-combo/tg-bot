#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

// Возвращает баланс пользователя на указанную дату
//
// Параметры:
//  Пользователь - СправочникСсылка.ФизическиеЛица - Физическое лицо, список задач которого нужно вернуть
//  Дата - Дата - Дата на которую собираются задачи (по умолчанию, ТекущаяДата())
//							
// Возвращаемое значение:
//  Структура
//  	Сообщение - Сообщение для вывода в телеграмм
//  	Команды - Массив структур
//  				Наименование - Представление команды
//  				id - идентификатор команды
//	
Функция БалансПользователяНаДату(Пользователь, Дата = Неопределено) Экспорт
	СтруктураВозврата = ОбщийМодульСервер.СтруктураВозвратаДляТГ_СообщениеКоманды();
	ОбщийМодульСервер.ДатаЗапросаПоУмолчанию(Дата);
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	БалансПользователяОстатки.ЗолотоОстаток КАК Золото,
	|	БалансПользователяОстатки.СереброОстаток КАК Серебро
	|ИЗ
	|	РегистрНакопления.БалансПользователя.Остатки(&Дата, ФизическоеЛицо = &ФЛ) КАК БалансПользователяОстатки";
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("ФЛ", Пользователь);
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		СтруктураВозврата.Сообщение = СтрШаблон("Ваш баланс: %1 золота, %2 серебра", Выборка.Золото, Выборка.Серебро);
	КонецЕсли;
	Возврат СтруктураВозврата;	
КонецФункции

#КонецЕсли