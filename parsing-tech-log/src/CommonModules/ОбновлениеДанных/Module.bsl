#Область ЧтениеЖурнала

Процедура ПозиционироватьЧтениеНаСтрокуФайла(ЧтениеФайла, НомерСтроки)
	ТекНомерСтроки = 0;
	ТекСтрокаФайла = "";
	Пока ТекНомерСтроки < НомерСтроки 
		И ТекСтрокаФайла <> Неопределено Цикл
			ТекСтрокаФайла = ЧтениеФайла.ПрочитатьСтроку();
			ТекНомерСтроки = ТекНомерСтроки + 1;
	КонецЦикла; 
КонецПроцедуры

Функция ЗначениеСвойстваБезЭкранирования(ЗначениеСвойства)
	Результат = ЗначениеСвойства;
	Если Лев(ЗначениеСвойства,1)="'" И Прав(ЗначениеСвойства,1)="'" 
		ИЛИ Лев(ЗначениеСвойства,1)="""" И Прав(ЗначениеСвойства,1)="""" Тогда
			Результат = Сред(ЗначениеСвойства,2,СтрДлина(ЗначениеСвойства)-2);	
	КонецЕсли;
	Возврат СокрЛП(Результат);
КонецФункции

Функция ПолучитьВременныеПараметрыПоСвойствамФайла(Знач ФайлТЖ) Экспорт
	
	СвойстваФайла = новый Структура("Год,День,Месяц,Час,ДатаФайла");
	
	СвойстваФайла.Год = Число(Лев(ФайлТЖ.Имя, 2));
	СвойстваФайла.Месяц = Число(Сред(ФайлТЖ.Имя, 3, 2));
	СвойстваФайла.День = Число(Сред(ФайлТЖ.Имя, 5, 2));
	СвойстваФайла.Час = Число(Прав(ФайлТЖ.ИмяБезРасширения, 2));
	СвойстваФайла.ДатаФайла = Дата(СвойстваФайла.Год + 2000, СвойстваФайла.Месяц, СвойстваФайла.День, СвойстваФайла.Час, 0, 0);

	Возврат СвойстваФайла;
	
КонецФункции // ПрочитатьЖурналПоРегистру

#КонецОбласти

#Область Служебные

Функция ИнформационнаяБазаФайловая(Знач СтрокаСоединенияИнформационнойБазы = "") Экспорт
			
	Если ПустаяСтрока(СтрокаСоединенияИнформационнойБазы) Тогда
		СтрокаСоединенияИнформационнойБазы =  СтрокаСоединенияИнформационнойБазы();
	КонецЕсли;
	Возврат Найти(Врег(СтрокаСоединенияИнформационнойБазы), "FILE=") = 1;
	
КонецФункции 

Функция ПолучитьАнализаторНачалаСтроки()
	Возврат ПолучитьАнализаторОбщий("([0-9]{2}):([0-9]{2})\.([0-9]+)\-([0-9]+)\,(\w+)\,(\d+)");
КонецФункции

Функция ПолучитьАнализаторСвойств()
	Возврат ПолучитьАнализаторОбщий(",([^""',=]+)=('[^']+'|""[^""]+""|[^""',]+)");
КонецФункции

Функция ПолучитьАнализаторКавычкиВКавычках()
	Возврат ПолучитьАнализаторОбщий(",([^""',=]+)=""[^""]*""{2}[^""]*""");
КонецФункции

Функция ПолучитьАнализаторОбщий(Выражение)
	Анализатор = Новый COMОбъект("VBScript.RegExp");
	Анализатор.Global = Истина;
	Анализатор.Pattern = Выражение;
	Возврат Анализатор;	
КонецФункции

#КонецОбласти

#Область ЧтениеВСправочник

