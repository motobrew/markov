#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

#include "prob.h"

void Usage(void)
{
	fprintf(stderr, "Usage: prob <ratio> <count>\n");
}

int
main(int argc, char** argv)
{
	int		ratio;
	int		count;
	int		ret;
	
	if (argc != 3) {
		Usage();
		exit(1);
	}
	
	ratio = atoi(argv[1]);	//勝率
	count = atoi(argv[2]);	//回数

	if (ratio < 0 || count <= 0) {
		Usage();
		exit(1);
	}
	
	ret = ProbMain(ratio, count);
	
	return ret;
}

int ProbMain(int ratio, int count)
{
	time_t	seed;
	int	i, ret, now_win;
	int	win_num, lose_num;
	int	count_over, num_over;
	int	win_count[WIN_COUNT_MAX];	//連勝回数
	int	sum_count[WIN_COUNT_MAX];	//連勝回数（上位含む）
	int	sum_num[WIN_COUNT_MAX];		//勝利回数（上位含む）
	
	ret = now_win = win_num = lose_num = 0;
	count_over = num_over = 0;
	memset(win_count, 0, sizeof(win_count));
	memset(sum_count, 0, sizeof(sum_count));
	memset(sum_num, 0, sizeof(sum_num));

	time(&seed);
	srand((unsigned int)seed);
	rand();
	for (i = 0; count > i; i++) {
		ret = rand();
		ret = (int)(ret * 100.0 / (1.0 + RAND_MAX));
		
		//win
		if (ret < ratio) {
			win_num++;
			now_win++;
		}
		
		//lose
		if ((count - 1 == i) || (ret >= ratio)) {
			if (ret >= ratio) {
				lose_num++;
			}
			if (WIN_COUNT_MAX < now_win) {
				printf("now_win: %d\n", now_win);
				count_over++;
				num_over += now_win;
			}
			else if (now_win > 0) {
				win_count[now_win - 1]++;
			}
			now_win = 0;
		}
	}
	
	//sum
	i = WIN_COUNT_MAX - 1;
	sum_count[i] = win_count[i] + count_over;
	sum_num[i] = win_count[i] * WIN_COUNT_MAX + num_over;
	i--;
	while (0 <= i) {
		sum_count[i] = win_count[i] + sum_count[i + 1];
		sum_num[i] = win_count[i] * (i + 1) + sum_num[i + 1];
		i--;
	}
	
	//display
	printf("  TOTAL: win:%d, lose:%d, %.2f%%\n",
		win_num, lose_num,
		(float)win_num / count * 100);
	
	printf("==================================================================\n");
	for (i = 0; WIN_COUNT_MAX > i; i++) {
		printf("%3d WIN\t: %10d, %10d, %10d, %10.2f%%\n",
			i + 1,
			win_count[i],
			sum_count[i],
			sum_num[i],
			(float)sum_num[i] / count * 100);
	}
	return 0;
}

