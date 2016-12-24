;/-------------------------------------------------------------------------------------------------------------\
;
;     IRC Functions Interface Unit:  
;                   - Contains functions relevant to IRC Communications.
;                   - Component of AFK-Operator IRC Framework Project. (Developed/Tested on UnrealIRCd-4.0.1)
;
;\-------------------------------------------------------------------------------------------------------------/
IncludeFile "MiscUtils.pbi" ; Misc String and Encryption procedures
IncludeFile "IRC_Netwk.pbi" ; Contains the IRC-related network functions
IncludeFile "IRC_Chars.pbi" ; Contains some Unicode Characters that mess up the IDE
IncludeFile "SSL_Library.pb" ; Contains header and library info for SSL Networking

Enumeration ; Some Constants to define message delivery and reciept types.
  #AFK_PRIVMSG_PRIVATE ; Used to tag a message that was sent to the bot privately
  #AFK_PRIVMSG_CHANNEL ; Used to tag a message that was sent to a public #Channel
EndEnumeration

Structure IRC_LIST_Channel ; Available Channels
  ChannelName$ ; "#channel" name
  ChannelDesc$ ; the channel's topic
  ChannelUsrs$ ; how many users in the channel, based on a LIST result
  ChannelMode$ ; the modes that are set on the channel
EndStructure

Structure IRC_Connection ; Structure containing information about an IRC connection instance
  SocketID.l             ; The Handle to the socket, and to the IRC Connection
  Thread.l ; The ThreadID for the connection 
  Connected.b ; Boolean connected
  Svr_Host.s ; The host that the IRC Client is connected to
  Svr_Addr.s ; The Network Address used to connect
  Svr_Port.i ; The Port the IRC server is listening on
  NetworkName.s ; The Name of the IRC Network
  Nick.s        ; The NickName used in the connection
  AltNick.s     ; an Alternate Nickname (one is auto-generated)
  Away.b ; Whether or not the client is set to "AWAY" on the server
  NickServPass.s ; NickServ Password ----
  User.s ; The UserName used in the connection
  IRCd.s ; The Name and Version of the IRCd you are connecting to
  BytesSent.l ; Total Bytes Sent to server
  BytesRecv.l ; Total Bytes Rcvd from server
  AutoReconnect.b ; Boolean to Reconnect on failure TODO
  UseSSL.b
  List AvailableChannels.IRC_LIST_Channel()
EndStructure

Structure IRC_TextLine ; The structure which contains properties of an IRC Text Line
  ParentSocketID.l ; The SocketID of the parent connection
  Line_Full.s ; The entire line
  Line_From.s ; The line's sender
  Line_Recipient.s ; The line's recipient
  Line_IRCCode.s ; The line's protocol-code
  Line_MsgText.s ; The line's message/text/content
  Line_Channel.s ; The line's channel
  Line_FromHost.s ; The line's sender's Hostname
  Line_FromUser.s ; THe Username of the line's sender
  Line_FromFull.s ; The Full Address of the line's sender
  Line_P4.s       ; The line's 4th parameter (varies in purpose)
  Line_P5.s       ; The line's 5th parameter (varies in purpose)
  Line_P6.s       ; The line's 6th parameter (varies in purpose)
  Line_TimeStmp.s ; The line's DateTime Integer
  Line_Type.l     ; The line's type (Private or Public)
  Line_RtnAddr.s  ; Who should be responed to, if need be (nick, channel, or host)
EndStructure

Structure IRC_Channel ; Properties of an IRC Channel
  ParentSocketID.l ; The SocketID of the parent connection
  ChannelName$ ; The #Name of the channel
  MyChanModes$ ; Modes set on the bot, in the channel (+v, +o, etc)
  ChannelTopic$ ; The Topic String, collected from a [332] line
  ChannelTopicDate$ ; Topic Date, collected from Line [333]
  ChannelTopicAuthor$ ; the Nick of the person to last set the topic.  Also in Line [333]
  List Users.s() ; A list of the Nicks int the channel, compiled from [353] Lines provided by server.
EndStructure

; =LISTS============================================================================================================

Global NewList Instances.IRC_Connection() ; A List of the active connections.
Global NewList Joined_Chans.IRC_Channel() ; A list of the currently-joined channels (across all sockets)

; =DECLARE==========================================================================================================

Declare IRC_LineCallBack(SocketID.l, Line$) ; This function should be included in your main program file, and is called when a new line is sent or received.\
Declare IRC_ErrorCallBack(SocketID.l, ErrorCode$, ErrorMsg$)
Declare IRC_DBGCallBack(Text$)

Declare.i IRC_Connection_AddBytesS(ParentSocketID.l, NewBytes.i) 
Declare.b IRC_Connection_IsUsingSSL(ParentSocketID.l)

; =SOCKET_SEND======================================================================================================

