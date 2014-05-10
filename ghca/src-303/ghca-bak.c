#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include "ghca.h"

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h" 
LUALIB_API int luaopen_bit(lua_State *L);
LUALIB_API void lua_enc_bit(lua_State *L);


/* MD5lib.h - md5 library
 */

/* Copyright (C) 1990-2, RSA Data Security, Inc. Created 1990. All
rights reserved.

RSA Data Security, Inc. makes no representations concerning either
the merchantability of this software or the suitability of this
software for any particular purpose. It is provided "as is"
without express or implied warranty of any kind.

These notices must be retained in any copies of any part of this
documentation and/or software.
 */

/* The following makes MD default to MD5 if it has not already been
  defined with C compiler flags.
 */

#include "global.h"
#include "md5.h"
#include "getPIN.h"
#define MD 5

/* Digests a string and prints the result.
 */
char* MDString (char *string)
 
{
  MD5_CTX context;
  unsigned char digest[16];
  char output1[32];
 static  char output[33]={""};
  unsigned int len = strlen (string);
  int i;
  MD5Init (&context);
  MD5Update (&context, (unsigned char*)string, len);
  MD5Final (digest, &context);

  for (i = 0; i < 16; i++)
 {sprintf(&(output1[2*i]),"%02x",(unsigned char)digest[i]);
  sprintf(&(output1[2*i+1]),"%02x",(unsigned char)(digest[i]<<4));
  }
  for(i=0;i<32;i++)
  output[i]=output1[i];
//  printf("%s",output);
  return output;
}

  
/* Digests a file and prints the result.
 */
char* MDFile (char *filename)
 
{ static char output[33]={""};
  FILE *file;
  MD5_CTX context;
  int len;
  unsigned char buffer[1024], digest[16];
  int i;
  char output1[32];
  if ((file = fopen (filename, "rb")) == NULL)
   { printf ("%s can't be openedn", filename);
    return 0;
   }
  else {
       MD5Init (&context);
     while (len = fread (buffer, 1, 1024, file))
       MD5Update (&context, buffer, len);
    MD5Final (digest, &context);
    fclose (file);
    for (i = 0; i < 16; i++)
     {sprintf(&(output1[2*i]),"%02x",(unsigned char)digest[i]);
        sprintf(&(output1[2*i+1]),"%02x",(unsigned char)(digest[i]<<4));
          }
        for(i=0;i<32;i++)
       output[i]=output1[i];
        return output;
       }
}

char* hmac_md5(char* text,char*  key)
{
        char   digest[16];
        char   output1[32];
         static char output[33]={""};
        MD5_CTX context;
        unsigned char k_ipad[65];    /* inner padding -
                                      * key XORd with ipad
                                      */
        unsigned char k_opad[65];    /* outer padding -
                                      * key XORd with opad
                                      */
        unsigned char tk[16];
        int i;
        int text_len = strlen (text);
        int key_len=strlen(key);
        /* if key is longer than 64 bytes reset it to key=MD5(key) */
        if (key_len > 64) {

                MD5_CTX      tctx;

                MD5Init(&tctx);
                MD5Update(&tctx,(unsigned char*) key, key_len);
                MD5Final(tk, &tctx);

                key = (char*)tk;
                key_len = 16;
        }

        /*
         * the HMAC_MD5 transform looks like:
         *
         * MD5(K XOR opad, MD5(K XOR ipad, text))
         *
         * where K is an n byte key
         * ipad is the byte 0x36 repeated 64 times
         * opad is the byte 0x5c repeated 64 times
         * and text is the data being protected
         */

        /* start out by storing key in pads */
        
        /*bzero( k_ipad, sizeof k_ipad);
          bzero( k_opad, sizeof k_opad);
        */

        for(i=0;i<65;i++)
        k_ipad[i]=(unsigned char)0;
        for(i=0;i<65;i++)
        k_opad[i]=(unsigned char)0;

        /*bcopy( key, k_ipad, key_len);
          bcopy( key, k_opad, key_len);
         */
         for(i=0;i<key_len;i++)
        {k_ipad[i]=(unsigned char)key[i];
         k_opad[i]=(unsigned char)key[i];
         }

        /* XOR key with ipad and opad values */
        for (i=0; i<64; i++) {
                k_ipad[i] ^= 0x36;
                k_opad[i] ^= 0x5c;
        }
        /*
         * perform inner MD5
         */
        MD5Init(&context);                   /* init context for 1st

                                              * pass */
        MD5Update(&context, k_ipad, 64);      /* start with inner pad */
        MD5Update(&context, (unsigned char*)text, text_len); /* then text of datagram 

*/
        MD5Final((unsigned char*)digest, &context);          /* finish up 1st pass */
        /*
         * perform outer MD5
         */
        MD5Init(&context);                   /* init context for 2nd
                                              * pass */
        MD5Update(&context, k_opad, 64);     /* start with outer pad */
        MD5Update(&context,(unsigned char*) digest, 16);     /* then results of 1st
                                              * hash */
        MD5Final((unsigned char*)digest, &context);          /* finish up 2nd pass */
        for (i = 0; i < 16; i++)
        {sprintf(&(output1[2*i]),"%02x",(unsigned char)digest[i]);
         sprintf(&(output1[2*i+1]),"%02x",(unsigned char)(digest[i]<<4));
          }
        for(i=0;i<32;i++)
        output[i]=output1[i]; 
        return output;     
}

