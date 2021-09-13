
#Область ПрограммныйИнтерфейс

Процедура ПодключитьБота() Экспорт
	
	ПараметрыПодключения = ПараметрыПодключения();
	
	Отказ = Ложь;
	
	ПроверитьПараметрыПодключенияПереодПодключением(ПараметрыПодключения, Отказ);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;	
	
	СоздатьСлужебногоПользователяТелеграм();
	
	ПроверитьДоступностьВебХука();
	
	УстановитьВебХукБота();	
	
	Константы.ТелеграмПодключен.Установить(Истина);
	
КонецПроцедуры

Функция ПолучитьСостояниеБота() Экспорт
	
	ПроверитьПодключение();
	
	Сервер = АдресСервераТелеграм();
	Токен = Константы.ТокенБотаТелеграм.Получить();
	
	Результат = ПустоеСостояниеБота();
	
	ШаблонТекстаЗапроса = "%1bot%2/getWebhookInfo";
	
	URL = СтрШаблон(ШаблонТекстаЗапроса, Сервер, Токен);
	
	Ответ = HTTPСервисы.ВыполнитьЗапрос("GET", URL);
	Если Ответ.КодСостояния = 401 Тогда
		ТекстОшибки = НСтр("ru = 'Неверный ключ API. Запрос не авторизован!'");
		ВызватьИсключение ТекстОшибки;
	ИначеЕсли Ответ.КодСостояния <> 200 Тогда
		ТекстОшибки = СтрШаблон(НСтр("ru = 'Не удалось получить информацию об учетной записи! Код состояния: %1'"),
		Ответ.КодСостояния);
		ЗаписьЖурналаРегистрации("МессенджерыСервер.getWebhookInfo",
		УровеньЖурналаРегистрации.Ошибка,,
		ТекстОшибки,
		HTTPСервисыСлужебный.ПредставлениеОбъектаHTTP(Ответ));
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	ОтветСтруктура = HTTPСервисы.ЗначениеИзТелаJSON(Ответ);
	// @skip-warning
	РезультатЗапроса = ОтветСтруктура["result"];
	
	Результат.АдресWebhook = РезультатЗапроса.url;
	
	Если РезультатЗапроса.Свойство("last_error_date") Тогда
		Дата = HTTPСервисы.UnixTimeStampВДату(РезультатЗапроса.last_error_date);
		Результат.ДатаПоследнейОшибки = Формат(Дата, "ДЛФ=DT");
		Результат.ТекстПоследнейОшибки = РезультатЗапроса.last_error_message
	КонецЕсли;
	
	ШаблонТекстаЗапроса = НСтр("ru = '%1bot%2/getMe'");
	URL = СтрШаблон(ШаблонТекстаЗапроса, Сервер, Токен);
	
	Ответ = HTTPСервисы.ВыполнитьЗапрос("GET", URL);
	ОтветСтруктура 	= HTTPСервисы.ЗначениеИзТелаJSON(Ответ);
	// @skip-warning
	РезультатЗапроса = ОтветСтруктура["result"];
	
	Результат.ИмяУчетнойЗаписи = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(РезультатЗапроса, "username");			
	Результат.Фамилия = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(РезультатЗапроса, "last_name");
	Результат.Идентификатор = РезультатЗапроса.id;
	Результат.Язык = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(РезультатЗапроса, "language_code");
	
	Возврат Результат;
	
КонецФункции

Функция ОбработатьЗапрос(Токен, ДанныеЗапроса) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию();
	
	Попытка
		
		Ответ = Неопределено;
		
		Если ДанныеЗапроса.Свойство("channel_post") Тогда
			// Обработать сообщение в канале
		КонецЕсли;  
		
		Если ДанныеЗапроса.Свойство("message") Тогда
			Ответ = ОбработатьСообщениеЧата(ДанныеЗапроса);
		КонецЕсли;	
		
		Если ДанныеЗапроса.Свойство("callback_query") Тогда	
			Ответ = ОбработатьКомандуСообщения(ДанныеЗапроса);
		КонецЕсли;

		Если Ответ = Неопределено Тогда
			Ответ = HTTPСервисы.СформироватьHTTPОтвет(200);
		КонецЕсли;

		ЗафиксироватьТранзакцию();

	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Возврат Ответ;
	
КонецФункции

Функция АдресСервераТелеграм() Экспорт 
	
	АдресИБ = Константы.АдресСервераТелеграм.Получить();
	
	Если Не СтрЗаканчиваетсяНа(АдресИБ, "/") Тогда
		АдресИБ = АдресИБ + "/";
	КонецЕсли;
	
	Возврат АдресИБ;	
	
КонецФункции

Функция НовыйОтветНаСообщение(УчетнаяЗапись, ТекстСообщения, ДополнительныеПараметры = Неопределено) Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("УчетнаяЗапись", УчетнаяЗапись);
	Результат.Вставить("Текст", ТекстСообщения);
	Результат.Вставить("ДополнительныеПараметры", ДополнительныеПараметры);
	
	Возврат Результат;
	
КонецФункции

// Новые дополнительные параметры сообщения физ лицу.
// 
// Возвращаемое значение:
//  Структура - Новые дополнительные параметры сообщения физ лицу:
// * ПозицияМеню - ПеречислениеСсылка.ПозицииМеню - Позиция, на которую должно переключиться меню пользователя
// * ОтобразитьКаталог - ПеречислениеСсылка.ВидыКаталогов - Каталог, который надо показать пользователю
Функция НовыеДополнительныеПараметрыСообщенияФизЛицу() Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("ПозицияМеню", Перечисления.ПозицииМеню.Старт);	
	Результат.Вставить("ОтобразитьКаталог", Перечисления.ВидыКаталогов.ПустаяСсылка());
	// Результат.Вставить("КомандыСообщения", Новый Массив);
	
	Возврат Результат;
	