Procedure.i IRC_RawText(SocketID.l, TheText$) ; Sends Raw Text to the Server.  All sent lines pass through here.
  Select IRC_Connection_IsUsingSSL(SocketID)
      
    Case #False ; Standard, Non-SSL SendText
      
      IRC_DBGCallBack(FormatDate("%hh:%ii:%ss",Date()) + " <"+Str(SocketID)+"> Send: " + TheText$)
      If SocketID <> #INVALID_SOCKET And Len(TheText$) > 0
        If Not FindString(TheText$, CR$) : TheText$ = TheText$ + CR$ : EndIf  
        ResultBytes.i = send_(SocketID, @TheText$, Len(TheText$), 0)
        If ResultBytes > 0
          IRC_Connection_AddBytesS(SocketID, ResultBytes)
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf 
      EndIf
      
    Case #True ; SSL-Connection Send
      
      IRC_DBGCallBack(FormatDate("%hh:%ii:%ss",Date()) + " <"+Str(SocketID)+"> SSnd: " + TheText$)
      If SocketID <> #INVALID_SOCKET And Len(TheText$) > 0
        If Not FindString(TheText$, CR$) : TheText$ = TheText$ + CR$ : EndIf  
        ResultBytes.i = SSL_Client_SendString(SocketID, TheText$)
        If ResultBytes > 0
          IRC_Connection_AddBytesS(SocketID, ResultBytes)
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf 
      EndIf
      
  EndSelect
EndProcedure

Procedure.i IRC_SendText(SocketID.l, SendTo$, TheText$) ; Send a PRIVMSG to a specific name, over a specific Socket
  If SendTo$ <> "" And TheText$ <> ""
    IRC_RawText(SocketID, "PRIVMSG " + SendTo$ + " :" + TheText$)
  EndIf  
EndProcedure

; =IRC_LINE=========================================================================================================

Procedure.s IRC_Line_GetFrom(Line$) ; Returns the Nick of the Sender of the Line
  If StringBetween(Line$, ":", "!") <> "" And Not FindString((StringBetween(Line$, ":", "!")), " ")
    ProcedureReturn StringBetween(Line$, ":", "!")
  Else
    ProcedureReturn StringBetween(Line$, ":", " ")
  EndIf
EndProcedure

Procedure.s IRC_Line_GetFullFrom(Line$) ; Returns the ID of the Sender, Formatted as Nick!User@Host.tld
  ProcedureReturn Trim(StringField(Line$, 1, " "),":")
EndProcedure

Procedure.s IRC_Line_GetCode(Line$) ; Returns the IRC/2 Line Identifier Code/String
  ProcedureReturn StringField(Line$, 2, " ")
EndProcedure

Procedure.s IRC_Line_GetTo(Line$) ; Returns the Nick which a specific Line was sent to
  ProcedureReturn StringField(Line$, 3, " ")
EndProcedure

Procedure.s IRC_Line_GetP4(Line$) ; Returns the letters representing the change taking place as a result of a MODE command (Param 4)
  ProcedureReturn StringField(Line$, 4, " ")
EndProcedure

Procedure.s IRC_Line_GetP5(Line$) ; Returns the target Nickname of a Server MODE command (Param 5 If applicable)
  ProcedureReturn StringField(Line$, 5, " ")
EndProcedure

Procedure.s IRC_Line_GetP6(Line$) ; Returns the 6th Param (IF applicable)
  ProcedureReturn StringField(Line$, 6, " ")
EndProcedure

Procedure.s IRC_Line_GetText(Line$) ; Separate and return only the Text / Message / Params part of a line
  Protected Start = FindString(Line$, ":", FindString(Line$, "PRIVMSG", 2)+Len("PRIVMSG"))
  If Start = 0
    Start = FindString(Line$, IRC_Line_GetTo(Line$) + " ", FindString(Line$, "PRIVMSG", 2)+Len("PRIVMSG")) + Len(IRC_Line_GetTo(Line$)) 
  EndIf
  ProcedureReturn Right(Line$, Len(Line$)-Start)
EndProcedure

Procedure.s IRC_Line_GetFromUsername(Line$) ; Find the UserName of the person that sent the line
  ProcedureReturn StringBetween(IRC_Line_GetFullFrom(Line$), "!", "@")
EndProcedure

Procedure.s IRC_Line_GetFromHost(Line$) ; Find the Hostname of the person that sent the line
  ProcedureReturn StringBetween(IRC_Line_GetFullFrom(Line$)+" ", "@", " ")
EndProcedure

Procedure.s IRC_Line_GetChannel(Line$) ; Finds and returns the associated '#Channel' name in most IRC Lines
  Protected Total.i = CountString(Line$, " ")
  Protected I.i = 0
  Protected Temp$ = ""
  Select IRC_Line_GetCode(Line$)
    Case "372" ; If The line is a 372 (MOTD)
      ProcedureReturn
    Case "JOIN" ; If the line is indicative of a channel JOIN
      If Not FindString(IRC_Line_GetText(Line$), " ") And IRC_Line_GetText(Line$) <> ""
        ProcedureReturn IRC_Line_GetText(Line$)
      Else
        ProcedureReturn IRC_Line_GetTo(Line$)
      EndIf
    Case "PART" ; If the line is indicative of a channel PART
      If Not FindString(IRC_Line_GetText(Line$), " ") And IRC_Line_GetText(Line$) <> ""
        ProcedureReturn StringField(Line$, 3, " ")
      Else
        ProcedureReturn IRC_Line_GetTo(Line$)
      EndIf 
    Default ; All other cases
      For I = 1 To Total
        Temp$ = StringField(Line$, I, " ")
        If Left(Temp$, 1) = "#"
          If Not FindString(Trim(Temp$ , ":"), " ")
            ProcedureReturn Trim(Temp$, ":")
          Else
            ProcedureReturn "#" + StringBetween(Line$, "#", " ")
          EndIf 
        EndIf
      Next
  EndSelect
EndProcedure

; =IRC_AWAY=========================================================================================================

Procedure.b IRC_AWAY_305(ParentSocketID.l) ; Line 305 from server, indicating away status has been removed.
  Protected Result.b =  #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\Away = #False
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_AWAY_306(ParentSocketID.l) ; Line 306 from server, indicating away status has been set.
  Protected Result.b =  #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\Away = #True
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

; =IRC_NICK=========================================================================================================

Procedure.s IRC_Nick_TrimUserSymbols(NickName$) ; Remove mode symbols from nicks
  NickName$ = RemoveString(NickName$, "@")
  NickName$ = RemoveString(NickName$, "~")
  NickName$ = RemoveString(NickName$, "&")
  NickName$ = RemoveString(NickName$, "%")
  NickName$ = RemoveString(NickName$, "+")
  ProcedureReturn NickName$
EndProcedure 

Procedure.b IRC_Nick_Update(ParentSocketID.l, OldNick.s, NewNick.s) ; Changes a nick in the lists
  Protected Result.b = #False
  ForEach Joined_Chans()
    If Joined_Chans()\ParentSocketID = ParentSocketID
      ForEach Joined_Chans()\Users()
        If Joined_Chans()\Users() = OldNick : Joined_Chans()\Users() = NewNick : EndIf
      Next
    EndIf
  Next
  ProcedureReturn Result  
EndProcedure

; =IRC_LIST_CHANNEL=================================================================================================

Procedure.b IRC_ChanList_321(ParentSocketID.l) ; Clears channel list, server msg idicating start of channel list
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      ForEach Instances()\AvailableChannels()
        DeleteElement(Instances()\AvailableChannels())
      Next
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure  

Procedure.b IRC_ChanList_322(ParentSocketID.l, ChannelName.s, UserCount.s, Text.s) ; Adds a channel item.
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      If ChannelName <> "*"
        AddElement(Instances()\AvailableChannels())
        With Instances()\AvailableChannels()
          \ChannelName$ = ChannelName
          \ChannelUsrs$ = UserCount
          \ChannelMode$ = StringBetween(Text, "[", "]")
          \ChannelDesc$ = RemoveString(Text, "["+\ChannelMode$+"] ")
           Result = #True
        EndWith
      EndIf
    EndIf 
  Next
  ProcedureReturn Result
EndProcedure

; =IRC_CHANNEL======================================================================================================

Procedure.b IRC_Channel_IsJoined(ParentSocketID.l, ChanName.s) ; Check if channel is currently / already joined.
  Protected Result.b = #False
  ForEach Joined_Chans()
    If Joined_Chans()\ChannelName$ = ChanName And Joined_Chans()\ParentSocketID = ParentSocketID
      Result = #True : IRC_DBGCallBack("Channel " + ChanName + " found on Socket " + Str(ParentSocketID))
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Channel_Join(ParentSocketID.l, ChanName.s) ; Add a channel to the Joined Channels list
  Protected Result.b = #False
  If Not IRC_Channel_IsJoined(ParentSocketID, ChanName)
    AddElement(Joined_Chans()) : IRC_DBGCallBack("Joining: " + ChanName)
    Joined_Chans()\ParentSocketID = ParentSocketID
    Joined_Chans()\ChannelName$ = ChanName
    Result = #True
  EndIf 
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Channel_Part(ParentSocketID.l, ChanName.s) ; Remove a channel from the Joined list, (Part Channel, Self)
  Protected Result.b = #False 
  If IRC_Channel_IsJoined(ParentSocketID, ChanName)
    ForEach Joined_Chans()
      If Joined_Chans()\ChannelName$ = ChanName And Joined_Chans()\ParentSocketID = ParentSocketID
        DeleteElement(Joined_Chans())
        If Not IRC_Channel_IsJoined(ParentSocketID, ChanName)
          Result = #True
          IRC_DBGCallBack("Successfully Parted from " + ChanName + " on Socket " + Str(ParentSocketID))
        EndIf
      EndIf 
    Next
  Else
    IRC_DBGCallBack("Requested PART from " + ChanName + " on Socket " + Str(ParentSocketID) + " but that channel is not found in the list.")
  EndIf
  ProcedureReturn Result 
EndProcedure

Procedure.b IRC_Channel_332(ParentSocketID.l, ChanName.s, Topic.s) ; Sets the topic for a channel
  Protected Result.b = #False
  ForEach Joined_Chans()
    If Joined_Chans()\ParentSocketID = ParentSocketID And Joined_Chans()\ChannelName$ = ChanName
      Joined_Chans()\ChannelTopic$ = Topic
      IRC_DBGCallBack("Topic for '" + ChanName + "' set to: "+ Topic +"'")
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure  