int CutStr(char x[],int len)
{
	x[len]=0;
	return 1;
}

/*为嵌入式设备设置的随机数产生式*/
int hexnum2(char dst[])
{
	FILE *fp;
	char x[300],x1[129],md[33];
	unsigned int hex;
	fp=fopen("/dev/urandom","r");
	if(fp==NULL)
		return 0;
	fread(x,128,1,fp);
	x[128]=0;
	fclose(fp);

	strcpy(md,MDString(x));
	CutStr(md,8);
	sscanf(md,"%x",&hex);
	usleep(hex%100000);

	fp=fopen("/dev/urandom","r");
	fread(x1,128,1,fp);
	x1[128]=0;
	fclose(fp);

	strcat(x,x1);
	strcpy(x,MDString(x));
	CutStr(x,8);
	sscanf(x,"%x",&hex);
	while(hex<0x40000000)
	{
		hex+=0x1000000;
	}
	while(hex>0x50000000)
	{
		hex-=0x1000000;
	}
	
	sprintf(dst,"%x",hex);
	return 1;
}

void hexnum(char dst[])
{
	if(!hexnum2(dst))
		sprintf(dst,"%x",time(0));
} 

int UCase(char in[])
{
	int i;
	for(i=0;in[i];i++)
		if(in[i]>='a' && in[i]<='z')
			in[i]-=32;
	return 1;
}

int covacc(char usr[],char pwd[],char dst[])
{
	UCase(usr);
	char str[100],hex[10];
	hexnum(hex);
	strcat(str,"jepyid");
	strcat(str,usr);
	strcat(str,hex);
	strcat(str,pwd);
	strcpy(str,MDString(str));
	CutStr(str,20);
	strcat(dst,"~ghca");
	strcat(dst,hex);
	strcat(dst,"2007");
	strcat(dst,str);
	strcat(dst,usr);
	return 0;
}

char * Encrypt(char *usr,char * password,int num,char * encfile)
{
	char username[128];
	strcpy(username,usr);
	UCase(username);
	int iError = 0,n,i,j;
	unsigned short nRand = 0,nSum = 0,nKey = 0;
	char cTmp[256];
	char Encrypt_str[256] = "";
	const char *Encrypt_str1;
	//播种
	srand((unsigned)time(0));
	//随机数
	nRand = rand();
	for (n = 0;n < num ;++n)
	{
		nRand++;
		nSum = 0;
		for (i = 0;i <strlen(password);i++)
		{
			nSum += password[i];
		}
		nKey = nSum ^ nRand;

		//初始化lua
		lua_State *L = lua_open();
		//载入lua标准库
		luaL_openlibs(L);
		//注册函数
		lua_enc_bit(L);
		//载入执行脚本
		iError = luaL_loadfile(L,encfile);
		if (iError)
		{
			printf("Load script FAILED! %s",lua_tostring(L, -1));
			lua_close(L);
			return "";
		}
		iError = lua_pcall(L, 0, 0, 0);
		if (iError)
		{
			printf("Run FAILED! %s",lua_tostring(L, -1));
			lua_close(L);
			return "";
		}
		//通过函数名取出函数地址压入栈
		lua_getglobal( L,"xxx");
		lua_pushstring(L,username);
		lua_pushstring(L,password);
		lua_pushnumber(L,nRand);
		iError = lua_pcall(L, 3, 1, 0);
		if (iError)
		{
			printf("Run FAILED! %s",lua_tostring(L, -1));
			lua_close(L);
			return "";
		}
		if (lua_isstring(L, -1) )
		{
			Encrypt_str1 = lua_tostring(L, -1);





		}
		else
		{
			printf("Return Wrong\n");
		}
		strcpy(Encrypt_str,Encrypt_str1);
		lua_close(L);	
		sprintf(cTmp,"%04x",nKey);
//		printf("%s\n",cTmp);
		for (j = 0;j < 4;j++)
		{
			Encrypt_str[j+28] = cTmp[j];
		}
		printf("~ghca%s\n",Encrypt_str);

	}	
	return Encrypt_str;
}
/*int main(int argc, char* argv[])
{
	char usr[100],pwd[100];
	int num;
	if(argc==1)
	{
		printf("Username password num\n");
		scanf("%s%s%d",usr,pwd,&num);
		Encrypt(usr,pwd,num);
		return 0;
	}
	Encrypt(argv[1],argv[2],1);
//	scanf("%s%s",argv[1],argv[2]);
//	printf("~ghca%s",Encrypt(usr,pwd));
	return 0;
}*/

char *get_208_id(char usr1[])
{
	char usr[128];
	strcpy(usr,usr1);
	UCase(usr);
	int i,k=0,usr_len=strlen(usr);
	char md_s[40];
	static char final_208_id[10];
	for(i=0;i<strlen(usr);++i)
	{
		k=k+usr[i]+(usr_len % 13);
		usr[i]+=125;
	}
//	printf("sum:%d\nmod:%d\n",k,k%5);
	k %= 5;
	if(k==0)k=5;
	strcpy(md_s,MDString(usr));
//	printf("%s\n",md_s);
	for(i=0;i<6;++i)
	{
		final_208_id[i]=md_s[i*k];
	}
	final_208_id[i]=0;
//	printf("%s\n",final_208_id);
	return final_208_id;
	
}
void printhelp(char *cmd)
{
	puts("Welcome!!!");
	puts("Use in this way:");
	printf("%s",cmd);
	puts(" account password mode [id]");
	puts("1.shanxun\n2007.ghca_2.07\n2009.ghca_2.09");
	puts("for ghca 2009 you should also give the identify code.");
}
int main(int argc,char * argv[])
{
	
	char final[100]="";
	char acc[52],pwd[52];
	switch(argc)
	{
		case 1:
		{
			printhelp(argv[0]);
			return -1;
		}break;
		case 2:
		{
			if(strcmp(argv[1],"--help")==0 || strcmp(argv[1],"-h")==0)
			{
				printhelp(argv[0]);
				return -1;
			}
			printf("%s\n",argv[1]);
		}break;
		case 3:
		{
			printf("%s\n",argv[1]);
		}break;
		case 4:
		{
			if(strcmp(argv[3],"0")==0)
				printf("%s\n",argv[1]);
			else if(strcmp(argv[3],"2007")==0)
			{
				strcpy(acc,argv[1]);
				strcpy(pwd,argv[2]);
				covacc(acc,pwd,final);
				printf("%s\n",final);
			}
			else if(strcmp(argv[3],"1")==0)
			{
				byte *userName = (byte *)(argv[1]);
				byte PIN[30] = {0};
				getPIN(userName,PIN);
				printf("%s\n",PIN+2);
			}
			else printf("%s\n",argv[1]);
		}break;
		case 5:
		{
			if(strcmp(argv[3],"2009")==0 )
			{
				Encrypt(argv[1],argv[2],1,"./encrypt.lua");
			}
			else if(strcmp(argv[3],"2008")==0 )
			{
				Encrypt(argv[1],argv[2],1,"./encrypt3.lua");
			}
			else if(strcmp(argv[3],"2007")==0)
			{
				strcpy(acc,argv[1]);
				strcpy(pwd,argv[2]);
				covacc(acc,pwd,final);
				printf("%s\n",final);
			}
			else if(strcmp(argv[3],"1")==0)
			{
				byte *userName = (byte *)(argv[1]);
				byte PIN[30] = {0};
				getPIN(userName,PIN);
				printf("%s\n",PIN+2);
			}
			else printf("%s\n",argv[1]);
		}break;
		default:printf("%s\n",argv[1]);break;
	}
//	byte *userName1 = "057400000000@ND.XY";
//	byte PIN[30] = {0};
//	getPIN(userName1,PIN);
//	printf("%s",PIN);
	return 0;
}
