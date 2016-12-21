;/-------------------------------------------------------------------------------------------------------------\
;
;     IRC Functions Interface Unit:  
;                   - Contains Miscellaneous Functionality.
;                   - Component of AFK-Operator IRC Framework Project. (Developed/Tested on UnrealIRCd-4.0.1)
;
;\-------------------------------------------------------------------------------------------------------------/
DataSection
  IV: ; This is the "Salt" for the Key-Based AES Encryption used in ENC() and DEC()
  Data.a $3d, $af, $ba, $42, $9d, $9e, $b4, $30, $b4, $22, $da, $80, $2c, $9f, $ac, $41
EndDataSection

Global CR$ = Chr(13)+Chr(10) ; Carriage-Return String Character
Global CK$ = "e59712260835192573f1ddde7588a325" ; MD5 string for private key

Procedure.s ENC(TXT$, K__$)
  Protected.i szL, S64 ; Length, Size64
  Protected *kAE, *iAE, *oAE, *o64 ; KeyAES, InAES, outAES, out64 (*)
  Protected ENC$
  *kAE = AllocateMemory(32)
  If *kAE
    If StringByteLength(K__$, #PB_UTF8) <= 32
      PokeS(*kAE, K__$, -1, #PB_UTF8|#PB_String_NoZero)
      szL = StringByteLength(TXT$, #PB_UTF8) + 1
      If szL < 16
        szL = 16
      EndIf
      *iAE = AllocateMemory(szL)
      If *iAE
        PokeS(*iAE, TXT$, -1, #PB_UTF8)
        *oAE = AllocateMemory(szL)
        If *oAE
          If AESEncoder(*iAE, *oAE, szL, *kAE, 256, ?IV)
            S64 = szL * 1.5
            If S64 < 64
              S64 = 64
            EndIf
            *o64 = AllocateMemory(S64)
            If *o64
              S64 = Base64Encoder(*oAE, szL, *o64, S64)
              If S64
                ENC$ = PeekS(*o64, S64, #PB_Ascii)
              EndIf
              FreeMemory(*o64)
            EndIf
          EndIf
          FreeMemory(*oAE)
        EndIf
        FreeMemory(*iAE)
      EndIf
    EndIf
    FreeMemory(*kAE)
  EndIf
  ProcedureReturn ENC$
EndProcedure

Procedure.s DEC(TXT$, K__$)
  Protected.i szL
  Protected *kAE, *i64, *o64, *oAE
  Protected d$
  *kAE = AllocateMemory(32)
  If *kAE
    If StringByteLength(K__$, #PB_UTF8) <= 32
      PokeS(*kAE, K__$, -1, #PB_UTF8|#PB_String_NoZero)
      *i64 = AllocateMemory(StringByteLength(TXT$, #PB_Ascii))
      If *i64
        PokeS(*i64, TXT$, -1, #PB_Ascii|#PB_String_NoZero)
        *o64 = AllocateMemory(MemorySize(*i64))
        If *o64
          szL = Base64Decoder(*i64, MemorySize(*i64), *o64, MemorySize(*o64))
          *oAE = AllocateMemory(szL)
          If *oAE
            If AESDecoder(*o64, *oAE, szL, *kAE, 256, ?IV)
              d$ = PeekS(*oAE, szL, #PB_UTF8)
            EndIf
            FreeMemory(*oAE)
          EndIf
          FreeMemory(*o64)
        EndIf
        FreeMemory(*i64)
      EndIf
    EndIf
    FreeMemory(*kAE)
  EndIf
  ProcedureReturn d$
EndProcedure

Procedure.s StringBetween(SourceString$, String1$, String2$, OccurenceNumber.i=0, StartPos.i=0) ; An old function to find and pull strings out of larger strings. Yep.
  Protected Start1.i = StartPos
  Protected End1.i = 0
  Protected I.i = 0
  If OccurenceNumber <> 0
    For I = 0 To OccurenceNumber
      Select I
        Case 0
          Start1 = FindString(SourceString$, String1$, Start1) + Len(String1$)
        Default
          Start1 = FindString(SourceString$, String1$, Start1) + Len(String1$)
      EndSelect
    Next
  Else
    Start1 = FindString(SourceString$, String1$, 0) + Len(String1$)
  EndIf
  End1 = FindString(SourceString$, String2$, Start1)
  End1 - Start1
  If End1 = 0 : End1 = Len(SourceString$) : EndIf
  ProcedureReturn Mid(SourceString$, Start1, End1)
EndProcedure

Procedure.s RandHex(strLen.i)
*Key = AllocateMemory(strLen)
  If OpenCryptRandom() And *Key
    CryptRandomData(*Key, strLen)
    For i = 0 To strLen-1
      Text$ + RSet(Hex(PeekB(*Key+i), #PB_Byte), 1, "0")
    Next i     
    CloseCryptRandom()
    ProcedureReturn Text$
  Else
    ;yoig
  EndIf
EndProcedure

Procedure TimeZoneOffset()
  Protected result,mode
 Protected TZ.TIME_ZONE_INFORMATION
 mode=GetTimeZoneInformation_(@TZ)
 If mode=1
  result-TZ\Bias
 ElseIf mode=2
  result-TZ\Bias-TZ\DaylightBias
 EndIf
 ProcedureReturn result*60
EndProcedure








; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 123
; Folding = I-
; EnableThread
; EnableXP