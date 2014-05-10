#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "md5.h"

char *MDString(char *in)
{
	static char md5_32[33];
	unsigned char md[16]={'0'},tmp[3]={'0'};
	int i;
	MD5_CTX ctx;
	memset(md5_32,0,33);
	//if(MD5Init(&ctx) ==0 )    //初始化一个MD5_CTX这样的结构体
    //{
    //    printf("Error!MD5_Init() Error!\n");
    //    exit(1);
    //}
   // int MD5_Update(MD5_CTX *c, const void *data, unsigned long len);
    MD5Init(&ctx);
    MD5Update(&ctx, (unsigned char*)in, strlen(in));   //更新这块区域，防止引用非法数据
    //int MD5_Final(unsigned char *md, MD5_CTX *c);
    MD5Final(md, &ctx);
    for(i=0; i< 16; i++)
    {
        sprintf(tmp, "%02x", md[i]);
        strcat(md5_32, tmp);
    }
	return md5_32;
}

int check_v1(char sn1[],char usr1[])
{
	if(strlen(sn1)>6 || strlen(usr1)>120)
		return 0;
	char *p;
	char sn[10],usr[128];
	strcpy(sn,sn1);
	strcpy(usr,usr1);
	int usr_len=strlen(usr);
	int k=0;
    unsigned int i;
	for(i=0;i<strlen(usr);++i)
	{
		k=k+usr[i]+(usr_len % 13);
		usr[i]+=125;
	}
	k %= 5;
	if(k==0)k=5;
	p=MDString(usr);
	for(i=0;i<6 && sn[i]==p[i*k];++i);
	while(i==6)
		return 1;
	return 0;
}

char *get_v1(char *user)
{
    char usr[128];
    strcpy(usr,user);
    static char sn_usr[10];
    char *SMD5;
    memset(sn_usr,0,10);
    int usr_len=strlen(usr);
    int i=0,k=0;
    for(i=0;i<usr_len;++i)
    {
        k=k+usr[i]+(usr_len % 13);
        usr[i] = usr[i]+125;
    }
    k %= 5;
    if(k==0)k=5;
    SMD5=MDString(usr);;

    for(i=0;i<6;++i)
    {
        sn_usr[i]=SMD5[i*k % 32];
    }
    return sn_usr;
}
int (*checker)(char sn1[],char usr1[]) = check_v1;
int main(int argc, char *argv[])
{
//	checker = check_v1;
    char user[128];
    strcpy(user,argv[1]);
    int i;
    for(i=0;user[i];i++)
    {
        if(user[i]>='a' && user[i] <= 'z')
            user[i]+='A'-'a';
    }
	printf("user:%s pin:%s\n",user,get_v1(user));
    //printf("The String is [ %s ]\nThe String MD5 is [ %s ]\n",argv[1],MDString(argv[1]));

    return 0;
}

