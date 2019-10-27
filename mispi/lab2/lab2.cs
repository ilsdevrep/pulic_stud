using System;

class MainClass
{
	static double Next(UInt64 a, ref UInt64 zatravka, UInt64 M)
	{
		double F = primarNext(a, ref zatravka, M);
		double result = -1;
		if (F <= 2.0 / 7.0)
			result = 1 + Math.Sqrt(14.0 * F);
		if ((F > 2.0 / 7.0) && (F <= 6.0 / 7.0))
			result = (7.0 * F + 4.0) / 2.0;
		if (F > 6.0 / 7.0)
			result = 7.0 * F - 1;
		return result;
	}

	
	//фунция получения следующего случайного числа
	public static double primarNext(UInt64 a, ref UInt64 zatravka, UInt64 M)
	{
		zatravka = (a * zatravka) % M;
		return zatravka / (double)M;
		
	}
	static	UInt64 zatravka;
	//число порядка корня из M (простое) в остатке 3
	
	// Здесь есть цикл по элментам. чтобы его убрать надо задать для a и M большие значения (расскомметировать большие, закомментировать меньшие)
	
	
	//static	UInt64 a = 2642203;
	static UInt64 a = 513;
	//простое число порядка a*a
	//static	UInt64 M = 6981463658303;
	static UInt64 M = 263171;
	
	//a*M<2^64
	//Так как M и a простые числа, число b можно не задавать, так. как нет опасности возникновения непрерывной последовательности нулей
	//b=1;
	
	
	public  static void Main(string[] args)
	{	
//Создать список для хранения чисел для проверки на цикличность
		System.Collections.Generic.List<UInt64> list_of_nums = new System.Collections.Generic.List <UInt64>();
//Флаг, определяющий, что не встертилось повторений
		bool loop_flg = false;
		
//путь для файлов
		string path = @"C:\Users\VAS-ER\Desktop\";

//задать число отрезков. 2^5=32
		const uint amount = (uint)1 << 5;
//Создать объект r класса datchik с начальной затравкой
		zatravka = 123456;
		
		Console.WriteLine("Значение затравки= {0}, значение a= {1}, значение M={2}", zatravka, a, 
			M);
//задать массив для отрезков
		int[] data = new int[amount];
//обнулить массив
		for (uint i = 0; i < amount; i++)
			data[i] = 0;
//задать количество случайных чисел 2^15>20`000

//Цикл обнаруживается начиная с 2^18
		UInt64 c = (UInt64)1 << 18;
//Открыть файл на запись (для записи чисел от 0 до M)

		for (UInt64 i = 0; i < c; i++) {
			//получить в temp случайное число [0;1)
			double temp = Next(a, ref zatravka, M);
			//записать в файл число от 0 до M 
			if (i < 20) {
				list_of_nums.Add(zatravka);
			} else {
//Проверить, входит ли затравка в список. Если да - вывести сообщение об этом и установить флаг цикла генератора
				if (list_of_nums.Contains(zatravka)) {
					Console.WriteLine("Элемент {0} под номером {2} встречен повторно на позиции {1}", zatravka, i, list_of_nums.IndexOf(zatravka));
					loop_flg = true;
				}
			}
//Увеличить количество чисел в диапазоне. Выбор диапазона с округлением вниз
			data[(uint)(temp * amount / 8.0)]++;
		}
//открыть файл на запись для диапазонов и количестве чисел, в них попавших
		var fout = new System.IO.StreamWriter(path + "out.txt");
//вывод диапазона и -/-
		for (uint i = 0; i < amount; i++)
			fout.WriteLine((double)i * 8.0 / amount + "	" + data[i]);
//закрытие файлов
		fout.Close();

//Вывести собщение, что цикла нет, если флаг циличности не былустановлен		
		if (!loop_flg) {
			Console.WriteLine("Цикл первых элементовне обаружен");
		}

		Console.WriteLine("Done");
//Ожидать нажатия клавиши перед завершением программы
		Console.ReadKey(true);
	}
}
