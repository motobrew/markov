#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

int w_ratio;		//勝率
int p_ratio;		//損益比率　損:益が1:2なら50
int s_ratio;		//資金に対する許容損失率
int start;		//開始時の資金
int games;		//ゲーム数
int times;		//実証回数

int Prob3Main(void);

void Usage(void)
{
	fprintf(stderr, "Usage: prob <WR> <PR> <SR> <start> <games> <times>\n"
			"       WR: win ratio\n"
			"       PR: payoff ratio\n"
			"       SR: stop ratio\n"
			"       start: start money\n");
}

main(int argc, char** argv)
{
	int		ret;
	
	if (argc != 7) {
		Usage();
		exit(1);
	}
	
	w_ratio = atoi(argv[1]);
	p_ratio = atoi(argv[2]);
	s_ratio = atoi(argv[3]);
	start = atoi(argv[4]);
	games = atoi(argv[5]);
	times = atoi(argv[6]);

	if (w_ratio <= 0 || p_ratio <= 0 || s_ratio <= 0
	|| start <= 0 || games <= 0 || times <= 0) {
		Usage();
		exit(1);
	}
	
	ret = Prob3Main();
	
	return ret;
}

int Prob3Main(void)
{
	unsigned int	money;
	time_t		seed;
	int		i, j, ret;
	float		mr_w, mr_l;
	
	mr_w = (float)(100 + s_ratio) / 100.0;
	mr_l = (float)(100 - s_ratio) / 100.0;
	
	time(&seed);
	srand((unsigned int)seed);
	rand();
	for (i = 1; times >= i; i++) {
		money = start;
		for (j = 0; games > j; j++) {
			ret = rand();
			ret = (int)(ret * 100.0 / (1.0 + RAND_MAX));
			
			if (ret < w_ratio) {
				money = (unsigned int)(money * mr_w);
			}
			else {
				money = (unsigned int)(money * mr_l);
				if (money <= 1000) {
					money = 0;
					break;
				}
			}
		}
		printf("%u, ", money);
	}
	
	printf("\n");
	printf("money:%u, mr_w:%f, mr_l:%f\n", money, mr_w, mr_l);
	return 0;
}