КонецФункции

Процедура ОтправитьСообщениеФизЛицу(ФизЛицо, ТекстСообщения) Экспорт

	ПроверитьПодключение();

	УчетныеЗаписиФизЛица = Справочники.УчетныеЗаписиТелеграм.ИдентификаторыУчетныхЗаписейФизЛица(ФизЛицо);
	
	Для Каждого ИдентификаторУчетнойЗаписи Из УчетныеЗаписиФизЛица Цикл
		ОтправитьТекстовоеСообщение(ТекстСообщения, ИдентификаторУчетнойЗаписи);
	КонецЦикла;	

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОтправитьТекстовоеСообщение(Текст, ИдентификаторЧата)
	
	ПараметрыПодключения = ТелеграмПовтИсп.ПараметрыПодключенияТелеграм();
	
	ШаблонТекстаЗапроса = "%1bot%2/sendMessage";
	URL = СтрШаблон(ШаблонТекстаЗапроса, ПараметрыПодключения.Адрес, ПараметрыПодключения.Токен);
	
	ПараметрыЗапроса = Новый Структура;
	ПараметрыЗапроса.Вставить("ТипКонтента", "application/json");
		
	Сообщение = Новый Структура;
	Сообщение.Вставить("chat_id", ИдентификаторЧата);
	Сообщение.Вставить("text", Текст);
	
	Ответ = HTTPСервисы.ВыполнитьЗапрос("POST", URL, Сообщение,, ПараметрыЗапроса);
	
	Если Ответ.КодСостояния <> 200 Тогда
		ВызватьИсключение "Ошибка отправки запроса. Код состояния: " + Ответ.КодСостояния;
	КонецЕсли;		
	
КонецПроцедуры

Функция ОбработатьКомандуСообщения(ДанныеЗапроса)
	
	РезультатПроверки = ПроверитьПравоИспользованияБота(ДанныеЗапроса);
	
	Если Не РезультатПроверки.ЕстьПраво Тогда
		Возврат РезультатПроверки.ОтветПользователю;
	КонецЕсли;	
	
	ТекущийПользователь = РезультатПроверки.ТекущийПользователь;
	
	ТекстСообщения = ДанныеЗапроса.callback_query.message.text;
	ИдентификаторСообщения = ДанныеЗапроса.callback_query.message.message_id;
	КомандаСообщения = ДанныеЗапроса.callback_query.data;
	ИдентификаторЧата = ДанныеЗапроса.callback_query.message.chat.id;
	
	КонтекстКоманды = Новый Структура;
	КонтекстКоманды.Вставить("ТекущийПользователь", ТекущийПользователь);
	КонтекстКоманды.Вставить("ТекстСообщения", ТекстСообщения);
	КонтекстКоманды.Вставить("ИдентификаторСообщения", ИдентификаторСообщения);
	КонтекстКоманды.Вставить("КомандаСообщения", КомандаСообщения);
	КонтекстКоманды.Вставить("ИдентификаторЧата", ИдентификаторЧата);
	
	
	Если ЭтоСообщениеКаталог(ТекстСообщения) Тогда
		Возврат ОбработатьКомандуКаталога(КонтекстКоманды);
	КонецЕсли;
	
	Если ЭтоСообщениеОбъект(ТекстСообщения) Тогда
		Возврат ОбработатьКомандуОбъекта(КонтекстКоманды);
	КонецЕсли;	
		
	Возврат HTTPСервисы.СформироватьHTTPОтвет(200);
	
КонецФункции

Функция ЭтоСообщениеКаталог(ТекстСообщения)
	Возврат СтрНачинаетсяС(ТекстСообщения, "Список:");
КонецФункции

Функция ЭтоСообщениеОбъект(ТекстСообщения)
	Возврат СтрНачинаетсяС(ТекстСообщения, "Объект:");
КонецФункции

Функция ЭтоВозвратВНачало(ТекстСообщения)
	Возврат ТекстСообщения = "В начало";
КонецФункции

