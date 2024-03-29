﻿Перем юТест;
Перем ВременныеФайлы;

Функция ПолучитьСписокТестов(ЮнитТестирование) Экспорт
	
	юТест = ЮнитТестирование;
	
	ВсеТесты = Новый Массив;
	
	ВсеТесты.Добавить("ТестДолжен_СоздатьАрхивЧерезКонструкторИмениФайла");
	ВсеТесты.Добавить("ТестДолжен_СоздатьАрхивЧерезМетодОткрыть");
	ВсеТесты.Добавить("ТестДолжен_ДобавитьВАрхивОдиночныйФайлБезПутей");
	ВсеТесты.Добавить("ТестДолжен_ДобавитьВАрхивОдиночныйСПолнымПутем");
	ВсеТесты.Добавить("ТестДолжен_ДобавитьВАрхивКаталогТестов");
	ВсеТесты.Добавить("ТестДолжен_ДобавитьВАрхивКаталогТестовПоМаске");
	ВсеТесты.Добавить("ТестДолжен_ПроверитьИзвлечениеБезПутей");
	
	Возврат ВсеТесты;
	
КонецФункции

Функция СоздатьВременныйФайл(Знач Расширение = "tmp")
	
	Если ВременныеФайлы = Неопределено Тогда
		ВременныеФайлы = Новый Массив;
	КонецЕсли;
	
	ИмяВремФайла = ПолучитьИмяВременногоФайла(Расширение);
	ВременныеФайлы.Добавить(ИмяВремФайла);
	
	Возврат ИмяВремФайла;
	
КонецФункции

