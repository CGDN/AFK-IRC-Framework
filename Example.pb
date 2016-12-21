IncludeFile "Lib_IRC.pbi" ; IRC Functions
;IncludeFile "WinHTTP.pbi" ; WinHTTP.lib interface

Global QuitSignal = #False
Global Socket01, Socket02, Socket03.l


Procedure IRC_LineCallBack(SocketID.l, Line$) ; Required Function for handling text in your program. (Pre-Declared in Lib_IRC.pbi, Therefore it Must Exist.)
  
  ; First we will create an IRC_TextLine Structure, then we will populate it
  
  Protected ThisLine.IRC_TextLine
  
  With ThisLine
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
      \Line_RtnAddr = \Line_From ; Establish
    Else
      \Line_Type = #AFK_PRIVMSG_CHANNEL
      \Line_RtnAddr = \Line_Channel ; Establish
    EndIf
  EndWith
  
  ; At this point you can do as you wish with the Line Data, using the ThisLine\ structure, but in this example
  ; we are simply debugging the received text with a timestamp.
  
  Debug FormatDate("%hh:%ii:%ss",Date()) + " <"+ Str(SocketID) +  "> Scan: " + Line$
  
EndProcedure

Procedure Main()
  If InitializeSockets() 
    Debug "cryptInit(): " + cryptInit()
    Socket01 = IRC_Connect(Socket01, "irc.yournetwork.net", 6697, "testClient", #True)
    ;Socket02 = IRC_Connect(Socket02, "irc.someothernetwork.com", 6667, "test2")
    ;Socket03 = IRC_Connect(....
    Repeat
      Delay(27)
    Until QuitSignal = #True
    ShutdownSockets(1)
    Debug "cryptEnd(): " + cryptEnd()
    End
  Else
    Debug "Network Error."
  EndIf
  
EndProcedure

Main()
; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 48
; FirstLine = 6
; Folding = -
; EnableThread
; EnableXP
; EnableAdmin
; Executable = test.exe
; Debugger = Standalone