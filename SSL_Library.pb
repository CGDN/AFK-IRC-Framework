;*******************************************************
;*                                                     *
;*                SSL Library V1.0                     *
;*                ================                     *
;*     SSL/TLS Network lib by Uncle B for PureBasic    *
;*         for use with Cryptlib library V3.3.3        *
;*                                                     *
;*              Rotterdam, NL, May 2010                *
;*                                                     *
;*     Needs: - Cryptlib_Header.pb (Include file)      *
;*            - cl32.dll (cryptlib library)            *
;*                                                     *
;*    Conditions for usage of cryptlib library see:    *
;*    http://www.cs.auckland.ac.nz/~pgut001/cryptlib/  *
;*                                                     *
;*    Cryptlib_Header.pb and cl32.dll available at:    *
;*    http://www.coastrd.com/download                  *
;*                                                     *
;*                                                     *
;*          COMPILE IN THREAD SAFE MODE!!!             *
;*                                                     *
;*******************************************************

XIncludeFile "Cryptlib_Header.pb"

Enumeration 
  #SSLEvent_Connect = 1   
  #SSLEvent_Data  
  #SSLEvent_File
  #SSLEvent_Disconnect
  #SSLEvent_ServerShutDown
  #SSLEvent_SessionStopped
EndEnumeration

Enumeration
  #SSL_Error_None = 0
  #SSL_Error_Push
  #SSL_Error_Pop
  #SSL_Error_AllocateMemory
EndEnumeration

Structure SSLEvent
 Event.l
*pBuffer
 Length.l
 Pos.l
 ID.l
EndStructure

Structure SSLSession
  hSession.l
  *pRequest.SSLEvent
  *pEvent.SSLEvent
  Error.l
  Lock.l
  ClientName.s
  ClientPort.l
EndStructure

Structure SSLServerParams
    ServerPort.l
    KeysetFile.s
    KeysetLabel.s
    KeysetPassword.s
EndStructure

Structure SSLServerData
*Request.SSLEvent
*Event.SSLEvent
*ServerParams.SSLServerParams
EventSemaphore.l
Quit.l
EndStructure

Structure SSLServer
*SSLServerData.SSLServerData
*SSLLastEvent.SSLEvent
*SSLServerParameters.SSLServerParams
*SSLServerPrivateKey
*pSession
Error.l
EndStructure

Structure SSLClient
 hSession.l
 *DataBuffer
 DataBufferLength.l
 Position.l
EndStructure

Structure SSLSessions
  ThreadID.l
  SessionID.l
EndStructure

Declare SSL_Server_CloseConnection(Client.l)

;- ********* Internal procedures *********

Procedure.s SSL_INT_GeneratePass(NumChars)

Protected pass$ = ""

For i = 1 To NumChars

x = Random(34)

If x < 9
    c = 48 + x
    pass$ + Chr(c)
Else
    c = x - 9 + 97
    pass$ + Chr(c)
EndIf

Next

ProcedureReturn pass$

EndProcedure

Procedure SSL_INT_PopData(hSession.l, *Buffer)

Protected result.l, pBuff.l, BufferSize.l, BytesReply.l, BytesReceived.l
Protected ReturnBuffer.l, newBuffer.l

pBuff = AllocateMemory(4096)

BytesReceived = 0 

    Repeat
    result = cryptPopData(hSession, pBuff, 4096, @BytesReply)

      If BytesReply > 0
          newBuffer = ReAllocateMemory(ReturnBuffer, BytesReceived + BytesReply)
          CopyMemory(pBuff, newBuffer + BytesReceived, BytesReply)
          BytesReceived + BytesReply
          ReturnBuffer = newBuffer 
      Else
          Break 
      EndIf

    ForEver
    
    PokeL(*Buffer, ReturnBuffer)
    FreeMemory(pBuff)

    ProcedureReturn BytesReceived 
    
EndProcedure

Procedure SSL_INT_PushData(hSession.l, *MemoryBuffer, BufferLength.l)

Protected BytesReply.l, RetVal.l
   
   result = cryptPushData(hSession, *MemoryBuffer, BufferLength, @BytesReply)
   result = cryptFlushData(hSession)
   
   If result = 0
        RetVal = 1
   Else
        RetVal = 0
   EndIf
   
ProcedureReturn RetVal

EndProcedure

Procedure SSL_INT_SessionThread(*Server.SSLServer)

Protected cryptContext.l, cryptKeyset.l, cryptSession.l
Protected privateKey.l, publicKey.l, Port.l
Protected password.s, label.s, fname.s, name.s
Protected connectionsActive.l, nameLength.l, clientPort.l

With *Server\SSLServerParameters
    Port = \ServerPort
    label = \KeysetLabel
    fname = \KeysetFile ;"TestKeyset.p15"
    password = \KeysetPassword
EndWith 

Protected *Session.SSLSession, *Event.SSLEvent, *Request.SSLEvent

*Session.SSLSession = AllocateMemory(SizeOf(SSLSession))
*Event.SSLEvent = AllocateMemory(SizeOf(SSLEvent))
*Request.SSLEvent = AllocateMemory(SizeOf(SSLEvent))

*Event\ID = *Session
*Session\Error = 0

;/* Create the session */
      cryptCreateSession(@cryptSession, #CRYPT_UNUSED, #CRYPT_SESSION_SSL_SERVER)

;/* Add the server key/certificate, add the port and activate the session */
      cryptSetAttribute(cryptSession, #CRYPT_SESSINFO_SERVER_PORT, Port)
      cryptSetAttribute(cryptSession, #CRYPT_SESSINFO_PRIVATEKEY, *Server\SSLServerPrivateKey);
      cryptSetAttribute(cryptSession, #CRYPT_SESSINFO_ACTIVE, 1);

;/*------ Thread paused until new client connects ------*/;

PokeL(*Server\pSession, *Session)

*Session\hSession = cryptSession
QuitSession.l = 0

;Get Client name (IP)
name = Space(#CRYPT_MAX_TEXTSIZE + 1)
cryptGetAttributeString(cryptSession, #CRYPT_SESSINFO_CLIENT_NAME, @name, @nameLength)
*Session\ClientName = Left(name, nameLength)

;Get client port nr.
cryptGetAttribute(cryptSession, #CRYPT_SESSINFO_CLIENT_PORT, @clientPort)
*Session\ClientPort = clientPort

Repeat

LoopStart = ElapsedMilliseconds()


      ;Check if the connection is still active
       cryptGetAttribute(cryptSession, #CRYPT_SESSINFO_CONNECTIONACTIVE, @connectionActive)
          
          If connectionActive = 0
                *Event\Event =  #SSLEvent_Disconnect
                *Session\pEvent = *Event
                Break
          EndIf
           
      ;Check for new request
      If *Session\pRequest <> 0
            
            *Request.SSLEvent = *Session\pRequest
              
            With *Request
              Select \Event 
              
                  Case #SSLEvent_Data ;Request to send data to client
                        res = SSL_INT_PushData(cryptSession, \pBuffer, \Length)
                        If res = 0 : *Session\Error = #SSL_Error_Push : EndIf
                        
                  Case #SSLEvent_Disconnect ;Request to kill session        
                        QuitSession = 1
                        *Event\Event = #SSLEvent_SessionStopped
                       
              EndSelect
            EndWith
            
              
      *Session\pRequest = 0        
      EndIf

      ;Check for new data
      buff.l
      Bytes = SSL_INT_Popdata(cryptSession, @buff)
      If Bytes > 0
            
            *Event\pBuffer = ReAllocateMemory(*Event\pBuffer, Bytes)
            CopyMemory(buff, *Event\pBuffer, Bytes)
            *Event\Event = #SSLEvent_Data
            *Event\Length = Bytes
            *Event\Pos = 0
            *Session\pEvent = *Event
            
         
            FreeMemory(buff)
         
      EndIf


      
LoopEnd = ElapsedMilliseconds()
If LoopEnd - LoopStart = 0 ;Indicates that the client has disconnected without proper closure of the session (client crashed)
      QuitSession = 1
      *Event\Event=#SSLEvent_Disconnect
      *Session\pEvent = *Event
      FreeMemory(*Request)
EndIf

If QuitSession = 1
      Break
EndIf

ForEver

cryptDestroySession(cryptSession)

EndProcedure

Procedure SSL_INT_MainServerThread(*Server.SSLServer)

Protected BytesReply.l, BytesCopied.l
Protected cryptContext.l, cryptKeyset.l, privateKey.l
Protected pBuff.l, ServerState.l

With *Server\SSLServerParameters

;/* Create cryptContext */
      cryptCreateContext(@cryptContext, #CRYPT_UNUSED, #CRYPT_ALGO_RSA)

;/* Open Keyset file */
      cryptKeysetOpen(@cryptKeyset, #CRYPT_UNUSED, #CRYPT_KEYSET_FILE, \KeysetFile, #CRYPT_KEYOPT_READONLY);

;/* Load private key */
      cryptGetPrivateKey(cryptKeyset, @privateKey, #CRYPT_KEYID_NAME, \KeySetLabel, \KeysetPassword)
    
EndWith

*Server\SSLServerPrivateKey = privateKey

Dim Sessions.SSLSessions(0)
SessionCnt = 0

newSession.l = 0
*Server\pSession = @newSession
newThread = CreateThread(@SSL_INT_SessionThread(),*Server) ; Start first server session

Repeat

      ;Check for new connection
      If newSession <> 0 And *Server\SSLServerData\Quit = 0
          SessionCnt + 1
          ReDim Sessions.SSLSessions(SessionCnt)
          Sessions(SessionCnt)\SessionID = newSession
          Sessions(SessionCnt)\ThreadID = newThread
          newSession = 0
          newThread = 0
          *Server\pSession = @newSession
          ;Start new session
          newThread = CreateThread(@SSL_INT_SessionThread(),*Server)
          
      EndIf


      If SessionCnt > 0
      
        ;Check for new client events (Client to server communication)
        ;(Server to client communication is directly handled by the sessionthread)
        For i = 1 To SessionCnt
              *Sess.SSLSession = Sessions(i)\SessionID
              If *Sess\pEvent <> 0 And *Sess\Lock = 0;New event available
                    
                    *ev.SSLEvent = *Sess\pEvent
                    
                    Select *ev\Event
                        Case #SSLEvent_Data
                            *Server\SSLServerData\Event = *Sess\pEvent
                            *Sess\Lock=1
                            WaitSemaphore(*Server\SSLServerData\EventSemaphore)
                        
                        Case #SSLEvent_Disconnect
                            
                            If i < SessionCnt
                                 Sessions(i)\SessionID = Sessions(SessionCnt)\SessionID
                                 Sessions(i)\ThreadID = Sessions(SessionCnt)\ThreadID
                            EndIf
                            
                            SessionCnt -1
                            ReDim Sessions(SessionCnt)
                            
                            *Server\SSLServerData\Event = *Sess\pEvent
                            WaitSemaphore(*Server\SSLServerData\EventSemaphore)
                            
                            FreeMemory(*ev)
                            FreeMemory(*Sess)

                        Case #SSLEvent_SessionStopped
                            If i < SessionCnt
                                 Sessions(i)\SessionID = Sessions(SessionCnt)\SessionID
                                 Sessions(i)\ThreadID = Sessions(SessionCnt)\ThreadID
                            EndIf
                            
                            SessionCnt -1
                            ReDim Sessions(SessionCnt)
                            
                            FreeMemory(*Sess\pEvent)
                            FreeMemory(*Sess\pRequest)
                            FreeMemory(*Sess)
                            
                     EndSelect     

              EndIf
              
              If *Sess\Error <> 0
                    *Server\Error = *Sess\Error
              EndIf
              
        Next
         

      EndIf

      ;Check for request to quit server
      If *Server\SSLServerdata\Quit = 1 And Exit <> 1
            If IsThread(newThread)
                KillThread(newThread)
            EndIf
            For i = 1 To SessionCnt
                SSL_Server_CloseConnection(Sessions(i)\SessionID)
            Next
            Exit = 1
      ElseIf *Server\SSLServerData\Quit=1 And Exit = 1
            Break
      EndIf

ForEver

EndProcedure

Procedure SSL_INT_GenerateKeyset(newKeysetFile.s, KeysetLabel.s, CommonName.s, PassWord.s)

;Parameter specifications:
;========================
;newKeysetFile:   a path+filename where the keyset and certificate can be saved to. 
;                 existing files will be overwritten. The common used extension for this kind of file is *.p15 (see Cryptlib manual).
;KeysetLabel:     a label where to identify the generated keyset by in the keyset file.
;PassWord:        password used for future extraction of the private key.
;CommonName:      Name used for certificate. This should typically be the server name (e.g. www.yourserver.com) but every random string is accepted.
;                 Not using the server name may cause some browsers to generate warning messages (see Cryptlib manual).
;========================


;*** Generate keyset with certificate ***

Protected cryptContext.l, cryptKeyset.l, cryptCertificate.l
Protected ReturnValue.l = 1


RetVal = cryptCreateContext(@cryptContext, #CRYPT_UNUSED, #CRYPT_ALGO_RSA) ;Create encription context
If RetVal <> 0 : ReturnValue = 0 : EndIf

    RetVal = cryptSetAttributeString(cryptContext, #CRYPT_CTXINFO_LABEL, @KeysetLabel, Len(KeysetLabel));
    If RetVal <> 0 : ReturnValue = 0 : EndIf
    
    RetVal = cryptGenerateKey(cryptContext);
    If RetVal <> 0 : ReturnValue = 0 : EndIf
    
    RetVal = cryptKeysetOpen(@cryptKeyset, #CRYPT_UNUSED, #CRYPT_KEYSET_FILE, newKeysetFile, #CRYPT_KEYOPT_CREATE);
    If RetVal <> 0 : ReturnValue = 0 : EndIf
    
    ;/* Load/store keys */
        RetVal = cryptAddPrivateKey(cryptKeyset, cryptContext, PassWord);
        If RetVal <> 0 : ReturnValue = 0 : EndIf
        
        ;/* Create a simplified certificate */
        RetVal = cryptCreateCert(@cryptCertificate, #CRYPT_UNUSED, #CRYPT_CERTTYPE_CERTIFICATE);
        If RetVal <> 0 : ReturnValue = 0 : EndIf
        
        RetVal = cryptSetAttribute(cryptCertificate, #CRYPT_CERTINFO_XYZZY, 1);
        If RetVal <> 0 : ReturnValue = 0 : EndIf
        
        ;/* Add the public key And certificate owner name And sign the certificate with the private key */
        RetVal = cryptSetAttribute(cryptCertificate, #CRYPT_CERTINFO_SUBJECTPUBLICKEYINFO, cryptContext);
        If RetVal <> 0 : ReturnValue = 0 : EndIf
        
        RetVal = cryptSetAttributeString(cryptCertificate, #CRYPT_CERTINFO_COMMONNAME, @CommonName, Len(CommonName));
        If RetVal <> 0 : ReturnValue = 0 : EndIf
        
        RetVal = cryptSignCert(cryptCertificate, cryptContext);
        If RetVal <> 0 : ReturnValue = 0 : EndIf
        
        RetVal = cryptAddPublicKey(cryptKeyset, cryptCertificate );
        If RetVal <> 0 : ReturnValue = 0 : EndIf

    RetVal = cryptKeysetClose(cryptKeyset)
    If RetVal <> 0 : ReturnValue = 0 : EndIf
    
RetVal = cryptDestroyContext(cryptContext);
If RetVal <> 0 : ReturnValue = 0 : EndIf

ProcedureReturn ReturnValue

EndProcedure

;- ******** SSL Server procedures ********

Procedure SSL_Server_Create(Port.l, ServerName.s)

KeySetFile$ = GetTemporaryDirectory()+SSL_INT_GeneratePass(8) + ".p15"
Pass$ = SSL_INT_GeneratePass(16)
SSL_INT_GenerateKeyset(KeySetFile$, "key", ServerName, Pass$)

*Server.SSLServer = AllocateMemory(SizeOf(SSLServer))

With *Server
 \SSLServerData = AllocateMemory(SizeOf(SSLServerData))
 \SSLLastEvent = AllocateMemory(SizeOf(SSLEvent))
 \SSLServerParameters = AllocateMemory(SizeOf(SSLServerParams))
 \SSLServerPrivateKey = AllocateMemory(4)
EndWith

*Server\SSLServerData\EventSemaphore = CreateSemaphore()

With *Server\SSLServerParameters
    \ServerPort = Port.l
    \KeysetLabel = "key"
    \KeysetFile = KeySetFile$
    \KeysetPassword = Pass$
EndWith 
  
  CreateThread(@SSL_INT_MainServerThread(), *Server)
  Delay(20)
  DeleteFile(KeySetFile$)

  ProcedureReturn *Server

EndProcedure

Procedure SSL_Server_Destroy(ServerID)
*Server.SSLServer = ServerID
*Server\SSLServerdata\Quit = 1
EndProcedure

Procedure SSL_Server_Event(ServerID)

*Server.SSLServer = ServerID

res = 0
    If *Server\SSLServerData\Event <> 0
           
           *event.SSLEvent = *Server\SSLServerData\Event
           Debug "event noticed"
           
           Select *event\Event
                  Case #SSLEvent_Data
                        res = #SSLEvent_Data
                        With *Server\SSLLastEvent
                            \Event = #SSLEvent_Data
                            \ID = *event\ID
                            \Length = *event\Length
                            \pBuffer = ReAllocateMemory(\pBuffer, \Length)
                            \Pos = 0
                            CopyMemory(*event\pBuffer, \pBuffer, \Length)
                            *Session.SSLSession = \ID
                            *Session\pEvent = 0
                            *Session\Lock = 0
                        EndWith
                  Case #SSLEvent_Disconnect
                        res = #SSLEvent_Disconnect
                        With *Server\SSLLastEvent
                            \Event = #SSLEvent_Disconnect
                            \ID = *event\ID
                            *Session.SSLSession = \ID
                            *Session\pEvent = 0
                            *Session\Lock = 0
                        EndWith     
                        
           EndSelect
    *Server\SSLServerData\Event = 0
    SignalSemaphore(*Server\SSLServerData\EventSemaphore)
    EndIf

ProcedureReturn res

EndProcedure 

Procedure SSL_Server_EventClient(ServerID)
    *Server.SSLServer = ServerID
    res = *Server\SSLLastEvent\ID
    ProcedureReturn res
EndProcedure

Procedure SSL_Server_ReceiveData(ServerID, *MemoryBuffer, Length)

*Server.SSLServer = ServerID

LastRun = 0
    With *Server\SSLLastEvent
        If \pos < \Length
              BytesToGo.l = \Length - \pos
              If BytesToGo < Length
                    BytesToRead = BytesToGo
                    LastRun = 1
              Else
                    BytesToRead = Length      
              EndIf
              
              CopyMemory(\pBuffer + \pos, *MemoryBuffer, BytesToRead)
              \pos + BytesToRead
         Else
            Lastrun = 1
         EndIf
              
         If LastRun = 1
              \Event = 0
              \Length = 0
              \Pos = 0
              *Sess.SSLSession = \ID
              *Sess\Lock = 0
         EndIf
    
    EndWith
    
    ProcedureReturn BytesToRead
    
EndProcedure

Procedure SSL_Server_Error(ServerID)

*Server.SSLServer = ServerID
ProcedureReturn *Server\Error 

EndProcedure

Procedure SSL_Server_SendData(Client.l, *MemoryBuffer, Length.l)

*Sess.SSLSession = Client
*Request.SSLEvent = AllocateMemory(SizeOf(SSLEvent))

With *Request
    \Event = #SSLEvent_Data
    \ID = Client
    \Length = Length
    *buff = ReAllocateMemory(\pBuffer, Length)
    If *buff
      \pBuffer = *buff
      CopyMemory(*MemoryBuffer, \pBuffer, Length)
    Else
      *Sess\Error = #SSL_Error_AllocateMemory
    EndIf
EndWith

*Sess\pRequest = *Request

EndProcedure

Procedure SSL_Server_SendString(Client.l, String.s)

Length = Len(String)

If Length > 0

*Sess.SSLSession = Client
*Request.SSLEvent = AllocateMemory(SizeOf(SSLEvent))

With *Request
    \Event = #SSLEvent_Data
    \ID = Client
    \Length = Length
    *buff = ReAllocateMemory(\pBuffer, Length)
    If *buff
      \pBuffer = *buff
      PokeS(\pBuffer, String)
    Else
      *Sess\Error = #SSL_Error_AllocateMemory
    EndIf
EndWith

*Sess\pRequest = *Request

EndIf

EndProcedure

Procedure SSL_Server_CloseConnection(Client.l)
  *Sess.SSLSession = Client
  *Request.SSLEvent = AllocateMemory(SizeOf(SSLEvent))
  With *Request
      \Event = #SSLEvent_Disconnect
      \ID = Client
  EndWith
  *Sess\pRequest = *Request
EndProcedure

Procedure SSL_Server_SessionHandle(Client.l)
  *Sess.SSLSession = Client
  handle.l = *Sess\hSession
  ProcedureReturn handle
EndProcedure

Procedure.s SSL_Server_GetClientIP(Client.l)

*Sess.SSLSession = Client
ProcedureReturn *Sess\ClientName

EndProcedure

Procedure SSL_Server_GetClientPort(Client.l)

*Sess.SSLSession = Client
ProcedureReturn *Sess\ClientPort

EndProcedure

;- ******** SSL Client procedures *********

Procedure SSL_Client_OpenConnection(ServerName.s, Port.l)

Protected cryptSession;

;/* Create the session */
    cryptCreateSession(@cryptSession, #CRYPT_UNUSED, #CRYPT_SESSION_SSL);

;/* Add the server name and activate the session */
    cryptSetAttributeString(cryptSession, #CRYPT_SESSINFO_SERVER_NAME, @ServerName, Len(ServerName));
    cryptSetAttribute(cryptSession, #CRYPT_SESSINFO_SERVER_PORT, Port)
    cryptSetAttribute(cryptSession, #CRYPT_SESSINFO_ACTIVE, 1 );
   
    *newConnection.SSLClient = AllocateMemory(SizeOf(SSLClient))
    With *newConnection
          \hSession = cryptSession
    EndWith

    ProcedureReturn *newConnection

EndProcedure

Procedure SSL_Client_Event(Client)

Protected connectionActive.l, buff.l
*Conn.SSLClient = Client

With *Conn
      cryptGetAttribute(\hSession, #CRYPT_SESSINFO_CONNECTIONACTIVE, @connectionActive)
      If connectionActive
          
          Bytes = SSL_INT_PopData(\hSession, @buff)
          If Bytes > 0
              \DataBuffer = buff
              \DataBufferLength = Bytes
              \Position =0
              RetVal = #SSLEvent_Data
          EndIf
          
      Else
          RetVal = #SSLEvent_Disconnect
      EndIf
EndWith

ProcedureReturn RetVal

EndProcedure

Procedure SSL_Client_ReceiveData(Client, *MemoryBuffer, Length.l)

Protected BytesToCopy.l = 0

*Conn.SSLClient = Client

With *Conn

If \DataBuffer <> 0
    
    If Length < (\DataBufferLength - \Position)
          BytesToCopy = Length
    Else
          BytesToCopy = (\DataBufferLength - \Position)
    EndIf
    
    CopyMemory(\DataBuffer + \Position, *MemoryBuffer, BytesToCopy)
    
    totalCopied = \Position + BytesToCopy
    \Position = totalCopied
    
    If BytesToCopy < Length
       FreeMemory(\DataBuffer)
       \DataBuffer = 0  
       \DataBufferLength = 0
       \Position = 0
    EndIf
    
EndIf
    
EndWith

ProcedureReturn BytesToCopy

EndProcedure

Procedure SSL_Client_SendData(Client, *MemoryBuffer, BufferLength.l);

Protected BytesCopied.l, result.l

*Conn.SSLClient = Client

result = 0

If cryptPushData(*Conn\hSession, *MemoryBuffer, BufferLength, @BytesCopied) = 0
   cryptFlushData(*Conn\hSession)
   result = 1
EndIf

ProcedureReturn result

EndProcedure

Procedure SSL_Client_SendString(Client, String$);

Protected BytesCopied.l, result.l

*Conn.SSLClient = Client

result = 0

If cryptPushData(*Conn\hSession, @String$, Len(String$), @BytesCopied) = 0
   cryptFlushData(*Conn\hSession)
   result = 1
EndIf

ProcedureReturn result

EndProcedure

Procedure SSL_Client_CloseConnection(Client)

    Protected *Conn.SSLClient
    Protected result = 0
    
    *Conn = Client
    
    If cryptDestroySession(*Conn\hSession) = 0
            result = 1
    EndIf

    If *Conn\DataBuffer <> 0
        FreeMemory(*Conn\DataBuffer)
    EndIf
    FreeMemory(*Conn)
    
ProcedureReturn result    

EndProcedure

; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 220
; FirstLine = 126
; Folding = PARAOpiV9
; EnableUnicode
; EnableXP