Процедура ОчиститьВременныеФайлы()
	
	Если ВременныеФайлы <> Неопределено Тогда
		Для Каждого ИмяФайла Из ВременныеФайлы Цикл
			Попытка
				УдалитьФайлы(ИмяФайла);
			Исключение
				Сообщить("Не удален временный файл: " + ИмяФайла + "
				|-" + ОписаниеОшибки());
			КонецПопытки;
		КонецЦикла;
		
		ВременныеФайлы.Очистить();
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПослеЗапускаТеста() Экспорт
	ОчиститьВременныеФайлы();
КонецПроцедуры

Процедура ТестДолжен_СоздатьАрхивЧерезКонструкторИмениФайла() Экспорт
	
	ИмяАрхива = СоздатьВременныйФайл("zip");
	Архив = Новый ЗаписьZipФайла(ИмяАрхива);
	Архив.Записать();
	
	Файл = Новый Файл(ИмяАрхива);
	юТест.ПроверитьИстину(Файл.Существует());
	
КонецПроцедуры

Процедура ТестДолжен_СоздатьАрхивЧерезМетодОткрыть() Экспорт
	
	ИмяАрхива = СоздатьВременныйФайл("zip");
	Архив = Новый ЗаписьZipФайла();
	Архив.Открыть(ИмяАрхива,,"Это комментарий",,УровеньСжатияZip.Максимальный);
	Архив.Записать();
	
	Файл = Новый Файл(ИмяАрхива);
	юТест.ПроверитьИстину(Файл.Существует());
	
КонецПроцедуры

Процедура ТестДолжен_ДобавитьВАрхивОдиночныйФайлБезПутей() Экспорт
	
	ФайлСкрипта = ТекущийСценарий().Источник;
	
	ИмяАрхива = ПолучитьИмяВременногоФайла("zip");
	Архив = Новый ЗаписьZipФайла();
	Архив.Открыть(ИмяАрхива,,"Это комментарий",,УровеньСжатияZip.Максимальный);
	Архив.Добавить(ФайлСкрипта, РежимСохраненияПутейZip.НеСохранятьПути);
	Архив.Записать();
	
	Чтение = Новый ЧтениеZipФайла(ИмяАрхива);
	
	Попытка
		юТест.ПроверитьРавенство("", Чтение.Элементы[0].Путь);
		юТест.ПроверитьРавенство("zip.os", Чтение.Элементы[0].Имя);
		юТест.ПроверитьРавенство("zip", Чтение.Элементы[0].ИмяБезРасширения);
	Исключение	
		Чтение.Закрыть();
		ВызватьИсключение;
	КонецПопытки;
	
	Чтение.Закрыть();
	
КонецПроцедуры

Процедура ТестДолжен_ДобавитьВАрхивОдиночныйСПолнымПутем() Экспорт
	
	ФайлСкрипта = Новый Файл(ТекущийСценарий().Источник);
	
	ИмяАрхива = ПолучитьИмяВременногоФайла("zip");
	Архив = Новый ЗаписьZipФайла();
	Архив.Открыть(ИмяАрхива);
	Архив.Добавить(ФайлСкрипта.ПолноеИмя, РежимСохраненияПутейZip.СохранятьПолныеПути);
	Архив.Записать();
	
	Чтение = Новый ЧтениеZipФайла(ИмяАрхива);
	
	СИ = Новый СистемнаяИнформация;
	Если Найти(СИ.ВерсияОС, "Windows") > 0 Тогда
		ИмяБезДиска = Сред(ФайлСкрипта.Путь, Найти(ФайлСкрипта.Путь, "\")+1);
	Иначе
		ИмяБезДиска = Сред(ФайлСкрипта.Путь,2);
	КонецЕсли;
	
	Попытка
		юТест.ПроверитьРавенство(ИмяБезДиска, Чтение.Элементы[0].Путь);
	Исключение	
		Чтение.Закрыть();
		УдалитьФайлы(ИмяАрхива);
		ВызватьИсключение;
	КонецПопытки;
	
	Чтение.Закрыть();
	
КонецПроцедуры

Процедура ТестДолжен_ДобавитьВАрхивКаталогТестов() Экспорт

	ФайлСкрипта = Новый Файл(ТекущийСценарий().Источник);
	КаталогСкрипта = Новый Файл(ФайлСкрипта.Путь);
	
	ВременныйКаталог = СоздатьВременныйФайл();
	КаталогКопииТестов = ОбъединитьПути(ВременныйКаталог, КаталогСкрипта.Имя);
	СоздатьКаталог(КаталогКопииТестов);
	ВсеФайлы = НайтиФайлы(КаталогСкрипта.ПолноеИмя, "*.os");
	Для Каждого Файл Из ВсеФайлы Цикл
		Если Файл.ЭтоФайл() Тогда
			КопироватьФайл(Файл.ПолноеИмя, ОбъединитьПути(КаталогКопииТестов, Файл.Имя));
		КонецЕсли;
	КонецЦикла;
	
	ИмяАрхива = ПолучитьИмяВременногоФайла("zip");
	Архив = Новый ЗаписьZipФайла();
	Архив.Открыть(ИмяАрхива);
	Архив.Добавить(ВременныйКаталог,,РежимОбработкиПодкаталоговZIP.ОбрабатыватьРекурсивно);
	Архив.Записать();
	
	ОжидаемоеИмя = КаталогСкрипта.Имя + ПолучитьРазделительПути();
	Чтение = Новый ЧтениеZipФайла(ИмяАрхива);
	Для Каждого Элемент Из Чтение.Элементы Цикл
		юТест.ПроверитьРавенство(ОжидаемоеИмя, Элемент.Путь);
	КонецЦикла;
	
	юТест.ПроверитьРавенство(ВсеФайлы.Количество(), Чтение.Элементы.Количество());
	
КонецПроцедуры

Процедура ТестДолжен_ДобавитьВАрхивКаталогТестовПоМаске() Экспорт

	ФайлСкрипта = Новый Файл(ТекущийСценарий().Источник);
	КаталогСкрипта = Новый Файл(ФайлСкрипта.Путь);
	
	ВременныйКаталог = СоздатьВременныйФайл();
	КаталогКопииТестов = ОбъединитьПути(ВременныйКаталог, КаталогСкрипта.Имя);
	СоздатьКаталог(КаталогКопииТестов);
	ВсеФайлы = НайтиФайлы(КаталогСкрипта.ПолноеИмя, "*.*");
	РасширениеТестов = ".os";
	КоличествоТестов = 0;
	Для Каждого Файл Из ВсеФайлы Цикл
		Если Файл.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;
		
		Если Файл.Расширение = РасширениеТестов Тогда
			КоличествоТестов = КоличествоТестов + 1;
		КонецЕсли;
		КопироватьФайл(Файл.ПолноеИмя, ОбъединитьПути(КаталогКопииТестов, Файл.Имя));
	КонецЦикла;
	
	ИмяАрхива = ПолучитьИмяВременногоФайла("zip");
	Архив = Новый ЗаписьZipФайла(ИмяАрхива);
	Архив.Добавить(ВременныйКаталог + ПолучитьРазделительПути() + "*.os",,РежимОбработкиПодкаталоговZIP.ОбрабатыватьРекурсивно);
	Архив.Записать();
	
	ОжидаемоеИмя = КаталогСкрипта.Имя + ПолучитьРазделительПути();
	Чтение = Новый ЧтениеZipФайла(ИмяАрхива);
	Для Каждого Элемент Из Чтение.Элементы Цикл
		юТест.ПроверитьРавенство(ОжидаемоеИмя, Элемент.Путь);
		юТест.ПроверитьРавенство(РасширениеТестов, Элемент.Расширение);
	КонецЦикла;
	
	юТест.ПроверитьИстину(КоличествоТестов > 0);
	юТест.ПроверитьРавенство(КоличествоТестов, Чтение.Элементы.Количество());
	
КонецПроцедуры

Процедура ТестДолжен_ПроверитьИзвлечениеБезПутей() Экспорт
	
	ФайлСкрипта = Новый Файл(ТекущийСценарий().Источник);
	КаталогСкрипта = Новый Файл(ФайлСкрипта.Путь);
	
	ВременныйКаталог = СоздатьВременныйФайл();
	КаталогКопииТестов = ОбъединитьПути(ВременныйКаталог, КаталогСкрипта.Имя);
	СоздатьКаталог(КаталогКопииТестов);
	ВсеФайлы = НайтиФайлы(КаталогСкрипта.ПолноеИмя, "*.os");
	Для Каждого Файл Из ВсеФайлы Цикл
		Если Файл.ЭтоФайл() Тогда
			КопироватьФайл(Файл.ПолноеИмя, ОбъединитьПути(КаталогКопииТестов, Файл.Имя));
		КонецЕсли;
	КонецЦикла;
	
	ИмяАрхива = ПолучитьИмяВременногоФайла("zip");
	Архив = Новый ЗаписьZipФайла();
	Архив.Открыть(ИмяАрхива);
	Архив.Добавить(ВременныйКаталог,,РежимОбработкиПодкаталоговZIP.ОбрабатыватьРекурсивно);
	Архив.Записать();
	
	Чтение = Новый ЧтениеZipФайла(ИмяАрхива);
	КаталогИзвлечения = СоздатьВременныйФайл();
	СоздатьКаталог(КаталогИзвлечения);
	Чтение.ИзвлечьВсе(КаталогИзвлечения, РежимВосстановленияПутейФайловZIP.НеВосстанавливать);
	
	ИзвлеченныеФайлы = НайтиФайлы(КаталогИзвлечения, "*.*");
	
	юТест.ПроверитьНеравенство(0, ИзвлеченныеФайлы.Количество());
	юТест.ПроверитьРавенство(ВсеФайлы.Количество(), ИзвлеченныеФайлы.Количество());
	
КонецПроцедуры
