#Использовать fs
#Использовать gitrunner
#Использовать logos

Перем Лог;
Перем Параметры;
Перем ГитРепозиторий;

Функция Имя() Экспорт
	Возврат "Версионирование в GIT";
КонецФункции

Процедура ОписаниеКоманды(Команда) Экспорт

	Команда.Опция("rep gitrepopath", "", Имя() + ": копировать в гит-репозиторий")
				.ТСтрока();
	
	Команда.Опция("src gitreposrc", "", Имя() + ": папка в гит-репозитории (относительно его корня)")
				.ТСтрока();

КонецПроцедуры

Процедура ПриЧтенииПараметров(Команда) Экспорт

	Параметры = Новый Структура();
	Параметры.Вставить("Путь", Команда.ЗначениеОпции("gitrepopath"));
	Параметры.Вставить("Папка", Команда.ЗначениеОпции("gitreposrc"));

КонецПроцедуры

Процедура ПослеЧтенияПараметров() Экспорт

	Если Включен() Тогда
		
		ФС.ОбеспечитьКаталог(Параметры.Путь);
		Лог.Информация("Включен обработчик %1. Путь: %2", Имя(), ФС.ПолныйПуть(Параметры.Путь));

		ГитРепозиторий = Новый ГитРепозиторий();
		ГитРепозиторий.УстановитьРабочийКаталог(Параметры.Путь);

		Если НЕ ГитРепозиторий.ЭтоРепозиторий() Тогда
			ГитРепозиторий.Инициализировать();
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

Функция Включен() Экспорт
	Возврат ЗначениеЗаполнено(Параметры.Путь);
КонецФункции

Процедура ВыполнитьДействие(мФайлыКОбработке) Экспорт

	Для каждого СтрокаТаблицыКонтроля Из мФайлыКОбработке Цикл
		Если СтрокаТаблицыКонтроля.ЭтоКаталог Тогда
			Продолжить;
		КонецЕсли;
		
		Источник = СтрокаТаблицыКонтроля.ПолноеИмя;
		ПутьОтносительноКорняРепозитория = ОбъединитьПути(Параметры.Папка, СтрокаТаблицыКонтроля.Имя);
		Приемник = ОбъединитьПути(Параметры.Путь, ПутьОтносительноКорняРепозитория);
		
		Если СтрокаТаблицыКонтроля.Статус = Перечисления.Статусы.Удален Тогда
			УдалитьФайлы(Приемник);
		Иначе
			КопироватьФайл(Источник, Приемник);
		КонецЕсли;

		ГитРепозиторий.ДобавитьФайлВИндекс(ПутьОтносительноКорняРепозитория);

	КонецЦикла;

	Статус = ГитРепозиторий.Статус(Истина);
	Если НЕ ПустаяСтрока(Статус) Тогда
		Комментарий = Новый Массив;
		Для каждого СтрокаТаблицыКонтроля Из мФайлыКОбработке Цикл
			Если СтрНайти(Статус, СтрокаТаблицыКонтроля.Имя) > 0 Тогда
				Текст = СтрШаблон("%1 в %2 : %3", 
							СтрокаТаблицыКонтроля.Статус,
							Формат(СтрокаТаблицыКонтроля.ДатаКонтроля, "ДФ='dd-MM-yyyy HH:mm:ss'"),
							СтрокаТаблицыКонтроля.Имя);
				Комментарий.Добавить(Текст);

				Если СтрокаТаблицыКонтроля.Статус = Перечисления.Статусы.Удален Тогда
					Лог.Информация("%1: %2 (удален из git-repo %3)", СтрокаТаблицыКонтроля.Статус, СтрокаТаблицыКонтроля.Имя, ПутьОтносительноКорняРепозитория);
				Иначе
					Лог.Информация("%1: %2 (добавлен в git-repo %3)", СтрокаТаблицыКонтроля.Статус, СтрокаТаблицыКонтроля.Имя, ПутьОтносительноКорняРепозитория);
				КонецЕсли;

			КонецЕсли;
		КонецЦикла;
		ГитРепозиторий.Закоммитить(СтрСоединить(Комментарий, Символы.ПС));
	КонецЕсли;

КонецПроцедуры

Лог = Логирование.ПолучитьЛог(ПараметрыПриложения.ИмяЛога());
