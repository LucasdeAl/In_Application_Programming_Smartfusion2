#include <stdio.h>
#include <time.h>
#include <windows.h>
#include <stdint.h>

#define VC_EXTRALEAN
#include <string.h>

// Flow control flags

#define FC_DTRDSR 0x01
#define FC_RTSCTS 0x02
#define FC_XONXOFF 0x04

// ascii definitions

#define ASCII_BEL 0x07
#define ASCII_BS 0x08
#define ASCII_LF 0x0A
#define ASCII_CR 0x0D
#define ASCII_XON 0x11
#define ASCII_XOFF 0x13

BOOL bPortReady;
DCB dcb;
COMMTIMEOUTS CommTimeouts;
BOOL bWriteRC;
BOOL bReadRC;
DWORD iBytesWritten;
DWORD iBytesRead;

#define TOTAL_BYTES 2000
#define SPLIT_POINT 1000

// Função para medir o tempo de execução (usando DWORD/GetTickCount)
void measure_time(const char* operation_name, DWORD start_time) {
    DWORD end_time = GetTickCount();
    DWORD elapsed_time = end_time - start_time;
    printf("Tempo para %s: %lu milissegundos\n", operation_name, elapsed_time);
}

// Função para ler uma string da porta serial
int ReadStringFromSerial(HANDLE hCom, char *buffer, int bufferSize) {
    DWORD bytesRead;
    int i = 0;
    char ch;

    // Ler até o final da string ou até o buffer ficar cheio
    while (i < bufferSize - 1) {
        // Ler um caractere da porta serial
        if (ReadFile(hCom, &ch, 1, &bytesRead, NULL)) {
            if (bytesRead > 0) {
                if (ch == '\n' || ch =='\r') {  // Se encontrou o caractere de nova linha, termine a string
                    buffer[i] = '\0';  // Adiciona o caractere de terminação de string
                    return i;  // Retorna o número de caracteres lidos
                }
                buffer[i++] = ch;  // Adiciona o caractere ao buffer
            }
        } else {
            // Erro ao ler da porta serial
            printf("Erro ao ler da porta serial\n");
            return -1;
        }
    }
}

char SerialGetc(HANDLE hCom)
{
    BOOL bReadRC;
    char ret[4];

    static DWORD iBytesRead = -1;

    bReadRC = ReadFile(hCom, ret, 1,&iBytesRead,NULL);

    return ret[0];
}

void SerialPutc(HANDLE hCom, char txchar)
{
    BOOL bWriteRC;
    static DWORD iBytesWritten = -1;

    bWriteRC = WriteFile(hCom, &txchar, 1, &iBytesWritten,NULL);

    return;
}