Procedure.b IRC_Channel_333(ParentSocketID.l, ChanName.s, Author.s, DateTime.s)
  Protected Result.b = #False
  ForEach Joined_Chans()
    If Joined_Chans()\ParentSocketID = ParentSocketID And Joined_Chans()\ChannelName$ = ChanName
      Joined_Chans()\ChannelTopicAuthor$ = Author : Joined_Chans()\ChannelTopicDate$ = FormatDate("%mm/%dd/%yy at %hh:%ii:%ss", Val(DateTime))
      IRC_DBGCallBack("333 Info Set for: " + ChanName)
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Channel_353(ParentSocketID.l, Channel.s, NickList.s) ; update list of users in chan from 353 line
  If Right(NickList,1) <> " " : NickList = NickList + " " : EndIf
  IRC_DBGCallBack("NickList for " + Channel + ": '" + NickList + "'")
  Protected Result.b = #False
  ForEach Joined_Chans()
    If Joined_Chans()\ChannelName$ = Channel And Joined_Chans()\ParentSocketID = ParentSocketID
      If Trim(NickList) <> ""
        If FindString(NickList, " ")
          Protected NickCountLine.i = CountString(NickList, " ")
          For X = 1 To NickCountLine
            AddElement(Joined_Chans()\Users())
            Joined_Chans()\Users() = IRC_Nick_TrimUserSymbols(StringField(NickList, X, " "))
            IRC_DBGCallBack("New Nick: " + IRC_Nick_TrimUserSymbols(StringField(NickList, X, " ")))
          Next
        Else
          AddElement(Joined_Chans()\Users())
          Joined_Chans()\Users() = IRC_Nick_TrimUserSymbols(Trim(NickList))
          IRC_DBGCallBack(IRC_Nick_TrimUserSymbols(Trim(NickList)))
        EndIf
        SortList(Joined_Chans()\Users(), #PB_Sort_Ascending | #PB_Sort_NoCase)
        Protected Current$ = "*****"
        ForEach Joined_Chans()\Users()
          If Joined_Chans()\Users() <> Current$
            Current$ = Joined_Chans()\Users()
          Else
            IRC_DBGCallBack("Deleted Duplicate: " + Joined_Chans()\Users())
            DeleteElement(Joined_Chans()\Users())
          EndIf
        Next
        Result = #True
      EndIf 
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Channel_DropUser(ParentSocketID.l, Channel.s, Nick.s) ; Remove a user from the list when they PART a CHAN
  IRC_DBGCallBack("Removing User '"+Nick+"' From Channel '"+Channel+"'")
  Protected Result.b = #False
  ForEach Joined_Chans()
    If Joined_Chans()\ChannelName$ = Channel And Joined_Chans()\ParentSocketID = ParentSocketID
      ForEach Joined_Chans()\Users()
        If Joined_Chans()\Users() = IRC_Nick_TrimUserSymbols(Nick)
          IRC_DBGCallBack("Removed User From " + Joined_Chans()\ChannelName$ + ": '" + Joined_Chans()\Users() + "'")
          DeleteElement(Joined_Chans()\Users())
          Result = #True
        EndIf
      Next
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Channel_IsUser(ParentSocketID.l, ChannelName.s, Nick.s) ; Search for a nick, in a channel, on a socket
  Protected Result.b = #False
  ForEach Joined_Chans()
    If Joined_Chans()\ChannelName$ = ChannelName And Joined_Chans()\ParentSocketID = ParentSocketID
      ForEach Joined_Chans()\Users()
        If Joined_Chans()\Users() = Nick 
          Result = #True : ProcedureReturn Result
        EndIf
      Next
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

; =IRC_CONNECTIONS==================================================================================================

Procedure.b IRC_Connection_IsConnection(ParentSocketID.l) ; Verify that a connection exists, and is connected.
  Protected Result.b = #False
  ForEach  Instances()
    If Instances()\SocketID = ParentSocketID And Instances()\Connected = #True
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Connection_SetHost(ParentSocketID.l, NewHost.s) ; Updates the "Svr_Host" property 
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      If NewHost <> ""
        IRC_DBGCallBack("Setting Host for Socket " + Str(ParentSocketID) + ": '" + NewHost +"'")
        Instances()\Svr_Host = NewHost
        Result = #True
      EndIf
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.s IRC_Connection_GetHost(ParentSocketID.l) ; Returns the server hostname you are connected to
  Protected Result.s = ""
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Result = Instances()\Svr_Host
    EndIf
  Next
  ProcedureReturn Result
EndProcedure  

Procedure.b IRC_Connection_SetConnAddr(ParentSocketID.l, ConnAddr.s) ; Saves the address used to connect to the network
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\Svr_Addr = ConnAddr
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.s IRC_Connection_GetConnAddr(ParentSocketID.l) ; Returns the network address used to connecto the network
  Protected Result.s = ""
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Result = Instances()\Svr_Addr
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Connection_SetConnectionStatus(ParentSocketID.l, NewConnectStatus.b) ; Set the Boolean for whether the connection is active. Inactive connections are dropped (deleted) shortly thereafter via the connection loop's logic
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\Connected = NewConnectStatus
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Connection_GetConnectionStatus(ParentSocketID.l) ; Returns the boolean of whether or not the connection is active
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Result = Instances()\Connected
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Connection_SetPort(ParentSocketID.l, NewPort.i) ; Save the port being used to connect
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\Svr_Port = NewPort
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.i IRC_Connection_GetPort(ParentSocketID.l) ; Recall the port being used to connect
  Protected Result.i = -1
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Result = Instances()\Svr_Port
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Connection_SetNick(ParentSocketID.l, NewNick.s) ; Stores what this client's Nick is on the connection
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\Nick = NewNick
      Result = #True
    EndIf
  Next
  ProcedureReturn
EndProcedure

Procedure.s IRC_Connection_GetNick(ParentSocketID.l) ; Returns what this client's nick is on the connection
  Protected Result.s = ""
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Result = Instances()\Nick
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Connection_SetAltNick(ParentSocketID.l, NewNick.s) ; Stores what this client's Nick is on the connection
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\AltNick = NewNick
      Result = #True
    EndIf
  Next
  ProcedureReturn
EndProcedure

Procedure.s IRC_Connection_GetAltNick(ParentSocketID.l) ; Returns what this client's nick is on the connection
  Protected Result.s = ""
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Result = Instances()\AltNick
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Connection_SetIRCd(ParentSocketID.l, NewIRCd.s) ; Stores the IRCd Name and version of the connection
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\IRCd = NewIRCd
      IRC_DBGCallBack("Socket " + Str(ParentSocketID) + " is running '" + NewIRCd + "'")
      Result = #True
    EndIf
  Next
  ProcedureReturn
EndProcedure

Procedure.s IRC_Connection_GetIRCd(ParentSocketID.l) ; Returns the IRCd Name / Version of the conection
  Protected Result.s = ""
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Result = Instances()\IRCd
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Connection_SetUser(ParentSocketID.l, NewUser.s) ; Stores the UserName in use for the connection
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\User= NewUser
      Result = #True
    EndIf
  Next
  ProcedureReturn
EndProcedure

Procedure.s IRC_Connection_GetUser(ParentSocketID.l) ; Returns the current UserName for the connection
  Protected Result.s = ""
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Result = Instances()\User
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Connection_SetNickServPass(ParentSocketID.l, NickServPass.s) ; Store (Encrypted) Nickserv Password
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\NickServPass = ENC(NickServPass,CK$) ; Encrypt while stored.  
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.s IRC_Connection_GetNickServPass(ParentSocketID.l) ; Decrypt and return the nickserv password
  Protected Result.s = ""
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Result = DEC(Instances()\NickServPass, CK$) ; Decrypt
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Connection_SetNetworkName(ParentSocketID.l, NewNetwkName.s) ; Stores the Network Name found in the 001 line Welcome to ________ <nick>
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\NetworkName = NewNetwkName
      IRC_DBGCallBack("Setting network name string to: '" + NewNetwkName + "'")
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.s IRC_Connection_GetNetworkName(ParentSocketID.l) ; Returns the stored Network Name from the above function
  Protected Result.s = ""
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Result = Instances()\NetworkName
    EndIf 
  Next
  ProcedureReturn Result
EndProcedure

Procedure.i IRC_Connection_AddBytesS(ParentSocketID.l, NewBytes.i) ; Increment the Bytes-Sent statistic, per connection. Return value is total
  Protected Result.i = 0
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\BytesSent = Instances()\BytesSent + NewBytes
      Result = Instances()\BytesSent
    EndIf
  Next
  ProcedureReturn Result ; Non-Zero indicates success. Actual Value Indicates Total Bytes Sent on Connection thus far.
EndProcedure

Procedure.i IRC_Connection_AddBytesR(ParentSocketID.l, NewBytes.i) ; Increment the Bytes-Received stat, per connection. Return value is total
  Protected Result.i = 0
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\BytesRecv = Instances()\BytesRecv + NewBytes
      Result = Instances()\BytesRecv
    EndIf
  Next
  ProcedureReturn Result ; Non-Zero indicates success. Actual Value Indicates Total Bytes Recv on Connection thus far.
EndProcedure

Procedure.b IRC_Connection_SetThreadID(ParentSocketID.l, ReadLoopThreadID.l) ; Set the ThreadID property of a connection.
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Instances()\Thread = ReadLoopThreadID 
      Result = #True ; ThreadID property has been set.
    EndIf
  Next
  ProcedureReturn Result  
EndProcedure

Procedure.l IRC_Connection_GetThreadID(ParentSocketID.l) ; Recall the Thread ID assocciated with a connection.
  Protected Result.l = 0 ; Return ZERO if there is no thread, or no matching socketID
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      Result = Instances()\Thread
    EndIf 
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Connection_IsUsingSSL(ParentSocketID.l) ; Check if a connection instance is using SSL
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID And Instances()\UseSSL = #True
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Connection_DropConnection(ParentSocketID.l) ; Remove an element from the global list of active connections
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      If IsThread(Instances()\Thread) : KillThread(Instances()\Thread) : EndIf ; Kill Read-Loop Thread, if exists.
      DeleteElement(Instances())
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_Connection_AddConnection(ParentSocketID.l, NickName$, UserName$, Srvr_Addr$, Srvr_Port.i, UseSSL.b=#False) ; Create a new connection
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      ProcedureReturn Result
    EndIf
  Next
  Result = #True
  AddElement(Instances())
  Instances()\SocketID = ParentSocketID
  Instances()\Nick = NickName$
  Instances()\AltNick = NickName$ + "_"
  Instances()\User = UserName$
  Instances()\Svr_Addr = Srvr_Addr$
  Instances()\Svr_Host = Srvr_Addr$
  Instances()\Svr_Port = Srvr_Port
  Instances()\Connected = #True
  Instances()\UseSSL = UseSSL
  IRC_DBGCallBack("Instances() Element ADDED: " + Str(Instances()\SocketID))
  ProcedureReturn Result
EndProcedure

; =IRC_CLIENT_COMMANDS==============================================================================================

Procedure.b IRC_CMD_NAMES(ParentSocketID.l, ChannelName.s) ; Send the NAMES :#channel command to the server
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID And ChannelName <> ""
      IRC_RawText(Instances()\SocketID, "NAMES " + ChannelName)
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_CMD_QUIT(ParentSocketID.l, QuitMessage.s="") ; Sends the QUIT message, with optional message
  Protected Result.b =  #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      If QuitMessage <> ""
        QuitMessage = " :" + QuitMessage
      EndIf
      IRC_RawText(Instances()\SocketID, "QUIT" + QuitMessage)
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_CMD_NICK(ParentSocketID.l, NickName.s) ; Sends the QUIT message, with optional message
  Protected Result.b =  #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      If NickName <> ""
        NickName = " " + NickName
      EndIf
      IRC_RawText(Instances()\SocketID, "NICK" + NickName)
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_CMD_Login(ParentSocketID.l, Nickname.s, Username.s, ServerHost.s, NickServPass.s="") ; Send USER + NICK info. also stores Nickserv pass if any
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID 
      IRC_RawText(Instances()\SocketID, "NICK :" + Nickname)
      IRC_RawText(Instances()\SocketID, "USER " + UserName + " " + Get_Local_FQDN() + " " + ServerHost + " :AFK-Operator")
      Result = #True
      If NickServPass <> ""
        IRC_Connection_SetNickServPass(Instances()\SocketID, NickServPass)
      EndIf
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_CMD_AWAY(ParentSocketID.l, AwayMsg.s="AFK") ; Sets the status to Away, with a customizable away message
  Protected Result.b =  #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      IRC_RawText(Instances()\SocketID, "AWAY " + AwayMsg)
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_CMD_UNAWAY(ParentSocketID.l) ; Sets the status to Back from AWAY (No Message)
  Protected Result.b =  #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      IRC_RawText(Instances()\SocketID, "AWAY")
      Result = #True
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

Procedure.b IRC_CMD_LIST(ParentSocketID.l) ; Sends the LIST command, to get a list of available channels.
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      IRC_RawText(Instances()\SocketID, "LIST")
      Result = #True
    EndIf
  Next
  ProcedureReturn Result  
EndProcedure

Procedure.b IRC_CMD_JOIN(ParentSocketID.l, ChannelName$)
  Protected Result.b = #False
  ForEach Instances()
    If Instances()\SocketID = ParentSocketID
      IRC_RawText(Instances()\SocketID, "JOIN :"+ChannelName$)
    EndIf
  Next
  ProcedureReturn Result
EndProcedure

; =IRC_CONNECT======================================================================================================

Procedure IRC_ProtocolHandle(SocketID, Line$) ; This Function will analyze coded Lines and make changes to the structure-db as needed
  Protected IRCLine.IRC_TextLine ; Temp. Structure to store line data
  
  With IRCLine
    
    \ParentSocketID = SocketID
    \Line_Full = Line$
    \Line_Channel = IRC_Line_GetChannel(Line$)
    \Line_From = IRC_Line_GetFrom(Line$)
    \Line_FromFull = IRC_Line_GetFullFrom(Line$)
    \Line_FromUser = IRC_Line_GetFromUsername(Line$)
    \Line_FromHost = IRC_Line_GetFromHost(Line$)
    \Line_IRCCode = IRC_Line_GetCode(Line$)
    \Line_MsgText = IRC_Line_GetText(Line$)
    \Line_P4 = IRC_Line_GetP4(Line$)
    \Line_P5 = IRC_Line_GetP5(Line$)
    \Line_P6 = IRC_Line_GetP6(Line$)
    \Line_Recipient = IRC_Line_GetTo(Line$)
    \Line_RtnAddr = ""
    \Line_TimeStmp = FormatDate("%hh:%ii:%ss",Date())
    
    If \Line_Recipient = IRC_Connection_GetNick(\ParentSocketID) And \Line_IRCCode = "PRIVMSG" ;  Create Function to Check for what the bot nick is, per the given socket.
      \Line_Type = #AFK_PRIVMSG_PRIVATE
      \Line_RtnAddr = \Line_From
    Else
      \Line_Type = #AFK_PRIVMSG_CHANNEL
      \Line_RtnAddr = \Line_Channel
    EndIf
    
    Select \Line_IRCCode ; Main Switch for Line Handling
        
      Case "001" ; RPL_WELCOME : The first message sent after client registration. The text used varies widely
        IRC_Connection_SetNetworkName(\ParentSocketID, StringBetween(\Line_MsgText, "Welcome to the ", " " + IRC_Connection_GetNick(\ParentSocketID)))
      Case "004" ; RPL_MYINFO : '<server_name> <version> <user_modes> <chan_modes>'
        IRC_Connection_SetHost(\ParentSocketID, \Line_P4) : IRC_Connection_SetIRCd(\ParentSocketID, \Line_P5)
      Case "305"
        IRC_AWAY_305(\ParentSocketID) ; Sets the status of the client to NOT Away
      Case "306"
        IRC_AWAY_306(\ParentSocketID) ; Sets the status of the client to AWAY
      Case "321" ; Channel-List Start 
        IRC_ChanList_321(\ParentSocketID) ; Clears the Available-Channel List
      Case "322" ; Channel-List Item
        IRC_ChanList_322(\ParentSocketID, \Line_P4, \Line_P5, \Line_MsgText) ; Adds an available channel item
      Case "331" ; Topic for <No Topic>
        IRC_Channel_332(\ParentSocketID, \Line_Channel, \Line_MsgText)
      Case "332" ; Topic for channel
        IRC_Channel_332(\ParentSocketID, \Line_Channel, \Line_MsgText)
      Case "333" ; Topic Details (Date Created, Created by Nick)
        IRC_Channel_333(\ParentSocketID, \Line_Channel, \Line_P5, \Line_P6)
      Case "353" ; RPL_NAMEREPLY
        IRC_Channel_353(\ParentSocketID, \Line_Channel, \Line_MsgText) ; Adds to names list, eliminates duplicates
      Case "376" ; End of MOTD 
                 ;IRC_RawText(SocketID, "JOIN #cyberghetto") ; Auto-Join a channel for saving time testing
      Case "401"
        IRC_ErrorCallBack(\ParentSocketID, \Line_IRCCode, \Line_P4)
      Case "436", "433", "432" ; ERR_NICKNAMINUSE - Nickname is in use or Nickname Collision
        IRC_CMD_NICK(\ParentSocketID, \Line_P4+"_")
      Case "JOIN"
        Select \Line_From
          Case IRC_Connection_GetNick(\ParentSocketID)
            IRC_Channel_Join(\ParentSocketID, \Line_Channel)
          Default
            IRC_Channel_353(\ParentSocketID, \Line_Channel, \Line_From)
        EndSelect
      Case "PART"
        Select \Line_From
          Case IRC_Connection_GetNick(\ParentSocketID)
            IRC_Channel_Part(\ParentSocketID, \Line_Recipient)
          Default 
            IRC_Channel_DropUser(\ParentSocketID, \Line_Channel, \Line_From)
        EndSelect
      Case "NICK" ; Indicates a nick change has occurred 
        If \Line_From = IRC_Connection_GetNick(\ParentSocketID)
          IRC_Connection_SetNick(\ParentSocketID, \Line_MsgText) ; update my own nick
        EndIf
        IRC_Nick_Update(\ParentSocketID, \Line_From, \Line_MsgText) ; replace all of ld nick with new nick
      Case "QUIT"
        IRC_Channel_DropUser(\ParentSocketID, \Line_Channel, \Line_From)
      Case "MODE"
        Select \Line_P4
          Case IRC_Connection_GetNick(\ParentSocketID)
            ; AdjustModes (Self)
        EndSelect
      Case "NOTICE"
        Select \Line_From
          Case "NickServ"
            ;
        EndSelect
      Case "PRIVMSG"
        ;
    EndSelect
    
  EndWith
EndProcedure
  
Procedure IRC_GetLines(*Socket) ; This ThreadProc is a loop, and one of these exists for each active connection, to recv text.
  Protected SocketID = PeekL(*Socket)
  IRC_DBGCallBack("Read Loop For Socket: " + SocketID)
  Protected UseSSL = IRC_Connection_IsUsingSSL(SocketID)
  IRC_Connection_SetConnectionStatus(SocketID, #True)
  Repeat
    Protected NewList ReadLines.s()
    Protected TempString$ = ""
    Protected Line.s = ""
    Protected ConnectionStatus.b = #True
    
    ; Grab a block of text from the Socket/SSL Socket
    
    Select UseSSL ;IRC_Connection_IsUsingSSL(SocketID)
        
      Case #False ; NON-SSL Connection (Winsock2)

          Protected RecvBuffer.s = Space(Socket_Buffer_Size)
          Protected BytesRecv.i = #SOCKET_ERROR
          While BytesRecv = #SOCKET_ERROR
            BytesRecv = recv_(SocketID, @RecvBuffer, Len(RecvBuffer), 0)
            If BytesRecv = #WSAECONNRESET ; Connection Reset
              IRC_DBGCallBack("Connection Reset.")
              closesocket_(SocketID)
              IRC_Connection_SetConnectionStatus(SocketID, #False)
              ConnectionStatus = #False
            ElseIf BytesRecv <= 0 ; Disconnected
              IRC_Connection_SetConnectionStatus(SocketID, #False)
              ConnectionStatus = #False
              IRC_DBGCallBack("Disconnected...")
            Else
              IRC_Connection_AddBytesR(SocketID, BytesRecv)
              TempString$ = Trim(PeekS(@RecvBuffer))
            EndIf
          Wend
        
      Case #True ; SSL Connections
        
        Select SSL_Client_Event(SocketID)
          Case #SSLEvent_Data
            Protected *SSLBuff = AllocateMemory(Socket_Buffer_Size)
            SSL_Client_ReceiveData(SocketID, *SSLBuff, Socket_Buffer_Size)
            TempString$ = Trim(PeekS(*SSLBuff))
            FreeMemory(*SSLBuff)
            ;Debug "SSL: " + TempString$
          Case #SSLEvent_Disconnect
            IRC_Connection_SetConnectionStatus(SocketID, #False) 
            ConnectionStatus = #False
            IRC_DBGCallBack("SSL Connection Disconnected...")
        EndSelect
        
    EndSelect
  
    ; Now that we have up to 8k of text, split it into lines, store, and process them
    
    ReplaceString(TempString$, Chr(13), Chr(10))
    ReplaceString(TempString$, Chr(10)+Chr(10), Chr(10))
    ReturnCount.i = CountString(TempString$, Chr(10))
    For K = 1 To ReturnCount
      Line.s = RemoveString(RemoveString(StringField(TempString$, k, Chr(10)), Chr(10)), Chr(13))
      If FindString(Line, "PING :", 0)
        IRC_RawText(SocketID, ReplaceString(Line, "PING :", "PONG :",0))
      Else
        AddElement(ReadLines())
        ReadLines() = Line
      EndIf 
    Next
    
    ; Process each line recorded from the buffer
    
    If ListSize(ReadLines()) > 0
      ForEach ReadLines()
        IRC_ProtocolHandle(SocketID, ReadLines()) ; Add Logging to protocol handler
        IRC_LineCallBack(SocketID, ReadLines()) 
        DeleteElement(ReadLines())
      Next
    EndIf
    
    ;Break this loop if we have detected a disconnection, and destroy the object (IRC_Connection Structure)
    ; which is associated with the socket. TODO Optionally Auto-Reconnect
  
  Until ConnectionStatus = #False
  
  IRC_DBGCallBack("Exiting Read Thread, Socket " + Str(SocketID))
  IRC_Connection_DropConnection(SocketID)
EndProcedure

Procedure.l IRC_Connect(InSocket, Network_Addr$, Network_Port.i, NickName$, UseSSL.b=#False, NickServPass$="", UserName$="") ; Returns the Socket Handle needed to manage the connection
  ; Generate A UserName if none was given, declare a new thread, and default to #INVALID_SOCKET
  If UserName$ = "" : UserName$ = NickName$ : EndIf 
  Protected NewThread.l = -1
  InSocket = #INVALID_SOCKET
  
  Select UseSSL ; Whether or not we are using SSL, we will be after a socket handle
      
    Case #True ; Creating an SSL Connection
      InSocket = SSL_Client_OpenConnection(Network_Addr$, Network_Port) ; CryptLIb Connection Create
      IRC_DBGCallBack("Socket (SSL) Created: " + Str(InSocket))
      
    Case #False ; Non SSL (Winsock2) type connections
      InSocket = Create_Socket_Connect(Network_Addr$, Network_Port) ; Winsock2 Connection Create                                                               
      IRC_DBGCallBack("Socket Created: " + Str(InSocket))
      
  EndSelect
  
  ; If the socket is something other than the default, create a new connection object,
  ; create a new thread to read data, and save the threadID to the object.  finally, 
  ; send the login command to provide the login information passed to this function.
  
  If InSocket <> #INVALID_SOCKET
    IRC_Connection_AddConnection(InSocket, NickName$, UserName$, Network_Addr$, Network_Port, UseSSL)
    NewThread.l = CreateThread(@IRC_GetLines(), @InSocket)
    If IsThread(NewThread)
      IRC_Connection_SetThreadID(InSocket, NewThread)
    EndIf
    IRC_CMD_Login(InSocket, NickName$, UserName$, Network_Addr$, NickServPass$)
  EndIf 
  
  ProcedureReturn InSocket
EndProcedure 



; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 407
; FirstLine = 236
; Folding = gBAC9PBABBEw--
; EnableThread
; EnableXP
; EnableAdmin
; Executable = bot.exe