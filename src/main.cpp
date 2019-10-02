#include <iostream>
#include <thread>
#include <fstream>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h> 


void run(){
    system("bin/server");
}

inline bool fileExist (const std::string& name) {
    return ( access( name.c_str(), F_OK ) != -1 );
}

void sendMessageToServer(char message[], std::string hostName, std::string port){
    int sockfd, portno, n;
    struct sockaddr_in serv_addr;
    struct hostent *server;

    // char buffer[256]  = message;
    portno = atoi(port.c_str());
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) 
        std::cerr << ("ERROR opening socket") << std::endl;
    server = gethostbyname(hostName.c_str());
    if (server == NULL) {
        fprintf(stderr,"ERROR, no such host\n");
        exit(0);
    }
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr, 
         (char *)&serv_addr.sin_addr.s_addr,
         server->h_length);
    serv_addr.sin_port = htons(portno);
    if (connect(sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0) 
        std::cerr << ("ERROR connecting") << std::endl;
    // bzero(buffer,256);
    n = write(sockfd, message, strlen(message));
    // n = write(sockfd,"end", 3);
    if (n < 0) 
        std::cerr << ("ERROR writing to socket") << std::endl;
    // bzero(buffer,256);
    // n = read(sockfd, buffer,255);
    if (n < 0) 
        std::cerr << ("ERROR reading from socket") << std::endl;
    // printf("%s\n",buffer);
    close(sockfd);

}

int main(){
    std::string portFilePath = ".config/port.config";
    std::string port;
    std::thread runServer(run);
    
    std::cout << "waiting server ..." << std::endl;
    std::cout << fileExist(portFilePath) << std::endl;
    while(!fileExist(portFilePath));
    std::cout << "starting application ..." << std::endl;
    sleep(3);

    std::ifstream portFile(portFilePath);
    portFile >> port;
    portFile.close();

    std::cout << "port: " << port << std::endl;
    char message [] = "start";
    sendMessageToServer(message, "127.0.0.1", port);
    runServer.join();
    remove(portFilePath.c_str());
    return 0;
}