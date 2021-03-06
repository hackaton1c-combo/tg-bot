#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Процедура ОбработкаПроведения(Отказ, Режим)
	Движения.ОстаткиМерча.Записывать = Истина;
	Движения.БалансПользователя.Записывать = Истина;

	Движение = Движения.ОстаткиМерча.Добавить();
	Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
	Движение.Период = Дата;
	Движение.Номенклатура = Номенклатура;
	Движение.Количество = 1;
	Движения.Записать();
	
	//проверка на наличие товара
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
				   |	ОстаткиМерчаОстатки.Номенклатура КАК Номенклатура,
				   |	ОстаткиМерчаОстатки.КоличествоОстаток КАК КоличествоОстаток
				   |ИЗ
				   |	РегистрНакопления.ОстаткиМерча.Остатки(&МоментВремени, ) КАК ОстаткиМерчаОстатки
				   |ГДЕ
				   |	ОстаткиМерчаОстатки.КоличествоОстаток < 0";

	Граница = Новый Граница(МоментВремени(), ВидГраницы.Включая);
	Запрос.УстановитьПараметр("МоментВремени", Граница);

	РезультатЗапроса = Запрос.Выполнить();

	Если Не РезультатЗапроса.Пустой() Тогда
		Отказ = Истина;
		ОбщегоНазначения.СообщитьПользователю("Нет мерча на складе!");
		Возврат;
	КонецЕсли;

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
				   |	ВЫБОР
				   |		КОГДА БалансПользователяОстатки.ЗолотоОстаток >= НоменклатураМерча.СтоимостьЗолото
				   |		И БалансПользователяОстатки.СереброОстаток >= НоменклатураМерча.СтоимостьСеребро
				   |			ТОГДА ИСТИНА
				   |		ИНАЧЕ ЛОЖЬ
				   |	КОНЕЦ КАК ДостаточноДенег,
				   | 	НоменклатураМерча.СтоимостьЗолото,
				   |	НоменклатураМерча.СтоимостьСеребро
				   |ИЗ
				   |	РегистрНакопления.БалансПользователя.Остатки(&МоментВремени, ФизическоеЛицо = &ФизическоеЛицо) КАК БалансПользователяОстатки
				   |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.НоменклатураМерча КАК НоменклатураМерча
				   |		ПО ИСТИНА
				   |ГДЕ
				   |	НоменклатураМерча.Ссылка = &Номенклатура";
	Запрос.УстановитьПараметр("ФизическоеЛицо", ФизическоеЛицо);
	Запрос.УстановитьПараметр("МоментВремени", Граница);
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Отказ = Истина;
		ОбщегоНазначения.СообщитьПользователю("Что-то пошло не так :(");
		Возврат;
	КонецЕсли;
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	Если Выборка.ДостаточноДенег Тогда
		Движение = Движения.БалансПользователя.ДобавитьРасход();
		Движение.Период = Дата;
		Движение.ФизическоеЛицо = ФизическоеЛицо;
		Движение.Серебро = Выборка.СтоимостьСеребро;
		Движение.Золото = Выборка.СтоимостьЗолото;
	Иначе
		Отказ = Истина;
		ОбщегоНазначения.СообщитьПользователю("Не достаточно средств");
		Возврат;
	КонецЕсли;
	// FIXME: Без этой строки не записывает. Почему?
	Движения.БалансПользователя.Записать();
КонецПроцедуры

#Иначе
	ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли