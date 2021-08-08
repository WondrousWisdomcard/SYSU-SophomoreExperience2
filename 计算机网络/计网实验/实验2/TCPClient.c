#include <stdio.h>
#include <string.h>
#include <winsock2.h>
#define BUFLEN 2000				   // 缓冲区大小
#define WSVERS MAKEWORD(2, 2)	  // 指明版本2.2
#pragma comment(lib, "ws2_32.lib") // 加载winsock 2.2 Llibrary
void main(int argc, char *argv[])
{
	char host[] = "127.0.0.1";		 // server IP to connect
	char service[] = "50500";		 // server port to connect
	struct sockaddr_in toAddr, from; // an Internet endpoint address
	int fromsize = sizeof(from);
	char buf[BUFLEN + 1]; // buffer for one line of text
	SOCKET sock;		  // socket descriptor
	int cc;				  // recv character count
	WSADATA wsadata;
	WSAStartup(WSVERS, &wsadata); // 启动某版本Socket的DLL
	sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
	memset(&toAddr, 0, sizeof(toAddr));
	toAddr.sin_family = AF_INET;
	toAddr.sin_port = htons((u_short)atoi(service)); //atoi：把ascii转化为int. htons：主机序(host)转化为网络序(network), s--short
	toAddr.sin_addr.s_addr = inet_addr(host);		 //如果host为域名，需要先用函数gethostbyname把域名转化为IP地址
	printf("Send the Message:\n");
	gets(buf);
	cc = sendto(sock, buf, strlen(buf), 0, (SOCKADDR *)&toAddr, sizeof(toAddr));
	if (cc == SOCKET_ERROR)
		printf("Error:\n%d\n", WSAGetLastError());
	else
	{
		cc = recvfrom(sock, buf, BUFLEN, 0, (SOCKADDR *)&from, &fromsize);
		if (cc == SOCKET_ERROR)
			printf("Receive Error:\n%d\n", WSAGetLastError());
		else
			printf("%s", buf);
	}
	closesocket(sock);
	WSACleanup(); // 卸载某版本的DLL
	system("pause");
}