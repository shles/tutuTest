Тестовое задание в tutu.ru
====================
Результат тествовго задания на вакансию младшего iOS разработчика

Хотелось бы отметить несколько моментов:

В задании не был сделан упор на UI/UX. Так например выбор станции из подробной информации является странным решением в целом. И мое решение с размещением кнопки в nav баре тоже не самое эффективное, но удовлетворяет требованиям задания. Так же отсутствует индикатор загрузки во время отображения результатов поиска

При первом запуске приложение переписывает данные в базу данных из json файла. Это занимает некоторое время.

Не совсем был понятен момент с группировкой станций, к сожалению, уточнения я не смог получить вовремя, по этому я решил этот вопрос на свое усмотрение, что повлияло на алгоритм работы с данными.

Данные загружаются по следующему алгоритму:
- сначала получает список уникальных городов по текущему направлению
- для каждого города получает список станций, удовлетворяющих требованиям (направлению и поисковой строке, при наличии) 

Тестирование в основном производил по средством дебага. Юнит тесты не использовал.