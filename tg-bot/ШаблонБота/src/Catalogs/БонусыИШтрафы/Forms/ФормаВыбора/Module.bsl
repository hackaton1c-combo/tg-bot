
&НаКлиенте
Процедура СписокВыборЗначения(Элемент, Значение, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	Знак = ?(ТекущиеДанные.Штраф, -1, 1);
	Значение = Новый Структура("Модификатор, СтоимостьЗолото, СтоимостьСеребро",
						ТекущиеДанные.Ссылка,
						ТекущиеДанные.СтоимостьЗолото * Знак,
						ТекущиеДанные.СтоимостьСеребро * Знак);
	ОповеститьОВыборе(Значение);
КонецПроцедуры
