Процедура ДатаЗапросаПоУмолчанию(Дата) Экспорт
	Дата = ?(Дата = Неопределено, ТекущаяДата(), Дата);
КонецПроцедуры

Функция СтруктураВозвратаДляТГ_СообщениеКоманды() Экспорт
	Перем СтруктураВозврата;
	СтруктураВозврата = Новый Структура("Сообщение, Команды", "", Новый Массив);
	Возврат СтруктураВозврата
КонецФункции