int main(int argc, char *argv[])
{
    int bytesRead;
    DCB dcb;
    HANDLE hCom;
    HANDLE *ptr;
    FILE *fp;
    long size,result,length,address,factor,temp;
    char filename[100];
    char buffer[8192];
    char ret[8];
    char filesize[8];
    BOOL bReadRC;
    static DWORD iBytesRead = -1;
    char Ack[2]="a";
    long returnbytes;
    BOOL fSuccess;
    char pcCommPort[10]="\\\\.\\COM";
    char prevch;
    char crc = 0;
    char Action_code[3];
    if(argc < 4)
    {
        printf("Usage for M2S_UARTHost_Loader: M2S_UARTHost_Loader.exe filename comportnumber\n");
        printf("Modes : mode = 0 -> write on flash ; mode = 1 -> begin ISP; mode = 2 -> ecc experiment\n");
        return 0;
    }
    strcpy(Action_code,argv[3]);
    printf("mode = %s\n",Action_code);

    if( Action_code[0] != '0' && Action_code[0] != '1' &&  Action_code[0] != '2' &&  Action_code[0] != '3')
    {
        printf("Usage for M2S_UARTHost_Loader: M2S_UARTHost_Loader.exe filename comportnumber\n");
        printf("Modes : mode = 0 -> write on flash ; mode = 1 -> begin ISP; mode = 2 -> ecc experiment\n");
        return 0;
    }

    strcat(pcCommPort,argv[2]);
    hCom = CreateFile( pcCommPort,
        GENERIC_READ | GENERIC_WRITE,
        0, // must be opened with exclusive-access
        NULL, // no security attributes
        OPEN_EXISTING, // must use OPEN_EXISTING
        0, // not overlapped I/O
        NULL // hTemplate must be NULL for comm devices
    );

    if (hCom == INVALID_HANDLE_VALUE)
    {
        printf ("Cann't open UART port, Please close if the port is open by other application %d.\n", GetLastError());
        return (1);
    }

    // Build on the current configuration, and skip setting the size
    // of the input and output buffers with SetupComm.

    fSuccess = GetCommState(hCom, &dcb);

    if (!fSuccess)
    {
        printf ("Cann't open UART port, Please close if the port is open by other application %d.\n", GetLastError());
        return (2);
    }

    // Fill in DCB: 57,600 bps, 8 data bits, no parity, and 1 stop bit.

    dcb.BaudRate = CBR_57600; // set the baud rate
    dcb.ByteSize = 8; // data size, xmit, and rcv
    dcb.Parity = NOPARITY; // no parity bit
    dcb.StopBits = ONESTOPBIT; // one stop bit

    fSuccess = SetCommState(hCom, &dcb);

    if (!fSuccess)
    {
        printf ("Cann't set the UART port Settings %d.\n", GetLastError());
        return (3);
    }

    printf ("Serial port %s successfully reconfigured.\n", pcCommPort);
    printf("\n\nPlease make sure Smartfusion2 Evaluation kit is running \n");
    printf("Reset the Evaluation Kit board before launching this host loader application\n\n");
    printf("Handshaking with Smartfusion2 Evaluation Kit Started \n");

    SerialPutc(hCom,'h');
    ret[0] = SerialGetc(hCom);
    if (ret[0] == 'a')
    {
        SerialPutc(hCom,'n');
    }
    else
    {
        printf("Handshake fail\n");
        printf("Please reset the SmartFusion2 Evaluation Kit Board \n");
        printf("restart this hostloader application with correct perameters \n");
        return 0;
    }

    ret[0] = SerialGetc(hCom);

    if (ret[0] == 'd')
    {
        SerialPutc(hCom,'s');
    }
    else
    {
        printf("Handshake fail\n");
        printf("Please reset the SmartFusion2 Evaluation Kit Board \n");
        printf("restart this hostloader application with correct perameters \n");
        return 0;
    }

    ret[0] = SerialGetc(hCom);

    if (ret[0] == 'h')
    {
        SerialPutc(hCom,'a');
    }
    else
    {
        printf("Handshake fail\n");
        printf("Please reset the SmartFusion2 Evaluation Kit Board \n");
        printf("restart this hostloader application with correct perameters \n");
        return 0;
    }

    ret[0] = SerialGetc(hCom);

    if (ret[0] == 'k')
    {
        SerialPutc(hCom,'e');
    }
    else
    {
        printf("Handshake fail\n");
        printf("Please reset the SmartFusion2 Evaluation Kit Board \n");
        printf("restart this hostloader application with correct perameters \n");
        return 0;
    }
    ret[0] = SerialGetc(hCom);

    if (ret[0] == 'r')
    {
        printf("HAND SHAKE is fine \n");
    }
    else
    {
        printf("Handshake fail\n");
        printf("Please reset the SmartFusion2 Evaluation Kit Board \n");
        printf("restart this hostloader application with correct perameters \n");
        return 0;
    }

    printf("HAND SHAKE is fine \n");

    printf("Sending starting Ack ....\n");
    bWriteRC = WriteFile(hCom, Ack, 1, &iBytesWritten,NULL);
    bReadRC = ReadFile(hCom, ret, 1,&iBytesRead,NULL);

    //printf("Comecar a operacao para iniciar a gravacao do bitstream na flash....\n");
    //send the mode
    
    ret[0] = SerialGetc(hCom);
    if (ret[0] == 'm')
    {
        SerialPutc(hCom,Action_code[0]);
    }

    strcpy(filename, argv[1]);
    fp = fopen(filename,"rb");
    // obtain file size:
    fseek (fp , 0 , SEEK_END);
    size = ftell (fp);
    rewind (fp);

	DWORD start_time = GetTickCount();
    printf("Sending the programming file size = %d\n", size);
    ret[0] = SerialGetc(hCom);
    if (ret[0] == 'z')
    {
        _itoa(size,filesize,10);
        bWriteRC = WriteFile(hCom, filesize, 8, &iBytesWritten,NULL); // aqui se manda o tamanho do arquivo
        printf("mandou o tamanho do arquivo\r\n");
    }

    while(1)
    {
        bReadRC = ReadFile(hCom, ret, 1,&iBytesRead,NULL);

        if(ret[0]=='p')
        {
            printf("\n*********envio de bitstream completado com sucesso*******\n");
            measure_time("gravacao do bitstream", start_time);
            return (0);
        }

        if(ret[0]=='q')
        {
            printf("\n*********falhou\n");
            return (0);
        }

        if(Action_code[0] == '0'){
            if(ret[0]!='b') // b de begining
                continue;

            if(bReadRC==0)
            {
                printf("No transction started from the target.Begin transaction Ack 'b' fails\n");
            }

            printf("============Begin transaction Ack '%s' is received from the target=============\n",ret);
            bWriteRC = WriteFile(hCom, Ack, 1, &iBytesWritten,NULL);
            if(bWriteRC==0)
            {
                printf("Sending Ack message 'a' fails for an acknowledgement of receiving the begin transaction Ack 'b'\n");
            }
            bReadRC =ReadFile(hCom, (char *)&temp, 8,&iBytesRead,NULL);
            address = temp*8;
            if(bReadRC==0)
            {
                printf("Read address transaction fails from the target\n");
            }
            printf("Requested address from the target =%d\n", address);
            bWriteRC = WriteFile(hCom, Ack, 1, &iBytesWritten,NULL);
            if(bWriteRC==0)
            {
                printf("Sending Ack message fails for the received address\n");
            }
            bReadRC =ReadFile(hCom, (char *)&returnbytes, 4,&iBytesRead,NULL);
            if(bReadRC==0)
            {
                printf("Read number of returnbytes transcation fails from the target\n");
            }
            printf("Requested returnbytes from the target =%d\n", returnbytes);
            bWriteRC = WriteFile(hCom, Ack, 1, &iBytesWritten,NULL);
            if(bWriteRC==0)
            {
                printf("Sending Ack message fails for the received returnbytes\n");
            }
            fseek (fp , address , SEEK_SET);
            result = fread (buffer,1,returnbytes,fp);

            printf("bytes read from the file=%d\n", result);
            printf("Remaining bytes =%d\n", size - address-returnbytes);
            if (result != returnbytes)
            {
                printf("Can't open Input file: Please check the path of the file: Reading error\n");
                exit (3);
            }

            bWriteRC = WriteFile(hCom, buffer, returnbytes, &iBytesWritten,NULL);
            printf("Sending the data to the target...............................................\n");
            bReadRC = ReadFile(hCom, ret, 1,&iBytesRead,NULL);
            if(bReadRC==0)
            {
                printf("Read Ack operation fail from target for the requested bytes\n");
            }
            factor = 1;
            crc = 0;
            while((returnbytes-1)/factor)
            {
                crc = crc^buffer[factor];
                factor = factor*2;
            }
            bWriteRC = WriteFile(hCom, &crc, 1, &iBytesWritten,NULL);
            bReadRC = ReadFile(hCom, ret, 1,&iBytesRead,NULL);
            if(bReadRC==0)
            {
                printf("Read Ack operation fail from target for the requested bytes\n");
            }
            else
                printf("End of one transaction:Ack '%s' received from target for the data from the host\n",ret);

            if(address+returnbytes == size)
            {
                printf("\n*********envio de bitstream completado com sucesso*******\n");
				measure_time("gravacao do bitstream", start_time);
                if(ret[0] == 'q')
                {
                    printf("\nDeu ruim\n");
                    return (0);
                }
                else if(ret[0]=='p')
                {
                    printf("\n*********envio de bitstream completado com sucesso*******\n");
                    measure_time("gravacao do bitstream", start_time);
                    return (0);
                }
                fclose(fp);
                return (0);
            }
            if(ret[0]=='p')
            {
                printf("\n*********envio de bitstream completado com sucesso*******\n");
                measure_time("gravacao do bitstream", start_time);
                return (0);
            }
        }
        else if(Action_code[0]=='1')
        {
            printf("Iniciar Operacao de ISP\n\r");
            ret[0] = SerialGetc(hCom);
            if(ret[0]=='c')
            {
                printf("\n\rSelect ISP Operation mode 1/2/3  1.Authenticate 2.Program 3.Verify\n\r");
            }
            ret[0] = getchar();
            SerialPutc(hCom,ret[0]);
            ret[0] = SerialGetc(hCom);
            if(ret[0] == 'm')
            {
                printf("\n\r ISP Authentication started...wait  \n\r");
                DWORD start_time = GetTickCount();

                while(1)
                {
                    ret[0] = SerialGetc(hCom);

                    if(ret[0] == 'p')
                    {
                        printf("\nISP Authentication completed successfully\n");
                        measure_time("autenticacao", start_time);
                        return (0);
                    }
                    else if(ret[0] == 'q')
                    {
                        printf("\nISP Authentication failed");
                        temp = 0;
                        bReadRC =ReadFile(hCom, (char *)&temp, 8,&iBytesRead,NULL);
                        printf(" with error code = %d\n",temp);
                        return (0);
                    }
                    if(ret[0] == '.')
                    {
                        printf(".");
                    }
                }
            }
            else if(ret[0] == 'g')
            {
                printf("\n\r ISP Programming started...wait  \n\r");
                DWORD start_time = GetTickCount();
                while(1)
                {
                    ret[0] = SerialGetc(hCom);

                    if(ret[0] == 'p')
                    {
                        printf("\nISP Programming completed successfully\n");
                        measure_time("programacao", start_time);
                        return (0);
                    }
                    else if(ret[0] == 'q')
                    {
                        printf("\nISP Programming failed");
                        temp = 0;
                        bReadRC =ReadFile(hCom, (char *)&temp, 8,&iBytesRead,NULL);
                        printf(" with error code = %d\n",temp);
                        return (0);
                    }
                    if(ret[0] == '.')
                    {
                        printf(".");
                    }
                }
            }else if(ret[0] == 'k')
            {
                printf("\n\r ISP Verify started...wait  \n\r");
                DWORD start_time = GetTickCount();
                while(1)
                {
                    ret[0] = SerialGetc(hCom);

                    if(ret[0] == 'p')
                    {
                        printf("\nISP Verify completed successfully\n");
                        measure_time("verificacao", start_time);
                        return (0);
                    }
                    else if(ret[0] == 'q')
                    {
                        printf("\nISP Verify failed");
                        temp = 0;
                        bReadRC =ReadFile(hCom, (char *)&temp, 8,&iBytesRead,NULL);
                        printf(" with error code = %d\n",temp);
                        return (0);
                    }
                    if(ret[0] == '.')
                    {
                        printf(".");
                    }
                }
            }
        }
        else if(Action_code[0] == '2')
        {
                FILE *file1, *file2;
    char buffer[TOTAL_BYTES];
    int count = 0;

    // Recebendo 2000 bytes da serial
    while (count < TOTAL_BYTES) {
        SerialPutc(hCom, 'h');
        buffer[count] = SerialGetc(hCom);
        count++;
    }

    // Grava os primeiros 1000 bytes em parte1.bin
    file1 = fopen("parte1.bin", "wb");
    if (file1 == NULL) {
        perror("Erro ao abrir parte1.bin");
        return 1;
    }
    fwrite(buffer, 1, SPLIT_POINT, file1);
    fclose(file1);

    // Grava os segundos 1000 bytes em parte2.bin
    file2 = fopen("parte2.bin", "wb");
    if (file2 == NULL) {
        perror("Erro ao abrir parte2.bin");
        return 1;
    }
    fwrite(buffer + SPLIT_POINT, 1, TOTAL_BYTES - SPLIT_POINT, file2);
    fclose(file2);

    printf("Arquivos binários separados com sucesso.\n");

    }
}
}