Функция ОбработатьКомандуКаталога(КонтекстКоманды)
	
	СтрокиТекстаСообщения = СтрРазделить(КонтекстКоманды.ТекстСообщения, Символы.ПС);
	
	ПредставлениеКаталога = СтрЗаменить(СтрокиТекстаСообщения[0], "Список: ", "");
	Каталог = Перечисления.ВидыКаталогов.НайтиПоПредставлению(ПредставлениеКаталога);
	
	СтрокаПоиска = "";
	Если СтрокиТекстаСообщения.Количество() > 1 
		И СтрНачинаетсяС(СтрокиТекстаСообщения[1], "Фильтр: ") Тогда
		СтрокаПоиска = СтрЗаменить(СтрокиТекстаСообщения[1], "Фильтр: ", "");
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Каталог) Тогда
		Возврат HTTPСервисы.СформироватьHTTPОтвет(200);
	КонецЕсли;
	
	Если СтрНачинаетсяС(КонтекстКоманды.КомандаСообщения, "page_") Тогда
		
		НомерСтраницы = Число(СтрЗаменить(КонтекстКоманды.КомандаСообщения, "page_", ""));
			
		ТекстНовогоСообщения = "";
		
		КомандаУправленияКлавиатурой = КоманднаяПанельКаталога(КонтекстКоманды, Каталог,
			ТекстНовогоСообщения, НомерСтраницы, СтрокаПоиска);	
		
		Ответ = Новый Структура;
		Ответ.Вставить("method", "editMessageText");
		Ответ.Вставить("chat_id", КонтекстКоманды.ИдентификаторЧата);
		Ответ.Вставить("message_id", КонтекстКоманды.ИдентификаторСообщения);
		Ответ.Вставить("text", ТекстНовогоСообщения);
		Ответ.Вставить("reply_markup", КомандаУправленияКлавиатурой);
		
		Возврат HTTPСервисы.СформироватьHTTPОтвет(200, Ответ);
		
	Иначе
		
		Ссылка = Неопределено;
		
		ТелеграмПереопределяемый.ПриПолученииСсылкиНаОбъект(Каталог, КонтекстКоманды.КомандаСообщения, Ссылка);
		
		Если Не ЗначениеЗаполнено(Ссылка) Тогда
			Возврат HTTPСервисы.СформироватьHTTPОтвет(200);
		КонецЕсли;		
		
		ОписаниеОбъекта = Новый Структура;
		ОписаниеОбъекта.Вставить("Сообщение");
		ОписаниеОбъекта.Вставить("Команды", Новый Массив);
		ОписаниеОбъекта.Вставить("БыстрыйОтвет", Ложь);
		ОписаниеОбъекта.Вставить("Картинка", "");
		
		ТелеграмПереопределяемый.ПриПолученииОписанияОбъекта(Ссылка, ОписаниеОбъекта);
		
		СтрокиОписанияКарточки = Новый Массив;
		СтрокиОписанияКарточки.Добавить("Объект: " + Каталог);
		СтрокиОписанияКарточки.Добавить(ОписаниеОбъекта.Сообщение);
		
		Если ОписаниеОбъекта.Свойство("Картинка") И Не ПустаяСтрока(ОписаниеОбъекта.Картинка) Тогда
			ОтправитьФото(ОписаниеОбъекта.Картинка, КонтекстКоманды.ИдентификаторЧата);
		КонецЕсли;			
					
		Ответ = НовыйОтветСлужебный(КонтекстКоманды.ИдентификаторЧата);
		Ответ.text = СтрСоединить(СтрокиОписанияКарточки, Символы.ПС);		
		
		БыстрыйОтвет = Ложь;
		Если ОписаниеОбъекта.Свойство("БыстрыйОтвет") И ОписаниеОбъекта.БыстрыйОтвет Тогда
			БыстрыйОтвет = Истина;
		КонецЕсли;		
		
		Если Не БыстрыйОтвет Тогда
			Ответ.Вставить("reply_markup", 
				КоманднаяПанельОбъекта(КонтекстКоманды.КомандаСообщения, ОписаниеОбъекта.Команды));
		Иначе
			ОписаниеБыстрогоОтвета = Новый Структура;
			ОписаниеБыстрогоОтвета.Вставить("force_reply", Истина);
			Ответ.Вставить("reply_markup", ОписаниеБыстрогоОтвета);
		КонецЕсли;
		
		Возврат HTTPСервисы.СформироватьHTTPОтвет(200, Ответ);		
		
	КонецЕсли;
	
	Возврат HTTPСервисы.СформироватьHTTPОтвет(200);	
	
КонецФункции

Функция ОтправитьФото(Картинка, ИдентификаторЧата)
	
	ПараметрыПодключения = ТелеграмПовтИсп.ПараметрыПодключенияТелеграм();
	
	ШаблонТекстаЗапроса = "/bot%1/sendPhoto?chat_id=%2";
	URL = СтрШаблон(ШаблонТекстаЗапроса, ПараметрыПодключения.Токен, XMLСтрока(ИдентификаторЧата));
	
	Разделитель = "----" + Строка(Новый УникальныйИдентификатор);

	ИмяФайла = "photo.jpg";
	
	Данные = Новый Соответствие;
	Данные.Вставить("Boundary", Разделитель);
	Данные.Вставить("Данные", ПолучитьИзВременногоХранилища(Картинка));
	Данные.Вставить("ИмяФайла", ИмяФайла);
	Данные.Вставить("type", "photo");
	
	ssl = Новый ЗащищенноеСоединениеOpenSSL();		
	СоединениеHTTP = Новый HTTPСоединение("api.telegram.org", 443,,,,,ssl,Ложь);
	HTTPЗапрос = Новый HTTPЗапрос;
	HTTPЗапрос.Заголовки.Вставить("Content-Type", "multipart/form-data; boundary=" + Разделитель);
	
	ТелоЗапроса = СформироватьТекстЗапроса(Данные);
	HTTPЗапрос.УстановитьТелоИзДвоичныхДанных(ТелоЗапроса);	
	HTTPЗапрос.АдресРесурса = URL;
	
	Ответ = СоединениеHTTP.ОтправитьДляОбработки(HTTPЗапрос);		
	
КонецФункции

Функция СформироватьТекстЗапроса(Данные)
	
	Разделитель =  Данные["Boundary"];
	
	ТелоОтвета = Новый ПотокВПамяти;
	
	ЗаписьДанных = Новый ЗаписьДанных(ТелоОтвета);
	ЗаписьДанных.ЗаписатьСтроку("--" + Разделитель);
	
	ЗаписьДанных.Записать(ЧастьСоставныхДанных(Данные));
	
	ЗаписьДанных.ЗаписатьСтроку("--" + Разделитель + "--");
	ЗаписьДанных.Закрыть();
	
	Возврат ТелоОтвета.ЗакрытьИПолучитьДвоичныеДанные();
	
КонецФункции

