;/-------------------------------------------------------------------------------------------------------------\
;
;     Winsock 2 Functions Interface Unit:  
;                   - Contains functions relevant to Winsock 2 Network Communications.
;                   - Component of AFK-Operator IRC Framework Project. (Developed/Tested on UnrealIRCd-4.0.1)
;
;\-------------------------------------------------------------------------------------------------------------/

Global Socket_Buffer_Size.i = 8192 ;16384 ; The amount of bytes that can be read at one time on the network

Macro MAKEWORD(a, b) ; Macro to generate Winsock Version Information
  (a & $FF)|((b & $FF)<<8)
EndMacro

Procedure.i InitializeSockets() ; Initialize Winsock for networking use in the program.
  wsaData.WSADATA
  wVersionRequested.w = MAKEWORD(2,2)
  iResult = WSAStartup_(wVersionRequested, @wsaData)
  If iResult <> #NO_ERROR
    Debug "Error at WSAStartup()"
    ProcedureReturn #False
  Else
    Debug "WSAStartup() OK."
    ProcedureReturn #True
  EndIf
EndProcedure

Procedure.i ShutdownSockets(ShowError.i=0) ; If there is an error, or we simply want to quit, this will close+free the sockets
  If ShowError <> 0
    Debug "Error: " + Str(WSAGetLastError_())
  EndIf
  WSACleanup_()
  Debug "WSACleanup() OK."
EndProcedure

Procedure.s HostnameToIP(HostName.s) ; Winsock, returns an IP Address based on a hostname, [needs error handling for zero-length input]
  If Len(HostName) > 0 
    ResultIP.s=""    
    *host.HOSTENT = gethostbyname_(HostName)
    If *host <> #Null
      IPAddr.l = PeekL(*host\h_addr_list)
      ResultIP = StrU(PeekB(IPAddr),#PB_Byte)+"."+StrU(PeekB(IPAddr+1),#PB_Byte)+"."+StrU(PeekB(IPAddr+2),#PB_Byte)+"."+StrU(PeekB(IPAddr+3),#PB_Byte)
    EndIf 
    ProcedureReturn ResultIP 
  EndIf 
EndProcedure 

Procedure.s Get_Local_FQDN() ; Allows the bot to determine its own Fully-Qualified Domain Name [FIX Non-Domain Error Check] !!!
  Protected BufferSize.I
  If GetNetworkParams_(0, @BufferSize) = #ERROR_BUFFER_OVERFLOW
    Protected *Buffer = AllocateMemory(BufferSize)
    If *Buffer
      Protected Result = GetNetworkParams_(*Buffer, @BufferSize)
      If Result = #ERROR_SUCCESS
        Hostname$ = PeekS(*Buffer)
        If Trim(Hostname$) = "" : Hostname$ = "localhost" : EndIf
        DomainName$ = PeekS(*Buffer + 132)
        If Trim(DomainName$) = "" : DomainName$ = "local" : EndIf
        FQDN$ = Hostname$ + "." + DomainName$ ;PeekS(*Buffer+132)
      EndIf
      FreeMemory(*Buffer)
    EndIf
  EndIf
  ProcedureReturn FQDN$
EndProcedure

Procedure.i Create_Socket_Connect(ServerHostName$, Port.i) ; Creates a new socket, and if all goes well, connects to your server, returning a Socket Handle
  ResultSocket = SOCKET_(#AF_INET, #SOCK_STREAM, #IPPROTO_TCP)
  If ResultSocket = #INVALID_SOCKET
    Debug "Error at Socket(): " + Str(WSAGetLastError_())
    ProcedureReturn #INVALID_SOCKET
  EndIf
  *ptr = client.sockaddr_in
  client\sin_family = #AF_INET
  client\sin_addr = inet_addr_(HostnameToIP(ServerHostname$))
  client\sin_port = htons_(Port)
  If connect_(ResultSocket, *ptr, SizeOf(sockaddr_in)) = #SOCKET_ERROR
    ProcedureReturn #INVALID_SOCKET
  Else
    Connected = 1
    Debug "Socket Created: " + Str(ResultSocket)
    ProcedureReturn ResultSocket
  EndIf
EndProcedure  
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 76
; Folding = --
; EnableThread
; EnableXP