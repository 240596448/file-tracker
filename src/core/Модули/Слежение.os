Перем Параметры;
Перем ТаблицаКонтроля;

Процедура УстановитьПараметры(пПараметры) Экспорт

	Параметры.Вставить("Путь", пПараметры.Путь);
	Параметры.Вставить("Фильтр", пПараметры.Фильтр);
	Параметры.Вставить("Рекурсивно", пПараметры.Рекурсивно);
	Параметры.Вставить("Период", пПараметры.Период);
	Параметры.Вставить("Длительность", пПараметры.Длительность);
	
КонецПроцедуры

Процедура ЗапуститьКонтроль() Экспорт

	НачалоКонтроля = ТекущаяДата();
	Сообщить("Начало контроля: " + НачалоКонтроля);

	Если ЗначениеЗаполнено(Параметры.Длительность) Тогда 
		
		ОкончаниеКонтроля = НачалоКонтроля + Параметры.Длительность;
		Сообщить("Ожидаемое окончание контроля: " + ОкончаниеКонтроля);
		УсловиеЦиклаКонтроля = "ТекущаяДата() < ОкончаниеКонтроля";
	
	Иначе

		Сообщить("Окончание контроля: <не задано>");
		УсловиеЦиклаКонтроля = "Истина";

	КонецЕсли;
	
	Пока Вычислить(УсловиеЦиклаКонтроля) Цикл
		ВыполнитьКонтроль();
		Приостановить(Параметры.Период * 1000);
	КонецЦикла;

	Сообщить("Окончание контроля: " + ТекущаяДата());

КонецПроцедуры

Процедура ВыполнитьКонтроль()

	Для каждого Стр Из ТаблицаКонтроля Цикл
		Стр.Статус = Перечисления.Статусы.Удален;
		Стр.ДатаКонтроля = ТекущаяДата();
	КонецЦикла;

	мФайлы = НайтиФайлы(Параметры.Путь, Параметры.Фильтр, Параметры.Рекурсивно);
	Для каждого Файл Из мФайлы Цикл
		ПолноеИмя = Файл.ПолноеИмя;
		
		Стр = ТаблицаКонтроля.Найти(ПолноеИмя, "ПолноеИмя");
		СвойстваФайла = СвойстваФайла(Файл);
		Если Стр = Неопределено Тогда
			Стр = ТаблицаКонтроля.Добавить();
			ЗаполнитьЗначенияСвойств(Стр, СвойстваФайла);
			Стр.Статус = Перечисления.Статусы.Новый;
			Стр.ДатаКонтроля = СвойстваФайла.ДатаИзменения;
		ИначеЕсли Стр.Размер <> СвойстваФайла.Размер
			Или Стр.ДатаИзменения <> СвойстваФайла.ДатаИзменения Тогда
			ЗаполнитьЗначенияСвойств(Стр, СвойстваФайла);
			Стр.Статус = Перечисления.Статусы.Изменен;
			Стр.ДатаКонтроля = СвойстваФайла.ДатаИзменения;
		Иначе
			Стр.Статус = Перечисления.Статусы.НеИзменился;
			Стр.ДатаКонтроля = СвойстваФайла.ДатаИзменения;
		КонецЕсли;

	КонецЦикла;

	мСнятьСКонтроля = Новый Массив;
	мФайлыКОбработке = Новый Массив;
	Для каждого Стр Из ТаблицаКонтроля Цикл
		Если Стр.Статус = Перечисления.Статусы.Удален Тогда
			мСнятьСКонтроля.Добавить(Стр);
		КонецЕсли;
		Если НЕ Стр.Статус = Перечисления.Статусы.НеИзменился Тогда
			мФайлыКОбработке.Добавить(Стр);
		КонецЕсли;
	КонецЦикла;

	Если ЗначениеЗаполнено(мФайлыКОбработке) Тогда
		МенеджерОбработчиков.ВыполнитьОбработчики(мФайлыКОбработке);
	КонецЕсли;

	Для каждого Стр Из мСнятьСКонтроля Цикл
		ТаблицаКонтроля.Удалить(Стр);
	КонецЦикла;

КонецПроцедуры

Функция СвойстваФайла(Файл)
	сткСвойства = Новый Структура();
	сткСвойства.Вставить("ПолноеИмя", Файл.ПолноеИмя);
	сткСвойства.Вставить("Имя", Файл.Имя);
	Если НЕ Файл.ЭтоКаталог() Тогда
		сткСвойства.Вставить("Размер", Файл.Размер());
		сткСвойства.Вставить("ЭтоКаталог", Ложь);
	Иначе
		сткСвойства.Вставить("Размер", 0);
		сткСвойства.Вставить("ЭтоКаталог", Истина);
	КонецЕсли;
	сткСвойства.Вставить("ДатаИзменения", Файл.ПолучитьВремяИзменения());
	Возврат сткСвойства;
КонецФункции

Процедура Инициализировать()

	ТаблицаКонтроля = Новый ТаблицаЗначений();
	
	ТаблицаКонтроля.Колонки.Добавить("ПолноеИмя");
	ТаблицаКонтроля.Колонки.Добавить("Имя");
	ТаблицаКонтроля.Колонки.Добавить("ЭтоКаталог");
	ТаблицаКонтроля.Колонки.Добавить("Размер");
	ТаблицаКонтроля.Колонки.Добавить("ДатаИзменения");
	ТаблицаКонтроля.Колонки.Добавить("Статус");
	ТаблицаКонтроля.Колонки.Добавить("ДатаКонтроля");

	Параметры = Новый Структура();

КонецПроцедуры

Инициализировать();