Функция ЧастьСоставныхДанных(Данные)

	Поток = Новый ПотокВПамяти;
	ЗаписьДанных = Новый ЗаписьДанных(Поток);
	ЗаписьДанных.ЗаписатьСтроку("Content-Disposition: form-data; name=""" + Данные["type"] + """; filename=" + Данные["ИмяФайла"] + "");
	ЗаписьДанных.ЗаписатьСтроку("Content-Type: application/x-zip-compressed");
	
	ЗаписьДанных.ЗаписатьСтроку("");
	
	ЗаписьДанных.Записать(Данные["Данные"]);
	ЗаписьДанных.ЗаписатьСимволы(Символы.ПС);
	
	ЗаписьДанных.Закрыть();
	
	Возврат Поток.ЗакрытьИПолучитьДвоичныеДанные();
	
КонецФункции

Функция КоманднаяПанельОбъекта(ИдентификаторОбъекта, Команды)
	
	Клавиатура = Новый Массив;
	
	Для Каждого ОписаниеКоманды Из Команды Цикл
		СтрокаКлавиатуры = Новый Массив;
		Кнопка = Новый Структура;
		Кнопка.Вставить("text", ОписаниеКоманды.Наименование);
		Кнопка.Вставить("callback_data", ИдентификаторОбъекта + "/" + ОписаниеКоманды.id);
		СтрокаКлавиатуры.Добавить(Кнопка);
		Клавиатура.Добавить(СтрокаКлавиатуры);
	КонецЦикла;
	
	Результат = Новый Структура;
	Результат.Вставить("inline_keyboard", Клавиатура);
	
	Возврат Результат;
	
КонецФункции

Функция ОбработатьКомандуОбъекта(КонтекстКоманды)
	
	СтрокиТекстаСообщения = СтрРазделить(КонтекстКоманды.ТекстСообщения, Символы.ПС);
	
	ПредставлениеКаталога = СтрЗаменить(СтрокиТекстаСообщения[0], "Объект: ", "");
	Каталог = Перечисления.ВидыКаталогов.НайтиПоПредставлению(ПредставлениеКаталога);
	
	ЧастиКоманды = СтрРазделить(КонтекстКоманды.КомандаСообщения, "/");
	
	Если ЧастиКоманды.Количество() < 2 Тогда
		Возврат HTTPСервисы.СформироватьHTTPОтвет(200);
	КонецЕсли;
	
	ИдентификаторОбъекта = ЧастиКоманды[0];
	ИдентификаторКоманды = ЧастиКоманды[1];
	
	Ссылка = Неопределено;
	
	ТелеграмПереопределяемый.ПриПолученииСсылкиНаОбъект(Каталог, ИдентификаторОбъекта, Ссылка);
	
	Если Не ЗначениеЗаполнено(Ссылка) Тогда
		Возврат HTTPСервисы.СформироватьHTTPОтвет(200);
	КонецЕсли;		

	ТекстКомментария = "";
	СписокКоманд = Новый Массив;
	
	ФизЛицо = КонтекстКоманды.ТекущийПользователь.ФизическоеЛицо;
	
	ТелеграмПереопределяемый.ПриОбработкеКомандыОбъекта(ФизЛицо, Ссылка, 
		ИдентификаторКоманды, ТекстКомментария, СписокКоманд);
	
	Если Не ПустаяСтрока(ТекстКомментария) Тогда
		ОтправитьТекстовоеСообщение(ТекстКомментария, КонтекстКоманды.ИдентификаторЧата);
	КонецЕсли;
	
	Ответ = Новый Структура;
	Ответ.Вставить("method", "editMessageReplyMarkup");
	Ответ.Вставить("chat_id", КонтекстКоманды.ИдентификаторЧата);
	Ответ.Вставить("message_id", КонтекстКоманды.ИдентификаторСообщения);
	Ответ.Вставить("reply_markup", КоманднаяПанельОбъекта(ИдентификаторОбъекта, СписокКоманд));
	
	Возврат HTTPСервисы.СформироватьHTTPОтвет(200, Ответ);			
	
КонецФункции

Функция ОбработатьСообщениеЧата(ДанныеЗапроса)
	
	РезультатПроверки = ПроверитьПравоИспользованияБота(ДанныеЗапроса);
	
	Если Не РезультатПроверки.ЕстьПраво Тогда
		Возврат РезультатПроверки.ОтветПользователю;
	КонецЕсли;	
	
	ТекущийПользователь = РезультатПроверки.ТекущийПользователь;
	
	ОписаниеОтвета = Неопределено;	
		
	ТекстСообщения = ДанныеЗапроса.message.text;
	
	Если ЭтоВозвратВНачало(ТекстСообщения) Тогда
		Возврат ОтобразитьГлавноеМеню(ДанныеЗапроса, ТекущийПользователь);		
	КонецЕсли;	
	
	Если ДанныеЗапроса.message.Свойство("reply_to_message") Тогда
		ТекстПредыдущегоСообщения = ДанныеЗапроса.message.reply_to_message.text;
	КонецЕсли;
	
	ТелеграмПереопределяемый.ОбработатьСообщениеЧата(ТекстСообщения,
		ТекстПредыдущегоСообщения, 
		ТекущийПользователь.ФизическоеЛицо, 
		ТекущийПользователь.УчетнаяЗапись,
		ОписаниеОтвета);
	
	Если ОписаниеОтвета = Неопределено Тогда
		Ответ = ОтветНеизвестнаяКоманда(ДанныеЗапроса, ТекущийПользователь);
	Иначе
		Ответ = ПодготовитьОтвет(ОписаниеОтвета, ТекущийПользователь);
	КонецЕсли;
		
	Возврат Ответ;
	
КонецФункции

Функция ПроверитьПравоИспользованияБота(ДанныеЗапроса)
	
	Результат = Новый Структура;
	Результат.Вставить("ЕстьПраво", Истина);
	Результат.Вставить("ОтветПользователю");
	Результат.Вставить("ТекущийПользователь");
		
	ТекущийПользователь = АвторСообщения(ДанныеЗапроса);		
	
	Если Не ЗначениеЗаполнено(ТекущийПользователь.УчетнаяЗапись) Тогда
		Результат.ЕстьПраво = Ложь;
		Результат.ОтветПользователю = РезультатСозданияУчетнойЗаписи(ДанныеЗапроса);
		Возврат Результат;		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ТекущийПользователь.ФизическоеЛицо) Тогда
		Результат.ЕстьПраво = Ложь;
		Результат.ОтветПользователю = РезультатПроверкиНаличияФизЛица(ДанныеЗапроса, ТекущийПользователь);
		Возврат Результат;
	КонецЕсли;	
	
	Результат.ТекущийПользователь = ТекущийПользователь;
	
	Возврат Результат;
	
КонецФункции
 
Функция НовыйОтветСлужебный(ИдентификаторЧата, Метод = Неопределено)
	
	Если Метод = Неопределено Тогда
		Метод = МетодОтправитьСообщение();
	КонецЕсли;	
	
	Результат = Новый Структура;
	Результат.Вставить("method", Метод);
	Результат.Вставить("chat_id", ИдентификаторЧата);
	Результат.Вставить("text", "");
	
	Возврат Результат;		
	
КонецФункции

Функция СформироватьКлавиатуру(ТекущийПользователь)
	
	УчетнаяЗапись = ТекущийПользователь.УчетнаяЗапись;
	
	ПозицияМеню = РегистрыСведений.ТекущиеПозицииМенюУчетныхЗаписей.ТекущаяПозицияМеню(УчетнаяЗапись);
	
	Кнопки = Новый Массив;
	
	ТелеграмПереопределяемый.УстановитьКнопкиМеню(ПозицияМеню, Кнопки);
	
	Если ПозицияМеню <> Перечисления.ПозицииМеню.Старт Тогда
		Кнопки.Добавить("В начало");
	КонецЕсли;	
	
	Клавиатура = Новый Массив;	
	СтрокаКлавиатуры = Новый Массив;
	
	Для Каждого Кнопка Из Кнопки Цикл
		КнопкаКлавиатуры = Новый Структура;
		КнопкаКлавиатуры.Вставить("text", Кнопка);
		СтрокаКлавиатуры.Добавить(Кнопка);
	КонецЦикла;		
	
	Клавиатура.Добавить(СтрокаКлавиатуры);
	
	Результат = Новый Структура;
	Результат.Вставить("keyboard", Клавиатура);
	Результат.Вставить("resize_keyboard", Истина);
	
	Возврат Результат;		
	
КонецФункции

Функция РезультатСозданияУчетнойЗаписи(ДанныеЗапроса)
	
	Сообщение = ДанныеЗапроса.message;
	ДанныеОтправителя = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Сообщение, "from");
	ИдентификаторЧата = Сообщение.chat.id;
	
	Справочники.УчетныеЗаписиТелеграм.НоваяУчетнаяЗапись(ДанныеОтправителя);	
	
	Ответ = НовыйОтветСлужебный(ИдентификаторЧата);
	Ответ.Вставить("text", ТелеграмШаблоныСообщений.ОтветНеизвестномуПользователю());
	
	Возврат HTTPСервисы.СформироватьHTTPОтвет(200, Ответ);
	
КонецФункции 

Функция РезультатПроверкиНаличияФизЛица(ДанныеЗапроса, ТекущийПользователь)
	
	Сообщение = ДанныеЗапроса.message;
	ИдентификаторЧата = Сообщение.chat.id;	

	Ответ = НовыйОтветСлужебный(ИдентификаторЧата);
	Ответ.Вставить("text");
	
	ТекстСообщения = ДанныеЗапроса.message.text;
	
	ФизическоеЛицо = Справочники.ФизическиеЛица.НайтиПоНаименованию(ТекстСообщения, Истина);
	
	Если Не ЗначениеЗаполнено(ФизическоеЛицо) Тогда
		Ответ.text = ТелеграмШаблоныСообщений.ОшибкаПоискаФизическогоЛица();
		Возврат HTTPСервисы.СформироватьHTTPОтвет(200, Ответ);						
	КонецЕсли;
	
	ЭтоДействующийСотрудник = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ФизическоеЛицо, "ДействующийСотрудник");
	
	Если Не ЭтоДействующийСотрудник Тогда
		Ответ.text = ТелеграмШаблоныСообщений.ОшибкаПоискаФизическогоЛица();
		Возврат HTTPСервисы.СформироватьHTTPОтвет(200, Ответ);
	КонецЕсли;
	
	Справочники.УчетныеЗаписиТелеграм.СвязатьУчетнуюЗаписьСФизЛицом(ТекущийПользователь.УчетнаяЗапись, ФизическоеЛицо);
	
	Ответ.text = ТелеграмШаблоныСообщений.УспешнаяСвязьУчетнойЗаписиИФизЛица();
	Ответ.Вставить("reply_markup", СформироватьКлавиатуру(ТекущийПользователь));
	
	Возврат HTTPСервисы.СформироватьHTTPОтвет(200, Ответ);
	
КонецФункции

Функция ПодготовитьОтвет(ОписаниеОтвета, ТекущийПользователь)
	
	ИдентификаторЧата = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ОписаниеОтвета.УчетнаяЗапись, "Код");
	
	КомандаУправленияКлавиатурой = Неопределено;
	
	Если ОписаниеОтвета.ДополнительныеПараметры <> Неопределено Тогда
		
		ДополнительныеПараметры = ОписаниеОтвета.ДополнительныеПараметры;
		РегистрыСведений.ТекущиеПозицииМенюУчетныхЗаписей.УстановитьПозициюМеню(
			ОписаниеОтвета.УчетнаяЗапись, 
			ДополнительныеПараметры.ПозицияМеню);
			
		КонтекстКоманды = Новый Структура;
		КонтекстКоманды.Вставить("ТекущийПользователь", ТекущийПользователь);
			
		Если ЗначениеЗаполнено(ДополнительныеПараметры.ОтобразитьКаталог) Тогда
			КомандаУправленияКлавиатурой = КоманднаяПанельКаталога(КонтекстКоманды, 
				ДополнительныеПараметры.ОтобразитьКаталог,
				ОписаниеОтвета.Текст);
		КонецЕсли;
		
	КонецЕсли;
		
	Если КомандаУправленияКлавиатурой = Неопределено Тогда
		КомандаУправленияКлавиатурой = СформироватьКлавиатуру(ТекущийПользователь);
	КонецЕсли;	 	
	
	Ответ = НовыйОтветСлужебный(ИдентификаторЧата);
	Ответ.Вставить("text", ОписаниеОтвета.Текст);
	Ответ.Вставить("reply_markup", КомандаУправленияКлавиатурой);
	
	Возврат HTTPСервисы.СформироватьHTTPОтвет(200, Ответ);
	
КонецФункции

Функция КоманднаяПанельКаталога(КонтекстКоманды, Каталог, ТекстСообщения, Страница = 0, СтрокаПоиска = "")
	
	ЭлементыКаталога = Новый Массив;
	ТелеграмПереопределяемый.ПриПолученииЭлементовКаталога(ЭлементыКаталога, 
		КонтекстКоманды.ТекущийПользователь.ФизическоеЛицо, 
		Каталог, 
		СтрокаПоиска);	
	
	КоличествоЭлементовКаталога = ЭлементыКаталога.Количество();
	
	Если КоличествоЭлементовКаталога = 0 Тогда
		ТекстСообщения = "Каталог пуст";
		Возврат Неопределено;
	КонецЕсли;
	
	КоличествоСтраниц = Цел(КоличествоЭлементовКаталога / 4);
	Если КоличествоЭлементовКаталога % 4 > 0 Тогда
		КоличествоСтраниц = КоличествоСтраниц + 1;
	КонецЕсли;	
	
	ЭлементыСообщения = Новый Массив;
	ЭлементыСообщения.Добавить("Список: " + Каталог);
	Если Не ПустаяСтрока(СтрокаПоиска) Тогда
		ЭлементыСообщения.Добавить("Фильтр: " + СтрокаПоиска);
	КонецЕсли;
	ЭлементыСообщения.Добавить("Страница " + XMLСтрока(Страница + 1) + "/" + XMLСтрока(КоличествоСтраниц));
	
	ТекстСообщения = СтрСоединить(ЭлементыСообщения, Символы.ПС);
	
	Клавиатура = Новый Массив;
	
	ВыводитьКнопкиНазад = Истина;
	ВыводитьКнопкиВперед = Истина;
	
	Если Страница = КоличествоСтраниц - 1 Тогда
		ВыводитьКнопкиВперед = Ложь;							
	КонецЕсли;
	
	Если Страница = 0 Тогда
		ВыводитьКнопкиНазад = Ложь;				
	КонецЕсли;	
	
	ТекущаяПозиция = Страница * 4;
	
	Пока ТекущаяПозиция < (Страница + 1) * 4
		И ТекущаяПозиция < КоличествоЭлементовКаталога Цикл
		
		ЭлементКаталога = ЭлементыКаталога[ТекущаяПозиция];
		
		СтрокаКлавиатуры = Новый Массив;
		Кнопка = Новый Структура;
		
		Если ТипЗнч(ЭлементКаталога) = Тип("Структура") Тогда
			Кнопка.Вставить("text", ЭлементКаталога.Представление);
			Кнопка.Вставить("callback_data", ЭлементКаталога.Ссылка.УникальныйИдентификатор());
		Иначе
			Кнопка.Вставить("text", Строка(ЭлементКаталога));
			Кнопка.Вставить("callback_data", ЭлементКаталога.УникальныйИдентификатор());
		КонецЕсли;
		
		СтрокаКлавиатуры.Добавить(Кнопка);
		Клавиатура.Добавить(СтрокаКлавиатуры);
		
		ТекущаяПозиция = ТекущаяПозиция + 1;
		
	КонецЦикла;
	
	СтрокаКлавиатуры = Новый Массив;
	
	Если ВыводитьКнопкиНазад Тогда
		
		Кнопка = Новый Структура;
		Кнопка.Вставить("text", "<<");
		Кнопка.Вставить("callback_data", "page_0");
		СтрокаКлавиатуры.Добавить(Кнопка);
		
		Кнопка = Новый Структура;
		Кнопка.Вставить("text", "<");
		Кнопка.Вставить("callback_data", "page_" + XMLСтрока(Страница - 1));
		СтрокаКлавиатуры.Добавить(Кнопка);
		
	КонецЕсли;
	
	Если ВыводитьКнопкиВперед Тогда
		
		Кнопка = Новый Структура;
		Кнопка.Вставить("text", ">");
		Кнопка.Вставить("callback_data", "page_" + XMLСтрока(Страница + 1));
		СтрокаКлавиатуры.Добавить(Кнопка);		
		
		Кнопка = Новый Структура;
		Кнопка.Вставить("text", ">>");
		Кнопка.Вставить("callback_data", "page_" + XMLСтрока(КоличествоСтраниц - 1));
		СтрокаКлавиатуры.Добавить(Кнопка);
		
	КонецЕсли;
		
	Клавиатура.Добавить(СтрокаКлавиатуры);
	
	Результат = Новый Структура;
	Результат.Вставить("inline_keyboard", Клавиатура);
	
	Если Каталог = Перечисления.ВидыКаталогов.Сотрудники Тогда
		ТекстСообщения = ТекстСообщения + "
			|Выберите сотрудника, которому хотите сказать спасибо:";
	КонецЕсли;
	
	Возврат Результат;		
	
КонецФункции

Функция ОтобразитьГлавноеМеню(ДанныеЗапроса, ТекущийПользователь)
	
	Сообщение = ДанныеЗапроса.message;
	ИдентификаторЧата = Сообщение.chat.id;
	
	РегистрыСведений.ТекущиеПозицииМенюУчетныхЗаписей.УстановитьПозициюМеню(
		ТекущийПользователь.УчетнаяЗапись,
		Перечисления.ПозицииМеню.Старт);
	
	Ответ = НовыйОтветСлужебный(ИдентификаторЧата);
	Ответ.Вставить("text", "Переход в главное меню");
	Ответ.Вставить("reply_markup", СформироватьКлавиатуру(ТекущийПользователь));
	
	Возврат HTTPСервисы.СформироватьHTTPОтвет(200, Ответ);
		
КонецФункции

Функция ОтветНеизвестнаяКоманда(ДанныеЗапроса, ТекущийПользователь)
	
	Сообщение = ДанныеЗапроса.message;
	ИдентификаторЧата = Сообщение.chat.id;		
	
	Ответ = НовыйОтветСлужебный(ИдентификаторЧата);
	Ответ.Вставить("text", ТелеграмШаблоныСообщений.ОтветНаНеизвестнуюКоманду());
	Ответ.Вставить("reply_markup", СформироватьКлавиатуру(ТекущийПользователь));
	
	Возврат HTTPСервисы.СформироватьHTTPОтвет(200, Ответ);
		
КонецФункции

Функция АвторСообщения(ДанныеЗапроса)
	
	Если ДанныеЗапроса.Свойство("message") Тогда
		Сообщение = ДанныеЗапроса.message;
		ДанныеОтправителя = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Сообщение, "from");
	ИначеЕсли ДанныеЗапроса.Свойство("callback_query") Тогда
		Сообщение = ДанныеЗапроса.callback_query;
		ДанныеОтправителя = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Сообщение, "from");
	Иначе
		ВызватьИсключение "Неизвестный канал взаимодействия";
	КонецЕсли;		
		
	IdUser = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ДанныеОтправителя, "id");
	
	Результат = Новый Структура;
	Результат.Вставить("УчетнаяЗапись");
	Результат.Вставить("ФизическоеЛицо");
	Результат.Вставить("ЭтоДействующийСотрудник");
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	УчетныеЗаписиТелеграм.Ссылка КАК УчетнаяЗапись,
	|	УчетныеЗаписиТелеграм.ФизическоеЛицо,
	|	УчетныеЗаписиТелеграм.ФизическоеЛицо.ДействующийСотрудник КАК ЭтоДействующийСотрудник
	|ИЗ
	|	Справочник.УчетныеЗаписиТелеграм КАК УчетныеЗаписиТелеграм
	|ГДЕ
	|	УчетныеЗаписиТелеграм.Код = &Код";
	
	Запрос.УстановитьПараметр("Код", IdUser);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		ЗаполнитьЗначенияСвойств(Результат, Выборка);		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции
 
Функция ПараметрыПодключения()
	
	Результат = Новый Структура;
	Результат.Вставить("АдресСервера");
	Результат.Вставить("Токен");
	Результат.Вставить("АдресВебХука");
	Результат.Вставить("Подключен");
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Константы.АдресСервераТелеграм КАК АдресСервера,
	|	Константы.АдресВебХукаТелеграм КАК АдресВебХука,
	|	Константы.ТокенБотаТелеграм КАК Токен,
	|	Константы.ТелеграмПодключен Подключен
	|ИЗ
	|	Константы КАК Константы";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Выборка.Следующий();
	
	ЗаполнитьЗначенияСвойств(Результат, Выборка);
	
	Возврат Результат;
	
КонецФункции

Процедура ПроверитьПараметрыПодключенияПереодПодключением(ПараметрыПодключения, Отказ)
	
	Если Не ЗначениеЗаполнено(ПараметрыПодключения.АдресСервера) Тогда
		ОбщегоНазначения.СообщитьПользователю(НСтр("ru = 'Не заполнен адрес сервера'"),,,, Отказ);
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ПараметрыПодключения.АдресВебХука) Тогда
		ОбщегоНазначения.СообщитьПользователю(НСтр("ru = 'Не заполнен адрес веб-хука'"),,,, Отказ);
	КонецЕсли;	
	
	Если Не ЗначениеЗаполнено(ПараметрыПодключения.Токен) Тогда
		ОбщегоНазначения.СообщитьПользователю(НСтр("ru = 'Не заполнен адрес токен'"),,,, Отказ);
	КонецЕсли;	
	
	Если ПараметрыПодключения.Подключен Тогда
		ОбщегоНазначения.СообщитьПользователю(НСтр("ru = 'Бот уже подключен'"),,,, Отказ);
	КонецЕсли;	
	
КонецПроцедуры

Процедура СоздатьСлужебногоПользователяТелеграм()
	
	Логин = СлужебныйПользовательМессенджеровЛогин();
	Пароль = СлужебныйПользовательМессенджеровПароль();
	
	УстановитьПривилегированныйРежим(Истина);
	
	СлужебныйПользователь = Пользователи.НайтиПоИмени(Логин);
	
	Если СлужебныйПользователь = Неопределено Тогда
		
		ОписаниеПользователяИБ = Пользователи.НовоеОписаниеПользователяИБ();
		ОписаниеПользователяИБ.Имя = Логин;
		ОписаниеПользователяИБ.ПолноеИмя = НСтр("ru='Служебный пользователь телеграмма'");
		ОписаниеПользователяИБ.АутентификацияСтандартная = Истина;
		ОписаниеПользователяИБ.ПоказыватьВСпискеВыбора = Ложь;
		ОписаниеПользователяИБ.Вставить("Действие", "Записать");
		ОписаниеПользователяИБ.Вставить("ВходВПрограммуРазрешен", Истина);
		ОписаниеПользователяИБ.ЗапрещеноИзменятьПароль = Истина;
		ОписаниеПользователяИБ.Пароль = Пароль;
		ОписаниеПользователяИБ.Роли = Новый Массив;
		ОписаниеПользователяИБ.Роли.Добавить(Метаданные.Роли.ИспользованиеМетодовИнтеграцииТелеграм.Имя);
		
		НовыйПользователь = Справочники.Пользователи.СоздатьЭлемент();
		НовыйПользователь.Наименование = ОписаниеПользователяИБ.ПолноеИмя;
		НовыйПользователь.Служебный = Истина;
		НовыйПользователь.ДополнительныеСвойства.Вставить("ОписаниеПользователяИБ", ОписаниеПользователяИБ);
		НовыйПользователь.Записать();
		
	Иначе
		
		ОбновитьНастройкиСлужебногоПользователяТелегам(Пароль, СлужебныйПользователь);
		
	КонецЕсли;	
	
КонецПроцедуры

Процедура ПроверитьДоступностьВебХука()
	
	Адрес = АдресПубликацииВебХука();
	
	ULR = Адрес + "ping";
	
	Ответ = HTTPСервисы.ВыполнитьЗапрос("GET", ULR);
	
	Если Ответ.КодСостояния <> 200 Тогда
		ШаблонТекстаОшибки = НСтр("ru = 'Некорректный ответ при проверке доступности веб-хука. (Код возврата: %1)'");
		ВызватьИсключение СтрШаблон(ШаблонТекстаОшибки, Ответ.КодСостояния);
	КонецЕсли;
	
КонецПроцедуры

Процедура УстановитьВебХукБота()
	
	АдресСервера = АдресСервераТелеграм();
	
	Токен = Константы.ТокенБотаТелеграм.Получить();
	
	Команда = "setWebhook";
	
	ШаблонТекстаЗапроса = "%1bot%2/%3?url=%4";
	
	URL = СтрШаблон(ШаблонТекстаЗапроса, АдресСервера, Токен, Команда, 
	КодироватьСтроку(ПолныйАдресВебХука(), СпособКодированияСтроки.КодировкаURL));
	
	Ответ = HTTPСервисы.ВыполнитьЗапрос("GET", URL);
	
	Если Ответ.КодСостояния <> 200 Тогда
		ТекстОшибки = НСтр("ru = 'Не удалось установить Webhook!'");
		ЗаписьЖурналаРегистрации(ИмяСобытия("setWebhook"), УровеньЖурналаРегистрации.Ошибка,,
		ТекстОшибки, HTTPСервисыСлужебный.ПредставлениеОбъектаHTTP(Ответ));
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	Результат = HTTPСервисы.ЗначениеИзТелаJSON(Ответ);
	Если НЕ ЗначениеЗаполнено(Результат) Тогда
		ТекстОшибки = НСтр("ru = 'Не удалось установить Webhook!'");
		ЗаписьЖурналаРегистрации(ИмяСобытия("SetWebhook"), УровеньЖурналаРегистрации.Ошибка,, 
		Ответ.КодСостояния, Ответ.ПолучитьТелоКакСтроку());
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;	
	
	// @skip-warning
	Если Не Результат["ok"] Тогда
		ТекстОшибки = НСтр("ru = 'Не удалось установить Webhook!'");
		ЗаписьЖурналаРегистрации(ИмяСобытия("SetWebhook"), УровеньЖурналаРегистрации.Ошибка,, 
		Ответ.КодСостояния, Ответ.ПолучитьТелоКакСтроку());
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;		
	
КонецПроцедуры

Процедура ПроверитьПодключение()
	
	БотПодключен = Константы.ТелеграмПодключен.Получить();
	
	Если Не БотПодключен Тогда
		ВызватьИсключение НСтр("ru = 'Бот не подключен. Выполнение действия невозможно.'")
	КонецЕсли;	
	
КонецПроцедуры

Функция ПустоеСостояниеБота()
	
	Результат = Новый Структура;
	Результат.Вставить("АдресWebhook", "");
	Результат.Вставить("СообщенийОжидаетДоставки", 0);
	Результат.Вставить("ДатаПоследнейОшибки");
	Результат.Вставить("ТекстПоследнейОшибки", "");
	Результат.Вставить("ИмяУчетнойЗаписи", "");
	Результат.Вставить("Фамилия", "");
	Результат.Вставить("Идентификатор", "");
	Результат.Вставить("Язык", "");
	
	Возврат Результат;	
	
КонецФункции
 
Функция АдресПубликацииВебХука()
	
	Шаблон = "%1hs/tg-api/";
	
	АдресИБ = Константы.АдресВебХукаТелеграм.Получить();
	
	Если Не СтрЗаканчиваетсяНа(АдресИБ, "/") Тогда
		АдресИБ = АдресИБ + "/";
	КонецЕсли;
	
	Возврат СтрШаблон(Шаблон, АдресИБ);
	
КонецФункции
 
Функция СлужебныйПользовательМессенджеровЛогин()
	Возврат "MessageService";
КонецФункции

Функция СлужебныйПользовательМессенджеровПароль()
	Возврат "0ac36ae0-eef9-4c26-a7a5-62abd77b3506";
КонецФункции
 
Процедура ОбновитьНастройкиСлужебногоПользователяТелегам(Знач Пароль, Знач Пользователь)
	
	ОбновляемыеСвойства = Новый Структура;
	ОбновляемыеСвойства.Вставить("СтарыйПароль", Пароль);
	ОбновляемыеСвойства.Вставить("АутентификацияСтандартная", Истина);
	
	Пользователи.УстановитьСвойстваПользователяИБ(
	ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Пользователь, "ИдентификаторПользователяИБ"),
	ОбновляемыеСвойства,
	Ложь,
	Ложь);
	
КонецПроцедуры
 
Функция ПолныйАдресВебХука()
	
	АдресПубликации = АдресПубликацииВебХука();
	
	Токен = Константы.ТокенБотаТелеграм.Получить();
	
	Шаблон = "%1send/%2";
	
	Возврат СтрШаблон(Шаблон, АдресПубликации, Токен);
	
КонецФункции

Функция ИмяСобытия(ИмяМетода)
	
	Возврат "Телеграм." + ИмяМетода; 
	
КонецФункции	

Функция МетодОтправитьСообщение()
	Возврат "sendMessage";
КонецФункции

#КонецОбласти