Функция ПолучитьСтруктуруЗаписиСправочник() Экспорт
	//структура записи журнала
	СтруктураЗаписи = Новый Структура;
	СтруктураЗаписи.Вставить("Владелец");
	СтруктураЗаписи.Вставить("Файл");
	СтруктураЗаписи.Вставить("НомерСтрокиФайла");
	СтруктураЗаписи.Вставить("ДатаСобытия"); 
	СтруктураЗаписи.Вставить("ДатаСобытияМкс");
	СтруктураЗаписи.Вставить("ДлительностьМкс");
	СтруктураЗаписи.Вставить("ТипСобытия");
	СтруктураЗаписи.Вставить("УровеньСобытия");
	СтруктураЗаписи.Вставить("ВсеСвойства");
	СтруктураЗаписи.Вставить("КлючевыеСвойства", Новый Соответствие);
	Возврат СтруктураЗаписи;
КонецФункции

Функция РазобратьФайлВСправочник(Замер, ИмяФайлаДляРазбора) Экспорт
	ФайлЗамера = Справочники.ФайлыЗамера.ПолучитьФайлПоПолномуИмени(Замер, ИмяФайлаДляРазбора);
	
	//еще раз проверим прочитан полностью
	СостояниеЧтения = РегистрыСведений.СостояниеЧтения.ПолучитьСостояние(ФайлЗамера);
	Если СостояниеЧтения.ЧтениеЗавершено Тогда
		Возврат 0;
	КонецЕсли;		
	
	//пропуск пустых файлов
	ФайлТЖ = Новый Файл(ИмяФайлаДляРазбора);
	РазмерФайла = ФайлТЖ.Размер();
	Если РазмерФайла <=3 Тогда
		Возврат 0;
	КонецЕсли;
	
	ПериодФайла = ОбновлениеДанныхРегламентное.ПолучитьПериодПоИмениФайла(ФайлТЖ.ИмяБезРасширения);
	
	ДатаНачалаЧтения = ТекущаяДата();
	
	Текст = Новый ЧтениеТекста(ИмяФайлаДляРазбора, КодировкаТекста.UTF8, Символы.ВК + Символы.ПС, "", Ложь);
	
	ПозиционироватьЧтениеНаСтрокуФайла(Текст, СостояниеЧтения.ПрочитаноСтрок);

	//продолжаем чтение с позиции СостояниеЧтения.ПрочитаноСтрок
	ПрочитаноСтрок = СостояниеЧтения.ПрочитаноСтрок;
	СтрокаТекста = Текст.ПрочитатьСтроку();
	Если СтрокаТекста = Неопределено Тогда
		
		//может быть прочитано строк не поменялось а полностью поменялось 
		РегистрыСведений.СостояниеЧтения.УстановитьСостояние(
			ФайлЗамера, 
			ПериодФайла,
			ПрочитаноСтрок, 
			ДатаНачалаЧтения, 
			РазмерФайла);		
		Возврат 0;
	КонецЕсли;
	ПрочитаноСтрок = ПрочитаноСтрок + 1;
	
	//регэксп объекты
	Анализатор = ПолучитьАнализаторНачалаСтроки();
	АнализаторСвойств = ПолучитьАнализаторСвойств();
	АнализаторДвойныеКавычкиВДвойныхКавычках = ПолучитьАнализаторКавычкиВКавычках();
	ЗаменительДвойныхКавычек = "ЁЁ";	
	
	//часть реквизитов будет одинакова для всего файла
	СтруктураЗаписи = ПолучитьСтруктуруЗаписиСправочник();
	СтруктураЗаписи.Владелец = Замер;
	СтруктураЗаписи.Файл = ФайлЗамера;
	
	Пока СтрокаТекста <> Неопределено Цикл
		
		// Проверяем, является ли следующая строка начальной строкой журнала
		СледующаяСтрока = Текст.ПрочитатьСтроку();
		
		Если СледующаяСтрока <> Неопределено Тогда
			ПрочитаноСтрок = ПрочитаноСтрок + 1;
			
			Совпадения = Анализатор.Execute(СледующаяСтрока);
			Если Совпадения.Count() = 0 Тогда
				// если следующая строка не соответствует шаблону - добавляем ее к текущей строке и пытаемся распознать объединенную часть
				СтрокаТекста = СтрокаТекста + Символы.ПС + СледующаяСтрока; //#11 сохраняем переносы строк
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		
		Совпадения = Анализатор.Execute(СтрокаТекста);
		Если Совпадения.Count() = 1 Тогда
			Совпадение = Совпадения.Item(0);
			Минуты = Число(Совпадение.SubMatches.Item(0));
			Секунды = Число(Совпадение.SubMatches.Item(1));
			ДолиСекунды = Число(Совпадение.SubMatches.Item(2));
			Длительность = Число(Совпадение.SubMatches.Item(3));
			ИмяСобытия = Совпадение.SubMatches.Item(4);
			УровеньСобытия = Совпадение.SubMatches.Item(5);
		Иначе
			ВызватьИсключение "Нет соответствия шаблону! " + СтрокаТекста;
		КонецЕсли;
		
		СтруктураЗаписи.НомерСтрокиФайла = ПрочитаноСтрок;
		СтруктураЗаписи.ТипСобытия = СправочникиСерверПовтИсп.ПолучитьСобытие(ИмяСобытия);
		СтруктураЗаписи.ДатаСобытия = ПериодФайла + Секунды + (Минуты * 60);
		СтруктураЗаписи.ДатаСобытияМкс = Число(ДолиСекунды);
		СтруктураЗаписи.УровеньСобытия = Число(УровеньСобытия);
		СтруктураЗаписи.ДлительностьМкс = Число(Длительность);
		СтруктураЗаписи.КлючевыеСвойства.Очистить();

		ЗаменитьДвойныеКавычкиВДвойныхКавычках = АнализаторДвойныеКавычкиВДвойныхКавычках.Test(СтрокаТекста);
		Если ЗаменитьДвойныеКавычкиВДвойныхКавычках Тогда
			СтрокаТекста = СтрЗаменить(СтрокаТекста, """""", ЗаменительДвойныхКавычек);
		КонецЕсли;
		Совпадения = АнализаторСвойств.Execute(СтрокаТекста);
		Если Совпадения.Count() <> 0 Тогда

			ТекстЗначениеСвойств = "";
			
			Для Сч = 0 По Совпадения.Count() - 1 Цикл
				Совпадение = Совпадения.Item(Сч);
				ИмяСвойства = Совпадение.SubMatches.Item(0);
				Свойство = СправочникиСерверПовтИсп.ПолучитьСвойство(ИмяСвойства);
				
				Если СтруктураЗаписи.КлючевыеСвойства.Получить(Свойство) = Неопределено Тогда 
				 
					ЗначениеСвойства = ЗначениеСвойстваБезЭкранирования(Совпадение.SubMatches.Item(1));
					Если ЗаменитьДвойныеКавычкиВДвойныхКавычках Тогда
						//обратно заменяем на ОДНУ двойную кавычку
						ЗначениеСвойства = СтрЗаменить(ЗначениеСвойства, ЗаменительДвойныхКавычек, """");
					КонецЕсли;

					ВыполнитьНормализациюЗначенияСвойства(Свойство, ЗначениеСвойства);
					СтруктураЗаписи.КлючевыеСвойства.Вставить(Свойство, ЗначениеСвойства);

					ТекстЗначениеСвойств = ТекстЗначениеСвойств + ИмяСвойства +" : "+ ЗначениеСвойства + Символы.ПС;
				КонецЕсли;
			КонецЦикла;
			СтруктураЗаписи.ВсеСвойства = ТекстЗначениеСвойств;
		КонецЕсли;
		
		Справочники.СобытияЗамера.ЗаписатьСобытие(СтруктураЗаписи);
		
		СтрокаТекста = СледующаяСтрока;
	КонецЦикла;
	
	Текст.Закрыть();
	
	// Обновление инфорации о количестве прочитанных строк
	РегистрыСведений.СостояниеЧтения.УстановитьСостояние(
		ФайлЗамера, 
		ПериодФайла,
		ПрочитаноСтрок, 
		ДатаНачалаЧтения,
		РазмерФайла);

	Возврат 0;
КонецФункции

Процедура ВыполнитьНормализациюЗначенияСвойства(Свойство, ЗначениеСвойства)
	НастройкиНормализации = СправочникиСерверПовтИсп.НастройкиНормализацииСвойства(Свойство);
	Если НастройкиНормализации.НормализацияЗначения Тогда
		Выполнить(НастройкиНормализации.ТекстФункцииНормализации);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти
