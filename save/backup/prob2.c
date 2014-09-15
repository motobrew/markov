#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

int Prob2Main(int ratio, int game_num, int win_num, int times);

void Usage(void)
{
	fprintf(stderr, "Usage: prob <ratio> <game_num> <win_num> <times>\n");
}

/*
 * ������<ratio>�����Q�[������<game_num>�̂Ƃ��A
 * �A����<win_num>�̘A�����N���邩�ǂ�����<times>��J��Ԃ��Č��؂���B
 */
int
main(int argc, char** argv)
{
	int		ratio;		//����
	int		game_num;	//�Q�[����
	int		win_num;	//�A����
	int		times;		//���؉�
	int		ret;
	
	if (argc != 5) {
		Usage();
		exit(1);
	}
	
	ratio = atoi(argv[1]);
	game_num = atoi(argv[2]);
	win_num = atoi(argv[3]);
	times = atoi(argv[4]);

	if (ratio < 0 || game_num <= 0 || win_num <= 0 || times <= 0) {
		Usage();
		exit(1);
	}
	
	ret = Prob2Main(ratio, game_num, win_num, times);
	
	return ret;
}

int Prob2Main(int ratio, int game_num, int win_num, int times)
{
	time_t	seed;
	int	i, j, k, ret;
	int	now_win;	//���݂̘A����
	int	sum;		//win_num�񐔂̊ԂɘA��������������
	
	now_win = sum = 0;
	
	time(&seed);
	srand((unsigned int)seed);
	rand();
	for (i = 1, k = 0; times >= i; i++) {
		//printf("Test[%d]: ", i + 1);
		
		for (j = 0; game_num > j; j++) {
			ret = rand();
			ret = (int)(ret * 100.0 / (1.0 + RAND_MAX));
			
			if (ret < ratio) {
				now_win++;
			}
			else {
				now_win = 0;
			}
			
			if (now_win >= win_num) {
				now_win = 0;
				sum++;
				//printf("%d, ", j);
				break;
			}
		}
		if (0 == i % (times / 3)) {
			k++;
			if (k < 3) {
			//	printf("Test[%d]: %d %.2f%%\n",
			//		i, sum, ((float)sum / i * 100));
			}
		}
	}
	/*
	printf("TOTAL: Ratio:%d%%, %dwin, %dgames: %d/%d, %.2f%%\n",
		ratio, win_num, game_num, sum, times,
		((float)sum / times * 100));
	*/
	printf("%d\t%d\t%d\t%d\t%.2f\n",
		ratio, win_num, game_num, times,
		((float)sum / times * 100));
	
	return 0;
}

