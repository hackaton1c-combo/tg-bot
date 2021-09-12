
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
		// Обработать обратный вызов
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

Функция МетодОтправитьСообщение()
	Возврат "sendMessage";
КонецФункции

Функция НовыйОтветНаСообщение(УчетнаяЗапись, ТекстСообщения, ДополнительныеПараметры = Неопределено) Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("УчетнаяЗапись", УчетнаяЗапись);
	Результат.Вставить("ТекстСообщения", ТекстСообщения);
	Результат.Вставить("ДополнительныеПараметры", ДополнительныеПараметры);
	
	Возврат Результат;
	
КонецФункции

Функция НовыеДополнительныеПараметрыСообщенияФизЛицу() Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("ПозицияМеню", Перечисления.ПозицииМеню.Старт);
	Результат.Вставить("КомандыСообщения", Новый Массив);
	Результат.Вставить("ОтобразитьКаталог", Перечисления.ВидыКаталогов.ПустаяСсылка());
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

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

Функция ОбработатьСообщениеЧата(ДанныеЗапроса)
	
	ТекущийПользователь = АвторСообщенияЧата(ДанныеЗапроса);		
	
	Если Не ЗначениеЗаполнено(ТекущийПользователь.УчетнаяЗапись) Тогда
		Возврат РезультатСозданияУчетнойЗаписи(ДанныеЗапроса);		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ТекущийПользователь.ФизическоеЛицо) Тогда
		Возврат РезультатПроверкиНаличияФизЛица(ДанныеЗапроса, ТекущийПользователь);
	КонецЕсли;
	
	Ответ = Неопределено;	
		
	//ТекстСообщения = ДанныеЗапроса.message.text;
	
	//ТелеграмПереопределяемый.ОбработатьСообщениеЧата(ТекстСообщения, ТекущийПользователь, Ответ);
		
	Если Ответ = Неопределено Тогда
		Ответ = ОтветНеизвестнаяКоманда(ДанныеЗапроса, ТекущийПользователь);
	КонецЕсли;
		
	Возврат Ответ;
	
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

Функция АвторСообщенияЧата(ДанныеЗапроса)
	
	Сообщение = ДанныеЗапроса.message;
	ДанныеОтправителя = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Сообщение, "from");
	
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

#КонецОбласти