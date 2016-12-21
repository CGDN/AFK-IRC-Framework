

;*****************************************************************************
;*                                                                           *
;*                        cryptlib External API Interface                    *
;*                       Copyright Peter Gutmann 1997-2008                   *
;*                                                                           *
;*                 Adapted For BASIC Nov 2009 - Coast Research               * 
;*                 Adapted for PureBasic by Bart                             *
;*                                                                           *
;*****************************************************************************
;
;* Translated for PureBasic Nov 2009 from: http://www.coastrd.com/smtps/cryptlib/cryptlib_header-inc


#CRYPTLIB_VERSION    = 3420   ;  Not the same As 3.32
  
;Attribute VB_Name = "CRYPTLIB"

;OPTION EXPLICIT


;****************************************************************************
;*                                                                          *
;*                           Algorithm and Object Types                     *
;*                                                                          *
;****************************************************************************          




; The baseline for a C/C++ enum is zero(0) unless otherwise specified.
  
;ENUM CRYPT_ALGO_TYPE                                ; /* Algorithms */ 
    #CRYPT_ALGO_NONE                                = 00  ; /* No encryption */
                                                  
; /* Conventional encryption */                   
    #CRYPT_ALGO_DES                                 = 01  ; /* DES */      
    #CRYPT_ALGO_3DES                                = 02  ; /* Triple DES *
    #CRYPT_ALGO_IDEA                                = 03  ; /* IDEA */     
    #CRYPT_ALGO_CAST                                = 04  ; /* CAST-128 */ 
    #CRYPT_ALGO_RC2                                 = 05  ; /* RC2 */      
    #CRYPT_ALGO_RC4                                 = 06  ; /* RC4 */      
    #CRYPT_ALGO_RC5                                 = 07  ; /* RC5 */      
    #CRYPT_ALGO_AES                                 = 08  ; /* AES */      
    #CRYPT_ALGO_BLOWFISH                            = 09  ; /* Blowfish */ 
    #CRYPT_ALGO_SKIPJACK                            = 10  ; /* Skipjack */ 
                                                  
; /* Public-key encryption */                     
    #CRYPT_ALGO_DH                                  = 100 ; /* Diffie-Hellman */   
    #CRYPT_ALGO_RSA                                 = 101 ; /* RSA */              
    #CRYPT_ALGO_DSA                                 = 102 ; /* DSA */              
    #CRYPT_ALGO_ELGAMAL                             = 103 ; /* ElGamal */          
    #CRYPT_ALGO_KEA                                 = 104 ; /* KEA */ 
    #CRYPT_ALGO_ECDSA                                      = 105 ; /* ECDSA */
    #CRYPT_ALGO_ECDH                                        = 106 ; /* ECDH */   
                                        
; /* Hash algorithms */                           
    #CRYPT_ALGO_MD2                                 = 200 ; /* MD2 */             
    #CRYPT_ALGO_MD4                                 = 201 ; /* MD4 */             
    #CRYPT_ALGO_MD5                                 = 202 ; /* MD5 */             
    #CRYPT_ALGO_SHA                                 = 203 ; /* SHA/SHA1 */ 
    #CRYPT_ALGO_SHA1                                = 203 ; #CRYPT_ALGO_SHA
    #CRYPT_ALGO_RIPEMD160                           = 204 ; /* RIPE-MD 160 */  
    #CRYPT_ALGO_SHA2                                         = 205 ; /* SHA-256 */
    #CRYPT_ALGO_SHAng                                       = 206 ; /* Future SHA-nextgen standard */
                                                   
;    /* MAC;s */                                     
    #CRYPT_ALGO_HMAC_MD5                            = 300 ; /* SHA-256 */          
    #CRYPT_ALGO_HMAC_SHA                            = 301 ; /* HMAC-SHA */      
    #CRYPT_ALGO_HMAC_SHA1                           = 301 ; CRYPT_ALGO_HMAC_SHA
    #CRYPT_ALGO_HMAC_RIPEMD160                      = 302 ; /* HMAC-RIPEMD-160 */ 
    #CRYPT_ALGO_HMAC_SHA2                                    = 303 ; /* SHA-256 */
    #CRYPT_ALGO_HMAC_SHAng                                  = 304 ; /* Future SHA-nextgen standard */                                             
    #CRYPT_ALGO_LAST                                = 305 ; /* Last possible crypt algo value */ 
                                               
    ; In order that we can scan through a range of algorithms with cryptQueryCapability(), 
  ; we define the following boundary points for each algorithm class 
    #CRYPT_ALGO_FIRST_CONVENTIONAL                  = #CRYPT_ALGO_DES
    #CRYPT_ALGO_LAST_CONVENTIONAL                   = #CRYPT_ALGO_DH-1           ; /* MAC;s */                      
    #CRYPT_ALGO_FIRST_PKC                           = #CRYPT_ALGO_DH             ; /* HMAC-MD5 */                   
    #CRYPT_ALGO_LAST_PKC                            = #CRYPT_ALGO_MD2-1          ; /* HMAC-SHA */                   
    #CRYPT_ALGO_FIRST_HASH                          = #CRYPT_ALGO_MD2            ; /* Older form */                 
    #CRYPT_ALGO_LAST_HASH                           = #CRYPT_ALGO_HMAC_MD5-1     ;            
    #CRYPT_ALGO_FIRST_MAC                           = #CRYPT_ALGO_HMAC_MD5       ; /* HMAC-SHA2 */                  
    #CRYPT_ALGO_LAST_MAC                            = #CRYPT_ALGO_HMAC_MD5+99    ; /* HMAC-future-SHA-nextgen */    
;END ENUM CRYPT_ALGO_TYPE                                        
                                              
                                                  
;ENUM CRYPT_MODE_TYPE                                   ; /* Block cipher modes */              
    #CRYPT_MODE_NONE                                = 00  ; /* No encryption mode */              
    #CRYPT_MODE_ECB                                 = 01  ; /* ECB */                             
    #CRYPT_MODE_CBC                                 = 02  ; /* CBC */                             
    #CRYPT_MODE_CFB                                 = 03  ; /* CFB */                             
    #CRYPT_MODE_OFB                                 = 04  ; /* OFB */                             
    #CRYPT_MODE_LAST                                = 05  ; /* Last possible crypt mode value */  
;END ENUM CRYPT_MODE_TYPE                                          
                                                    
                                                    
;;ENUM CRYPT_KEYSET_TYPE                                ; /* Keyset types */                        
    #CRYPT_KEYSET_NONE                              = 00  ; /* No keyset type */                      
    #CRYPT_KEYSET_FILE                              = 01  ; /* Generic flat file keyset */            
    #CRYPT_KEYSET_HTTP                              = 02  ; /* Web page containing cert/CRL */        
    #CRYPT_KEYSET_LDAP                              = 03  ; /* LDAP directory service */              
    #CRYPT_KEYSET_ODBC                              = 04  ; /* Generic ODBC interface */              
    #CRYPT_KEYSET_DATABASE                          = 05  ; /* Generic RDBMS interface */             
    #CRYPT_KEYSET_PLUGIN                            = 06  ; /* Generic database plugin */             
    #CRYPT_KEYSET_ODBC_STORE                        = 07  ; /* ODBC certificate store */              
    #CRYPT_KEYSET_DATABASE_STORE                    = 08  ; /* Database certificate store */          
    #CRYPT_KEYSET_PLUGIN_STORE                      = 09  ; /* Database plugin certificate store */   
    #CRYPT_KEYSET_LAST                              = 10  ; /* Last possible keyset TYPE */           
;END ENUM CRYPT_KEYSET_TYPE                                        
                                                
                                                  
;;ENUM CRYPT_DEVICE_TYPE                                ; /* Crypto device types */             
    #CRYPT_DEVICE_NONE                              = 00  ; /* No crypto device */                
    #CRYPT_DEVICE_FORTEZZA                          = 01  ; /* Fortezza card */                   
    #CRYPT_DEVICE_PKCS11                            = 02  ; /* PKCS #11 crypto token */           
    #CRYPT_DEVICE_CRYPTOAPI                         = 03  ; /* Microsoft CryptoAPI */             
    #CRYPT_DEVICE_LAST                              = 04  ; /* Generic crypo HW plugin */         
;END ENUM CRYPT_DEVICE_TYPE                                             ; /* Last possible crypto device TYPE */
                                                  
                                                  
                                                  
;ENUM CRYPT_CERTTYPE_TYPE                             ; /* Certificate object types */          
    #CRYPT_CERTTYPE_NONE                            = 00 ; /* No certificate TYPE */               
    #CRYPT_CERTTYPE_CERTIFICATE                     = 01 ; /* Certificate */                       
    #CRYPT_CERTTYPE_ATTRIBUTE_CERT                  = 02 ; /* Attribute certificate */             
    #CRYPT_CERTTYPE_CERTCHAIN                       = 03 ; /* PKCS #7 certificate chain */         
    #CRYPT_CERTTYPE_CERTREQUEST                     = 04 ; /* PKCS #10 certification request */    
    #CRYPT_CERTTYPE_REQUEST_CERT                    = 05 ; /* CRMF certification request */        
    #CRYPT_CERTTYPE_REQUEST_REVOCATION              = 06 ; /* CRMF revocation request */           
    #CRYPT_CERTTYPE_CRL                             = 07 ; /* CRL */                               
    #CRYPT_CERTTYPE_CMS_ATTRIBUTES                  = 08 ; /* CMS attributes */                    
    #CRYPT_CERTTYPE_RTCS_REQUEST                    = 09 ; /* RTCS request */                      
    #CRYPT_CERTTYPE_RTCS_RESPONSE                   = 10 ; /* RTCS response */                     
    #CRYPT_CERTTYPE_OCSP_REQUEST                    = 11 ; /* OCSP request */                      
    #CRYPT_CERTTYPE_OCSP_RESPONSE                   = 12 ; /* OCSP response */                     
    #CRYPT_CERTTYPE_PKIUSER                         = 13 ; /* PKI user information */   
    #CRYPT_CERTTYPE_LAST                            = 14 ; /* Last possible format type */
;END ENUM CRYPT_CERTTYPE_TYPE                                         
          
   
;ENUM CRYPT_FORMAT_TYPE
    #CRYPT_FORMAT_NONE                                  = 00  ; /* No format TYPE */
    #CRYPT_FORMAT_AUTO                                  = 01  ; /* Deenv, auto-determine TYPE */
    #CRYPT_FORMAT_CRYPTLIB                          = 02  ; /* cryptlib native format */
    #CRYPT_FORMAT_CMS                                      = 03  ; /* PKCS #7 / CMS / S/MIME fmt.*/
    #CRYPT_FORMAT_PKCS7                             = #CRYPT_FORMAT_CMS
    #CRYPT_FORMAT_SMIME                                  = 04  ; /* AS CMS WITH MSG-style behaviour */
    #CRYPT_FORMAT_PGP                                      = 05  ; /* PGP format */   
    #CRYPT_FORMAT_LAST                                  = 06  ; /* Last possible format TYPE */    
;END ENUM CRYPT_FORMAT_TYPE
                                                                                  
                                                  
;ENUM CRYPT_SESSION_TYPE                         
    #CRYPT_SESSION_NONE                             = 00 ; /* No session TYPE */              
    #CRYPT_SESSION_SSH                              = 01 ; /* SSH */                          
    #CRYPT_SESSION_SSH_SERVER                       = 02 ; /* SSH SERVER */                   
    #CRYPT_SESSION_SSL                              = 03 ; /* SSL/TLS */                      
    #CRYPT_SESSION_SSL_SERVER                       = 04 ; /* SSL/TLS SERVER */               
    #CRYPT_SESSION_RTCS                             = 05 ; /* RTCS */                         
    #CRYPT_SESSION_RTCS_SERVER                      = 06 ; /* RTCS SERVER */                  
    #CRYPT_SESSION_OCSP                             = 07 ; /* OCSP */                        
    #CRYPT_SESSION_OCSP_SERVER                      = 08 ; /* OCSP SERVER */                 
    #CRYPT_SESSION_TSP                              = 09 ; /* TSP */                         
    #CRYPT_SESSION_TSP_SERVER                       = 10 ; /* TSP SERVER */                  
    #CRYPT_SESSION_CMP                              = 11 ; /* CMP */                         
    #CRYPT_SESSION_CMP_SERVER                       = 12 ; /* CMP SERVER */                  
    #CRYPT_SESSION_SCEP                             = 13 ; /* SCEP */                        
    #CRYPT_SESSION_SCEP_SERVER                      = 14 ; /* SCEP SERVER */   
    #CRYPT_SESSION_CERTSTORE_SERVER                 = 15 ; /* HTTP cert store interface */        
    #CRYPT_SESSION_LAST                             = 16 ; /* Last possible session TYPE */   
;END ENUM CRYPT_SESSION_TYPE                                        
                                                                                                 
                                                  
;ENUM CRYPT_USER_TYPE                               
    #CRYPT_USER_NONE                                = 00 ; /* No user TYPE */              
    #CRYPT_USER_NORMAL                              = 01 ; /* Normal user */               
    #CRYPT_USER_SO                                  = 02 ; /* Security officer */          
    #CRYPT_USER_CA                                  = 03 ; /* CA user */                   
    #CRYPT_USER_LAST                                = 04 ; /* Last possible user TYPE */   
;END ENUM CRYPT_USER_TYPE                                                        
                   
   
                        
;  /****************************************************************************
;  *                                                                                                                  *
;  *                                               Attribute Types                                             *
;  *                                                                                                                  *
;  ****************************************************************************/

; Attribute types are arranged in the following order:
;    PROPERTY    - Object property
;    ATTRIBUTE    - Generic attributes
;    OPTION        - Global or object-specific config.option
;    CTXINFO        - Context-specific attribute
;    CERTINFO    - Certificate-specific attribute
;    KEYINFO        - Keyset-specific attribute
;    DEVINFO        - Device-specific attribute
;    ENVINFO        - Envelope-specific attribute
;    SESSINFO    - Session-specific attribute
;    USERINFO    - User-specific attribute */

       
;ENUM CRYPT_ATTRIBUTE_TYPE
    #CRYPT_ATTRIBUTE_NONE                           = 00 ; /* Non-value */
    #CRYPT_PROPERTY_FIRST                           = 01 ; /* Used internally */ 
               
;    /*********************/
;    /* Object attributes */
;    /*********************/ 

; /* Object properties */
    #CRYPT_PROPERTY_HIGHSECURITY                    = 02 ; /* Owned+non-forwardcount+locked */           
    #CRYPT_PROPERTY_OWNER                           = 03 ; /* Object owner */                            
    #CRYPT_PROPERTY_FORWARDCOUNT                    = 04 ; /* No.OF times object can be forwarded */     
    #CRYPT_PROPERTY_LOCKED                          = 05 ; /* Whether properties can be chged/READ */    
    #CRYPT_PROPERTY_USAGECOUNT                      = 06 ; /* Usage count before object expires */       
    #CRYPT_PROPERTY_NONEXPORTABLE                   = 07 ; /* Whether key is nonexp.FROM context */ 
     
    #CRYPT_PROPERTY_LAST                            = 08 ; /* Used internally */
    #CRYPT_GENERIC_FIRST                            = 09 ; /* Used internally */                         

;    /* Extended error information */
    #CRYPT_ATTRIBUTE_ERRORTYPE                      = 10 ; /* TYPE OF last ERROR */            
    #CRYPT_ATTRIBUTE_ERRORLOCUS                     = 11 ; /* Locus OF last ERROR */ 
 
;http://old.nabble.com/cryptPopData-returns-CRYPT_ERROR_COMPLETE-td7356492.html         
    #CRYPT_ATTRIBUTE_INT_ERRORCODE                  = 12 ; /* Low-level software-specific */   
    #CRYPT_ATTRIBUTE_INT_ERRORMESSAGE               = 13 ; /* ERROR code & message */      

;    /* Generic information */     
    #CRYPT_ATTRIBUTE_CURRENT_GROUP                  = 14 ; /* Cursor mgt: Group IN attribute list */
    #CRYPT_ATTRIBUTE_CURRENT                        = 15 ; /* Cursor mgt: Entry IN attribute list */
    #CRYPT_ATTRIBUTE_CURRENT_INSTANCE               = 16 ; /* Cursor mgt: Instance IN attribute list */
    #CRYPT_ATTRIBUTE_BUFFERSIZE                     = 17 ; /* Internal DATA buffer SIZE */
    #CRYPT_GENERIC_LAST                             = 18 ; /* User internally */

                    

;    /****************************/
;    /* Configuration attributes */
;    /****************************/  
    #CRYPT_OPTION_FIRST                             = 100 ; /* User internally */

;    /* cryptlib information (read-only) */
    #CRYPT_OPTION_INFO_DESCRIPTION                  = 101 ; /* Text description */      
    #CRYPT_OPTION_INFO_COPYRIGHT                    = 102 ; /* Copyright notice */      
    #CRYPT_OPTION_INFO_MAJORVERSION                 = 103 ; /* Major release version */ 
    #CRYPT_OPTION_INFO_MINORVERSION                 = 104 ; /* Minor release version */ 
    #CRYPT_OPTION_INFO_STEPPING                     = 105 ; /* Release stepping */      
                                                 
;    /* Encryption options */                         
    #CRYPT_OPTION_ENCR_ALGO                         = 106 ; /* Encryption algorithm */
    #CRYPT_OPTION_ENCR_HASH                         = 107 ; /* Hash algorithm */      
    #CRYPT_OPTION_ENCR_MAC                          = 108 ; /* MAC algorithm */       
                                               
;    /* PKC options */                              
    #CRYPT_OPTION_PKC_ALGO                          = 109 ; /* Public-key encryption algorithm */  
    #CRYPT_OPTION_PKC_KEYSIZE                       = 110 ; /* Public-key encryption key size */  
                                                 
;    /* Signature options */                       
    #CRYPT_OPTION_SIG_ALGO                          = 111 ; /* Signature algorithm */    
    #CRYPT_OPTION_SIG_KEYSIZE                       = 112 ; /* Signature keysize */  
                                                 
;    /* Keying options */                                              
    #CRYPT_OPTION_KEYING_ALGO                       = 113 ; /* Key processing algorithm */
    #CRYPT_OPTION_KEYING_ITERATIONS                 = 114 ;    /* Key processing iterations */

;    /* Certificate options */
    #CRYPT_OPTION_CERT_SIGNUNRECOGNISEDATTRIBUTES   = 115 ; /* Whether TO sign unrecog.attrs */            
    #CRYPT_OPTION_CERT_VALIDITY                     = 116 ; /* Certificate validity period */              
    #CRYPT_OPTION_CERT_UPDATEINTERVAL               = 117 ; /* CRL update interval */                      
    #CRYPT_OPTION_CERT_COMPLIANCELEVEL              = 118 ; /* PKIX compliance level FOR cert chks.*/ 
    #CRYPT_OPTION_CERT_REQUIREPOLICY                = 119 ;    /* Whether explicit policy req;d For certs */

;    /* CMS/SMIME options */
    #CRYPT_OPTION_CMS_DEFAULTATTRIBUTES             = 120 ; /* Add default CMS attributes */ 
    #CRYPT_OPTION_SMIME_DEFAULTATTRIBUTES           = #CRYPT_OPTION_CMS_DEFAULTATTRIBUTES

;    /* LDAP keyset options */
    #CRYPT_OPTION_KEYS_LDAP_OBJECTCLASS             = 121 ; /* Object class */
    #CRYPT_OPTION_KEYS_LDAP_OBJECTTYPE              = 122 ; /* Object TYPE TO fetch */
    #CRYPT_OPTION_KEYS_LDAP_FILTER                  = 123 ; /* Query filter */
    #CRYPT_OPTION_KEYS_LDAP_CACERTNAME              = 124 ; /* CA certificate attribute NAME */
    #CRYPT_OPTION_KEYS_LDAP_CERTNAME                = 125 ; /* Certificate attribute NAME */
    #CRYPT_OPTION_KEYS_LDAP_CRLNAME                 = 126 ; /* CRL attribute NAME */
    #CRYPT_OPTION_KEYS_LDAP_EMAILNAME               = 127 ; /* Email attribute NAME */
           
;    /* Crypto device options */
    #CRYPT_OPTION_DEVICE_PKCS11_DVR01                  = 128 ; /* NAME OF first PKCS #11 driver */
    #CRYPT_OPTION_DEVICE_PKCS11_DVR02                  = 129 ; /* NAME OF second PKCS #11 driver */
    #CRYPT_OPTION_DEVICE_PKCS11_DVR03                  = 130 ; /* NAME OF third PKCS #11 driver */
    #CRYPT_OPTION_DEVICE_PKCS11_DVR04                  = 131 ; /* NAME OF fourth PKCS #11 driver */
    #CRYPT_OPTION_DEVICE_PKCS11_DVR05                  = 132 ; /* NAME OF fifth PKCS #11 driver */
    #CRYPT_OPTION_DEVICE_PKCS11_HARDWAREONLY        = 133 ; /* Use only hardware mechanisms */
                    
;    /* Network ACCESS options */
    #CRYPT_OPTION_NET_SOCKS_SERVER                      = 134 ; /* Socks SERVER NAME */
    #CRYPT_OPTION_NET_SOCKS_USERNAME                  = 135 ; /* Socks user NAME */
    #CRYPT_OPTION_NET_HTTP_PROXY                        = 136 ; /* Web proxy SERVER */
    #CRYPT_OPTION_NET_CONNECTTIMEOUT                  = 137 ; /* TIMEOUT FOR network connection setup */
    #CRYPT_OPTION_NET_READTIMEOUT                        = 138 ; /* TIMEOUT FOR network reads */
    #CRYPT_OPTION_NET_WRITETIMEOUT                      = 139 ; /* TIMEOUT FOR network writes */

;    /* Miscellaneous options */
    #CRYPT_OPTION_MISC_ASYNCINIT                      = 140 ; /* Whether TO init cryptlib async;ly */
    #CRYPT_OPTION_MISC_SIDECHANNELPROTECTION        = 141 ; /* Protect against side-channel attacks */
      
;    /* cryptlib STATE information */
    #CRYPT_OPTION_CONFIGCHANGED                          = 142 ; /* Whether IN-mem.opts match ON-disk ones */
    #CRYPT_OPTION_SELFTESTOK                        = 143 ; /* Whether self-test was completed & OK */

; /* Used internally */
  #CRYPT_OPTION_LAST                              = 144 ; /* Used internally */

             

   
;    /**********************/
;    /* Context attributes */
;    /**********************/
  #CRYPT_CTXINFO_FIRST                            = 1000 ; /* Used internally */
                          

;    /* Algorithm & mode information */
    #CRYPT_CTXINFO_ALGO                                      = 1001 ; /* Algorithm */
    #CRYPT_CTXINFO_MODE                                      = 1002 ; /* Mode */
    #CRYPT_CTXINFO_NAME_ALGO                            = 1003 ; /* Algorithm NAME */
    #CRYPT_CTXINFO_NAME_MODE                            = 1004 ; /* Mode NAME */
    #CRYPT_CTXINFO_KEYSIZE                                = 1005; /* Key SIZE IN bytes */
    #CRYPT_CTXINFO_BLOCKSIZE                            = 1006 ; /* Block SIZE */
    #CRYPT_CTXINFO_IVSIZE                              = 1007 ; /* IV SIZE */
    #CRYPT_CTXINFO_KEYING_ALGO                          = 1008 ; /* Key processing algorithm */
    #CRYPT_CTXINFO_KEYING_ITERATIONS                = 1009 ; /* Key processing iterations */
    #CRYPT_CTXINFO_KEYING_SALT                          = 1010 ; /* Key processing salt */
    #CRYPT_CTXINFO_KEYING_VALUE                          = 1011 ; /* Value used TO derive key */

;    /* STATE information */
    #CRYPT_CTXINFO_KEY                                      = 1012 ; /* Key */
    #CRYPT_CTXINFO_KEY_COMPONENTS                      = 1013 ; /* Public-key components */
    #CRYPT_CTXINFO_IV                                        = 1014 ; /* IV */
    #CRYPT_CTXINFO_HASHVALUE                            = 1015 ; /* Hash value */

;    /* Misc.information */
    #CRYPT_CTXINFO_LABEL                                  = 1016 ; /* LABEL FOR PRIVATE/secret key */
    #CRYPT_CTXINFO_PERSISTENT                            = 1017 ; /* Obj.is backed by device OR keyset */
      
;    /* Used internally */
    #CRYPT_CTXINFO_LAST                             = 1018 ; /* Used internally */  
           


;    /**************************/
;    /* Certificate attributes */
;    /**************************/
    #CRYPT_CERTINFO_FIRST                           = 2000  
                    
    ; Because there are so many cert attributes, we break them down into
    ; blocks to minimise the number of values that change if a new one is
    ; added halfway through */
     

    ; Pseudo-information on a cert object or meta-information which is used
    ; TO CONTROL the way that a cert object is processed */
       
    #CRYPT_CERTINFO_SELFSIGNED                            = 2001 ; /* Cert is self-SIGNED */
    #CRYPT_CERTINFO_IMMUTABLE                              = 2002 ; /* Cert is SIGNED & immutable */
    #CRYPT_CERTINFO_XYZZY                                    = 2003 ; /* Cert is a magic just-works cert */
    #CRYPT_CERTINFO_CERTTYPE                              = 2004 ; /* Certificate object TYPE */
    #CRYPT_CERTINFO_FINGERPRINT                            = 2005 ; /* Certificate fingerprints */
    #CRYPT_CERTINFO_FINGERPRINT_MD5                   = #CRYPT_CERTINFO_FINGERPRINT
    #CRYPT_CERTINFO_FINGERPRINT_SHA                   = 2006
                                                    
    #CRYPT_CERTINFO_CURRENT_CERTIFICATE               = 2007 ; /* Cursor mgt: Rel.pos IN chain/CRL/OCSP */
    #CRYPT_CERTINFO_TRUSTED_USAGE                       = 2008 ; /* Usage that cert is trusted FOR */
    #CRYPT_CERTINFO_TRUSTED_IMPLICIT                  = 2009 ; /* Whether cert is implicitly trusted */
    #CRYPT_CERTINFO_SIGNATURELEVEL                    = 2010 ; /* Amount OF detail TO include IN sigs.*/
                                                    
;    /* General certificate object information */      
    #CRYPT_CERTINFO_VERSION                                  = 2011 ; /* Cert.format version */
    #CRYPT_CERTINFO_SERIALNUMBER                        = 2012 ; /* Serial number */
    #CRYPT_CERTINFO_SUBJECTPUBLICKEYINFO                = 2013 ; /* Public key */
    #CRYPT_CERTINFO_CERTIFICATE                            = 2014 ; /* User certificate */
    #CRYPT_CERTINFO_USERCERTIFICATE                   = #CRYPT_CERTINFO_CERTIFICATE
    #CRYPT_CERTINFO_CACERTIFICATE                        = 2015 ; /* CA certificate */
    #CRYPT_CERTINFO_ISSUERNAME                            = 2016 ; /* Issuer DN */
    #CRYPT_CERTINFO_VALIDFROM                              = 2017 ; /* Cert valid-FROM time */
    #CRYPT_CERTINFO_VALIDTO                                  = 2018 ; /* Cert valid-TO time */
    #CRYPT_CERTINFO_SUBJECTNAME                            = 2019 ; /* Subject DN */
    #CRYPT_CERTINFO_ISSUERUNIQUEID                      = 2020 ; /* Issuer unique ID */
    #CRYPT_CERTINFO_SUBJECTUNIQUEID                      = 2021 ; /* Subject unique ID */
    #CRYPT_CERTINFO_CERTREQUEST                            = 2022 ; /* Cert.request (DN + public key) */
    #CRYPT_CERTINFO_THISUPDATE                            = 2023 ; /* CRL/OCSP current-update time */
    #CRYPT_CERTINFO_NEXTUPDATE                            = 2024 ; /* CRL/OCSP NEXT-update time */
    #CRYPT_CERTINFO_REVOCATIONDATE                      = 2025 ; /* CRL/OCSP cert-revocation time */
    #CRYPT_CERTINFO_REVOCATIONSTATUS                  = 2026 ; /* OCSP revocation STATUS */
    #CRYPT_CERTINFO_CERTSTATUS                            = 2027 ; /* RTCS certificate STATUS */
    #CRYPT_CERTINFO_DN                                        = 2028 ; /* Currently selected DN IN STRING form */
    #CRYPT_CERTINFO_PKIUSER_ID                            = 2029 ; /* PKI user ID */
    #CRYPT_CERTINFO_PKIUSER_ISSUEPASSWORD                = 2030 ; /* PKI user issue password */
    #CRYPT_CERTINFO_PKIUSER_REVPASSWORD                    = 2031 ; /* PKI user revocation password */
                                                    
          
                                
    ; X.520 Distinguished Name components.  This is a composite field, the
    ; DN to be manipulated is selected through the addition of a
    ; pseudocomponent, and then one of the following is used to access the
    ; DN components directly */
    #CRYPT_CERTINFO_COUNTRYNAME                       = 100 + 2000 ; CRYPT_CERTINFO_FIRST     /* countryName */
    #CRYPT_CERTINFO_STATEORPROVINCENAME               = 2101 ; /* stateOrProvinceName */
    #CRYPT_CERTINFO_LOCALITYNAME                      = 2102 ; /* localityName */
    #CRYPT_CERTINFO_ORGANIZATIONNAME                  = 2103 ; /* organizationName */
    #CRYPT_CERTINFO_ORGANISATIONNAME                  = #CRYPT_CERTINFO_ORGANIZATIONNAME
    #CRYPT_CERTINFO_ORGANIZATIONALUNITNAME            = 2104 ; /* organizationalUnitName */
    #CRYPT_CERTINFO_ORGANISATIONALUNITNAME            = #CRYPT_CERTINFO_ORGANIZATIONALUNITNAME
    #CRYPT_CERTINFO_COMMONNAME                        = 2105 ; /* commonName */


    ; X.509 General Name components.  These are handled in the same way as
    ; the DN composite field, with the current GeneralName being selected by
    ; a pseudo-component after which the individual components can be
    ; modified through one OF the following */
    #CRYPT_CERTINFO_OTHERNAME_TYPEID                      = 2106 ; /* otherName.typeID */
    #CRYPT_CERTINFO_OTHERNAME_VALUE                        = 2107 ; /* otherName.value */
    #CRYPT_CERTINFO_RFC822NAME                                = 2108 ; /* rfc822Name */
    #CRYPT_CERTINFO_EMAIL                             = #CRYPT_CERTINFO_RFC822NAME
    #CRYPT_CERTINFO_DNSNAME                                      = 2109 ; /* dNSName */  
                                                    
    #CRYPT_CERTINFO_DIRECTORYNAME                            = 2110 ; /* directoryName */
    #CRYPT_CERTINFO_EDIPARTYNAME_NAMEASSIGNER            = 2111 ; /* ediPartyName.nameAssigner */
    #CRYPT_CERTINFO_EDIPARTYNAME_PARTYNAME              = 2112 ; /* ediPartyName.partyName */
    #CRYPT_CERTINFO_UNIFORMRESOURCEIDENTIFIER           = 2113 ; /* uniformResourceIdentifier */
    #CRYPT_CERTINFO_IPADDRESS                                  = 2114 ; /* iPAddress */
    #CRYPT_CERTINFO_REGISTEREDID                            = 2115 ; /* registeredID */


    ; X.509 certificate extensions.  Although it would be nicer to use names
    ; that match the extensions more closely (e.g.
    ; CRYPT_CERTINFO_BASICCONSTRAINTS_PATHLENCONSTRAINT), these exceed the
    ; 32-character ANSI minimum length for unique names, and get really
    ; hairy once you get into the weird policy constraints extensions whose
    ; names wrap around the screen about three times.
  ;
    ; The following values are defined in OID order, this isn;t absolutely
    ; necessary but saves an extra layer OF processing when encoding them */

; 1 2 840 113549 1 9 7 challengePassword.  This is here even though it;s
; a CMS attribute because SCEP stuffs it into PKCS #10 requests */
    #CRYPT_CERTINFO_CHALLENGEPASSWORD                 = 200 + 2000 ; #CRYPT_CERTINFO_FIRST 
                                                    
; /* 1 3 6 1 4 1 3029 3 1 4 cRLExtReason */         
    #CRYPT_CERTINFO_CRLEXTREASON                      = 2201 
                                                        
; /* 1 3 6 1 4 1 3029 3 1 5 keyFeatures */          
    #CRYPT_CERTINFO_KEYFEATURES                       = 2202 
                                                    
; /* 1 3 6 1 5 5 7 1 1 authorityInfoAccess */       
    #CRYPT_CERTINFO_AUTHORITYINFOACCESS               = 2203 ;
    #CRYPT_CERTINFO_AUTHORITYINFO_RTCS                    = 2204 ; /* accessDescription.accessLocation */
    #CRYPT_CERTINFO_AUTHORITYINFO_OCSP                    = 2205 ; /* accessDescription.accessLocation */
    #CRYPT_CERTINFO_AUTHORITYINFO_CAISSUERS              = 2206 ; /* accessDescription.accessLocation */
    #CRYPT_CERTINFO_AUTHORITYINFO_CERTSTORE              = 2207 ; /* accessDescription.accessLocation */
    #CRYPT_CERTINFO_AUTHORITYINFO_CRLS                    = 2208 ; /* accessDescription.accessLocation */
                                                    
; /* 1 3 6 1 5 5 7 1 2 biometricInfo */             
    #CRYPT_CERTINFO_BIOMETRICINFO                     = 2209 ;
    #CRYPT_CERTINFO_BIOMETRICINFO_TYPE                    = 2210 ; /* biometricData.typeOfData */
    #CRYPT_CERTINFO_BIOMETRICINFO_HASHALGO              = 2211 ; /* biometricData.hashAlgorithm */
    #CRYPT_CERTINFO_BIOMETRICINFO_HASH                    = 2212 ; /* biometricData.dataHash */
    #CRYPT_CERTINFO_BIOMETRICINFO_URL                      = 2213 ; /* biometricData.sourceDataUri */
                                                    
; /* 1 3 6 1 5 5 7 1 3 qcStatements */              
    #CRYPT_CERTINFO_QCSTATEMENT                       = 2214
    #CRYPT_CERTINFO_QCSTATEMENT_SEMANTICS             = 2215

; /* qcStatement.statementInfo.semanticsIdentifier */
    #CRYPT_CERTINFO_QCSTATEMENT_REGISTRATIONAUTHORITY = 2216
; /* qcStatement.statementInfo.nameRegistrationAuthorities */

;    /* 1 3 6 1 5 5 7 48 1 2 ocspNonce */
    #CRYPT_CERTINFO_OCSP_NONCE                              = 2217 ;    /* nonce */

;    /* 1 3 6 1 5 5 7 48 1 4 ocspAcceptableResponses */
    #CRYPT_CERTINFO_OCSP_RESPONSE                     = 2218 ; 
    #CRYPT_CERTINFO_OCSP_RESPONSE_OCSP                    = 2219 ; /* OCSP standard response */
                                                    
;    /* 1 3 6 1 5 5 7 48 1 5 ocspNoCheck */            
    #CRYPT_CERTINFO_OCSP_NOCHECK                      = 2220
                                                    
;    /* 1 3 6 1 5 5 7 48 1 6 ocspArchiveCutoff */      
    #CRYPT_CERTINFO_OCSP_ARCHIVECUTOFF                = 2221
                                                    
;    /* 1 3 6 1 5 5 7 48 1 11 subjectInfoAccess */     
    #CRYPT_CERTINFO_SUBJECTINFOACCESS                 = 2222 
    #CRYPT_CERTINFO_SUBJECTINFO_CAREPOSITORY          = 2223 ; /* accessDescription.accessLocation */
    #CRYPT_CERTINFO_SUBJECTINFO_TIMESTAMPING          = 2224 ; /* accessDescription.accessLocation */
                                                    
;    /* 1 3 36 8 3 1 siggDateOfCertGen */              
    #CRYPT_CERTINFO_SIGG_DATEOFCERTGEN                = 2225 ;
                                                    
;    /* 1 3 36 8 3 2 siggProcuration */                
    #CRYPT_CERTINFO_SIGG_PROCURATION                  = 2226 ;
    #CRYPT_CERTINFO_SIGG_PROCURE_COUNTRY                = 2227 ; /* country */
    #CRYPT_CERTINFO_SIGG_PROCURE_TYPEOFSUBSTITUTION      = 2228 ; /* typeOfSubstitution */
    #CRYPT_CERTINFO_SIGG_PROCURE_SIGNINGFOR              = 2229 ; /* signingFor.thirdPerson */

;    /* 1 3 36 8 3 4 siggMonetaryLimit */
    #CRYPT_CERTINFO_SIGG_MONETARYLIMIT                = 2230
    #CRYPT_CERTINFO_SIGG_MONETARY_CURRENCY              = 2231 ; /* CURRENCY */
    #CRYPT_CERTINFO_SIGG_MONETARY_AMOUNT                = 2232 ; /* amount */
    #CRYPT_CERTINFO_SIGG_MONETARY_EXPONENT              = 2233 ; /* exponent */

;    /* 1 3 36 8 3 8 siggRestriction */
    #CRYPT_CERTINFO_SIGG_RESTRICTION                  = 2234

;    /* 1 3 101 1 4 1 strongExtranet */
    #CRYPT_CERTINFO_STRONGEXTRANET                    = 2235 ; 
    #CRYPT_CERTINFO_STRONGEXTRANET_ZONE                    = 2236 ; /* sxNetIDList.sxNetID.zone */
    #CRYPT_CERTINFO_STRONGEXTRANET_ID                      = 2237 ; /* sxNetIDList.sxNetID.id */

;    /* 2 5 29 9 subjectDirectoryAttributes */
    #CRYPT_CERTINFO_SUBJECTDIRECTORYATTRIBUTES        = 2238 ; 
    #CRYPT_CERTINFO_SUBJECTDIR_TYPE                          = 2239 ; /* attribute.TYPE */
    #CRYPT_CERTINFO_SUBJECTDIR_VALUES                      = 2240 ; /* attribute.values */

;    /* 2 5 29 14 subjectKeyIdentifier */
    #CRYPT_CERTINFO_SUBJECTKEYIDENTIFIER              = 2241

;    /* 2 5 29 15 keyUsage */
    #CRYPT_CERTINFO_KEYUSAGE                          = 2242

;    /* 2 5 29 16 privateKeyUsagePeriod */
    #CRYPT_CERTINFO_PRIVATEKEYUSAGEPERIOD             = 2243 ; 
    #CRYPT_CERTINFO_PRIVATEKEY_NOTBEFORE                = 2244 ; /* notBefore */
    #CRYPT_CERTINFO_PRIVATEKEY_NOTAFTER                    = 2245 ; /* notAfter */

;    /* 2 5 29 17 subjectAltName */
    #CRYPT_CERTINFO_SUBJECTALTNAME                    = 2246 ;
                                                    
;    /* 2 5 29 18 issuerAltName */                     
    #CRYPT_CERTINFO_ISSUERALTNAME                     = 2247 ;
                                                    
;    /* 2 5 29 19 basicConstraints */                  
    #CRYPT_CERTINFO_BASICCONSTRAINTS                  = 2248 ;
    #CRYPT_CERTINFO_CA                                          = 2249 ; /* cA */
    #CRYPT_CERTINFO_AUTHORITY                         = #CRYPT_CERTINFO_CA
    #CRYPT_CERTINFO_PATHLENCONSTRAINT                      = 2250 ; /* pathLenConstraint */

;    /* 2 5 29 20 cRLNumber */
    #CRYPT_CERTINFO_CRLNUMBER                         = 2251 ;
                                                    
;    /* 2 5 29 21 cRLReason */                         
    #CRYPT_CERTINFO_CRLREASON                         = 2252 ;
                                                    
;    /* 2 5 29 23 holdInstructionCode */               
    #CRYPT_CERTINFO_HOLDINSTRUCTIONCODE               = 2253 ;
                                                    
;    /* 2 5 29 24 invalidityDate */                    
    #CRYPT_CERTINFO_INVALIDITYDATE                    = 2254 ;
                                                    
;    /* 2 5 29 27 deltaCRLIndicator */                 
    #CRYPT_CERTINFO_DELTACRLINDICATOR                 = 2255 ;
                                                    
;    /* 2 5 29 28 issuingDistributionPoint */          
    #CRYPT_CERTINFO_ISSUINGDISTRIBUTIONPOINT          = 2256 ;
    #CRYPT_CERTINFO_ISSUINGDIST_FULLNAME              = 2257 ; /* distributionPointName.fullName */
    #CRYPT_CERTINFO_ISSUINGDIST_USERCERTSONLY            = 2258 ; /* onlyContainsUserCerts */
    #CRYPT_CERTINFO_ISSUINGDIST_CACERTSONLY              = 2259 ; /* onlyContainsCACerts */
    #CRYPT_CERTINFO_ISSUINGDIST_SOMEREASONSONLY          = 2260 ; /* onlySomeReasons */
    #CRYPT_CERTINFO_ISSUINGDIST_INDIRECTCRL              = 2261 ; /* indirectCRL */

;    /* 2 5 29 29 certificateIssuer */
    #CRYPT_CERTINFO_CERTIFICATEISSUER                 = 2262 ;

;    /* 2 5 29 30 nameConstraints */
    #CRYPT_CERTINFO_NAMECONSTRAINTS                   = 2263 ; 
    #CRYPT_CERTINFO_PERMITTEDSUBTREES                 = 2264 ; /* permittedSubtrees */
    #CRYPT_CERTINFO_EXCLUDEDSUBTREES                  = 2265 ; /* excludedSubtrees */
                                                    
;    /* 2 5 29 31 cRLDistributionPoint */              
    #CRYPT_CERTINFO_CRLDISTRIBUTIONPOINT              = 2266 ; 
    #CRYPT_CERTINFO_CRLDIST_FULLNAME                     = 2267 ; /* distributionPointName.fullName */
    #CRYPT_CERTINFO_CRLDIST_REASONS                     = 2268 ; /* reasons */
    #CRYPT_CERTINFO_CRLDIST_CRLISSUER                 = 2269 ; /* cRLIssuer */

;    /* 2 5 29 32 certificatePolicies */
    #CRYPT_CERTINFO_CERTIFICATEPOLICIES               = 2270 ; 
    #CRYPT_CERTINFO_CERTPOLICYID                        = 2271 ; /* policyInformation.policyIdentifier */
    #CRYPT_CERTINFO_CERTPOLICY_CPSURI                 = 2272 ; 

;    /* policyInformation.policyQualifiers.qualifier.cPSuri */
    #CRYPT_CERTINFO_CERTPOLICY_ORGANIZATION           = 2273 ;

;    /* policyInformation.policyQualifiers.qualifier.userNotice.noticeRef.organization */
    #CRYPT_CERTINFO_CERTPOLICY_NOTICENUMBERS          = 2274 ;

; /* policyInformation.policyQualifiers.qualifier.userNotice.noticeRef.noticeNumbers */
    #CRYPT_CERTINFO_CERTPOLICY_EXPLICITTEXT           = 2275 ;

; /* policyInformation.policyQualifiers.qualifier.userNotice.explicitText */
; /* 2 5 29 33 policyMappings */
    #CRYPT_CERTINFO_POLICYMAPPINGS                    = 2276 ; 
    #CRYPT_CERTINFO_ISSUERDOMAINPOLICY                  = 2277 ; /* policyMappings.issuerDomainPolicy */
    #CRYPT_CERTINFO_SUBJECTDOMAINPOLICY                  = 2278 ; /* policyMappings.subjectDomainPolicy */

;    /* 2 5 29 35 authorityKeyIdentifier */
    #CRYPT_CERTINFO_AUTHORITYKEYIDENTIFIER            = 2279 ; 
    #CRYPT_CERTINFO_AUTHORITY_KEYIDENTIFIER              = 2280 ; /* keyIdentifier */
    #CRYPT_CERTINFO_AUTHORITY_CERTISSUER                = 2281 ; /* authorityCertIssuer */
    #CRYPT_CERTINFO_AUTHORITY_CERTSERIALNUMBER          = 2282 ; /* authorityCertSerialNumber */

;    /* 2 5 29 36 policyConstraints */
    #CRYPT_CERTINFO_POLICYCONSTRAINTS                 = 2283 ; 
    #CRYPT_CERTINFO_REQUIREEXPLICITPOLICY             = 2284 ; /* policyConstraints.requireExplicitPolicy */
    #CRYPT_CERTINFO_INHIBITPOLICYMAPPING              = 2285 ; /* policyConstraints.inhibitPolicyMapping */

;    /* 2 5 29 37 extKeyUsage */
    #CRYPT_CERTINFO_EXTKEYUSAGE                       = 2286 ;
    #CRYPT_CERTINFO_EXTKEY_MS_INDIVIDUALCODESIGNING      = 2287 ; /* individualCodeSigning */
    #CRYPT_CERTINFO_EXTKEY_MS_COMMERCIALCODESIGNING      = 2288 ; /* commercialCodeSigning */
    #CRYPT_CERTINFO_EXTKEY_MS_CERTTRUSTLISTSIGNING      = 2289 ; /* certTrustListSigning */
    #CRYPT_CERTINFO_EXTKEY_MS_TIMESTAMPSIGNING          = 2290 ; /* timeStampSigning */
    #CRYPT_CERTINFO_EXTKEY_MS_SERVERGATEDCRYPTO          = 2291 ; /* serverGatedCrypto */
    #CRYPT_CERTINFO_EXTKEY_MS_ENCRYPTEDFILESYSTEM     = 2292 ; /* encrypedFileSystem */
    #CRYPT_CERTINFO_EXTKEY_SERVERAUTH                 = 2293 ; /* serverAuth */
    #CRYPT_CERTINFO_EXTKEY_CLIENTAUTH                    = 2294 ; /* clientAuth */
    #CRYPT_CERTINFO_EXTKEY_CODESIGNING                  = 2295 ; /* codeSigning */
    #CRYPT_CERTINFO_EXTKEY_EMAILPROTECTION              = 2296 ; /* emailProtection */
    #CRYPT_CERTINFO_EXTKEY_IPSECENDSYSTEM                = 2297 ; /* ipsecEndSystem */
    #CRYPT_CERTINFO_EXTKEY_IPSECTUNNEL                    = 2298 ; /* ipsecTunnel */
    #CRYPT_CERTINFO_EXTKEY_IPSECUSER                      = 2299 ; /* ipsecUser */
    #CRYPT_CERTINFO_EXTKEY_TIMESTAMPING                  = 2300 ; /* timeStamping */
    #CRYPT_CERTINFO_EXTKEY_OCSPSIGNING                    = 2301 ; /* ocspSigning */
    #CRYPT_CERTINFO_EXTKEY_DIRECTORYSERVICE              = 2302 ; /* directoryService */
    #CRYPT_CERTINFO_EXTKEY_ANYKEYUSAGE                  = 2303 ; /* anyExtendedKeyUsage */
    #CRYPT_CERTINFO_EXTKEY_NS_SERVERGATEDCRYPTO         = 2304 ; /* serverGatedCrypto */
    #CRYPT_CERTINFO_EXTKEY_VS_SERVERGATEDCRYPTO_CA      = 2305 ; /* serverGatedCrypto CA */

;    /* 2 5 29 46 freshestCRL */
    #CRYPT_CERTINFO_FRESHESTCRL                       = 2306 ; 
    #CRYPT_CERTINFO_FRESHESTCRL_FULLNAME                = 2307 ; /* distributionPointName.fullName */
    #CRYPT_CERTINFO_FRESHESTCRL_REASONS                    = 2308 ; /* reasons */
    #CRYPT_CERTINFO_FRESHESTCRL_CRLISSUER                = 2309 ; /* cRLIssuer */

;    /* 2 5 29 54 inhibitAnyPolicy */
    #CRYPT_CERTINFO_INHIBITANYPOLICY                  = 2310 ; 

;    /* 2 16 840 1 113730 1 x Netscape extensions */
    #CRYPT_CERTINFO_NS_CERTTYPE                              = 2311 ; /* netscape-cert-TYPE */
    #CRYPT_CERTINFO_NS_BASEURL                                = 2312 ; /* netscape-BASE-url */
    #CRYPT_CERTINFO_NS_REVOCATIONURL                      = 2313 ; /* netscape-revocation-url */
    #CRYPT_CERTINFO_NS_CAREVOCATIONURL                  = 2314 ; /* netscape-ca-revocation-url */
    #CRYPT_CERTINFO_NS_CERTRENEWALURL                    = 2315 ; /* netscape-cert-renewal-url */
    #CRYPT_CERTINFO_NS_CAPOLICYURL                          = 2316 ; /* netscape-ca-policy-url */
    #CRYPT_CERTINFO_NS_SSLSERVERNAME                      = 2317 ; /* netscape-ssl-SERVER-NAME */
    #CRYPT_CERTINFO_NS_COMMENT                                = 2318 ; /* netscape-comment */

;    /* 2 23 42 7 0 SET hashedRootKey */
    #CRYPT_CERTINFO_SET_HASHEDROOTKEY                 = 2319 ;
    #CRYPT_CERTINFO_SET_ROOTKEYTHUMBPRINT                = 2320 ; /* rootKeyThumbPrint */

;    /* 2 23 42 7 1 SET certificateType */
    #CRYPT_CERTINFO_SET_CERTIFICATETYPE               = 2321 ;

;    /* 2 23 42 7 2 SET merchantData */
    #CRYPT_CERTINFO_SET_MERCHANTDATA                  = 2322 ;
    #CRYPT_CERTINFO_SET_MERID                                = 2323 ; /* merID */
    #CRYPT_CERTINFO_SET_MERACQUIRERBIN                    = 2324 ; /* merAcquirerBIN */
    #CRYPT_CERTINFO_SET_MERCHANTLANGUAGE                = 2325 ; /* merNames.language */
    #CRYPT_CERTINFO_SET_MERCHANTNAME                      = 2326 ; /* merNames.NAME */
    #CRYPT_CERTINFO_SET_MERCHANTCITY                      = 2327 ; /* merNames.city */
    #CRYPT_CERTINFO_SET_MERCHANTSTATEPROVINCE         = 2328 ; /* merNames.stateProvince */
    #CRYPT_CERTINFO_SET_MERCHANTPOSTALCODE              = 2329 ; /* merNames.postalCode */
    #CRYPT_CERTINFO_SET_MERCHANTCOUNTRYNAME              = 2330 ; /* merNames.countryName */
    #CRYPT_CERTINFO_SET_MERCOUNTRY                        = 2331 ; /* merCountry */
    #CRYPT_CERTINFO_SET_MERAUTHFLAG                        = 2332 ; /* merAuthFlag */

;    /* 2 23 42 7 3 SET certCardRequired */
    #CRYPT_CERTINFO_SET_CERTCARDREQUIRED              = 2333
                                                    
;    /* 2 23 42 7 4 SET tunneling */                   
    #CRYPT_CERTINFO_SET_TUNNELING                     = 2334 ; 
    #CRYPT_CERTINFO_SET_TUNNELLING                    = #CRYPT_CERTINFO_SET_TUNNELING
    #CRYPT_CERTINFO_SET_TUNNELINGFLAG                    = 2335 ; /* tunneling */
    #CRYPT_CERTINFO_SET_TUNNELLINGFLAG                = #CRYPT_CERTINFO_SET_TUNNELINGFLAG
    #CRYPT_CERTINFO_SET_TUNNELINGALGID                  = 2336 ; /* tunnelingAlgID */
    #CRYPT_CERTINFO_SET_TUNNELLINGALGID               = #CRYPT_CERTINFO_SET_TUNNELINGALGID
           

;    /* S/MIME attributes */
;    /* 1 2 840 113549 1 9 3 contentType */
    #CRYPT_CERTINFO_CMS_CONTENTTYPE                   = 500 + 2000 ; #CRYPT_CERTINFO_FIRST 
                                                    
;    /* 1 2 840 113549 1 9 4 messageDigest */          
    #CRYPT_CERTINFO_CMS_MESSAGEDIGEST                 = 2501
                                                    
;    /* 1 2 840 113549 1 9 5 signingTime */            
    #CRYPT_CERTINFO_CMS_SIGNINGTIME                   = 2502
                                                    
;    /* 1 2 840 113549 1 9 6 counterSignature */       
    #CRYPT_CERTINFO_CMS_COUNTERSIGNATURE                = 2503 ; /* counterSignature */
                                                    
;    /* 1 2 840 113549 1 9 13 signingDescription */    
    #CRYPT_CERTINFO_CMS_SIGNINGDESCRIPTION            = 2504

;    /* 1 2 840 113549 1 9 15 sMIMECapabilities */
    #CRYPT_CERTINFO_CMS_SMIMECAPABILITIES             = 2505 ;
    #CRYPT_CERTINFO_CMS_SMIMECAP_3DES                      = 2506 ; /* 3DES encryption */
    #CRYPT_CERTINFO_CMS_SMIMECAP_AES                      = 2507 ; /* AES encryption */
    #CRYPT_CERTINFO_CMS_SMIMECAP_CAST128                = 2508 ; /* CAST-128 encryption */
    #CRYPT_CERTINFO_CMS_SMIMECAP_IDEA                      = 2509 ; /* IDEA encryption */
    #CRYPT_CERTINFO_CMS_SMIMECAP_RC2                      = 2510 ; /* RC2 encryption (w.128 key) */
    #CRYPT_CERTINFO_CMS_SMIMECAP_RC5                      = 2511 ; /* RC5 encryption (w.128 key) */
    #CRYPT_CERTINFO_CMS_SMIMECAP_SKIPJACK                = 2512 ; /* Skipjack encryption */
    #CRYPT_CERTINFO_CMS_SMIMECAP_DES                    = 2513 ; /* DES encryption */
    #CRYPT_CERTINFO_CMS_SMIMECAP_PREFERSIGNEDDATA        = 2514 ; /* preferSignedData */
    #CRYPT_CERTINFO_CMS_SMIMECAP_CANNOTDECRYPTANY        = 2515 ; /* canNotDecryptAny */

;    /* 1 2 840 113549 1 9 16 2 1 receiptRequest */
    #CRYPT_CERTINFO_CMS_RECEIPTREQUEST                = 2516 ; 
    #CRYPT_CERTINFO_CMS_RECEIPT_CONTENTIDENTIFIER     = 2517 ; /* contentIdentifier */
    #CRYPT_CERTINFO_CMS_RECEIPT_FROM                      = 2518 ; /* receiptsFrom */
    #CRYPT_CERTINFO_CMS_RECEIPT_TO                          = 2519 ; /* receiptsTo */

;    /* 1 2 840 113549 1 9 16 2 2 essSecurityLabel */
    #CRYPT_CERTINFO_CMS_SECURITYLABEL                 = 2520 ; 
    #CRYPT_CERTINFO_CMS_SECLABEL_POLICY                    = 2521 ; /* securityPolicyIdentifier */
    #CRYPT_CERTINFO_CMS_SECLABEL_CLASSIFICATION       = 2522 ; /* securityClassification */
    #CRYPT_CERTINFO_CMS_SECLABEL_PRIVACYMARK          = 2523 ; /* privacyMark */
    #CRYPT_CERTINFO_CMS_SECLABEL_CATTYPE                = 2524 ; /* securityCategories.securityCategory.TYPE */
    #CRYPT_CERTINFO_CMS_SECLABEL_CATVALUE                = 2525 ; /* securityCategories.securityCategory.value */

;    /* 1 2 840 113549 1 9 16 2 3 mlExpansionHistory */
    #CRYPT_CERTINFO_CMS_MLEXPANSIONHISTORY            = 2526 ;
    #CRYPT_CERTINFO_CMS_MLEXP_ENTITYIDENTIFIER        = 2527 ; /* mlData.mailListIdentifier.issuerAndSerialNumber */
    #CRYPT_CERTINFO_CMS_MLEXP_TIME                          = 2528 ; /* mlData.expansionTime */
    #CRYPT_CERTINFO_CMS_MLEXP_NONE                          = 2529 ; /* mlData.mlReceiptPolicy.NONE */
    #CRYPT_CERTINFO_CMS_MLEXP_INSTEADOF                  = 2530 ; /* mlData.mlReceiptPolicy.insteadOf.generalNames.generalName */
    #CRYPT_CERTINFO_CMS_MLEXP_INADDITIONTO               = 2531 ; /* mlData.mlReceiptPolicy.inAdditionTo.generalNames.generalName */

;    /* 1 2 840 113549 1 9 16 2 4 contentHints */
    #CRYPT_CERTINFO_CMS_CONTENTHINTS                  = 2532 ;
    #CRYPT_CERTINFO_CMS_CONTENTHINT_DESCRIPTION          = 2533 ; /* contentDescription */
    #CRYPT_CERTINFO_CMS_CONTENTHINT_TYPE                = 2534 ; /* contentType */

;    /* 1 2 840 113549 1 9 16 2 9 equivalentLabels */
    #CRYPT_CERTINFO_CMS_EQUIVALENTLABEL               = 2535 ; 
    #CRYPT_CERTINFO_CMS_EQVLABEL_POLICY                    = 2536 ; /* securityPolicyIdentifier */
    #CRYPT_CERTINFO_CMS_EQVLABEL_CLASSIFICATION       = 2537 ; /* securityClassification */
    #CRYPT_CERTINFO_CMS_EQVLABEL_PRIVACYMARK          = 2538 ; /* privacyMark */
    #CRYPT_CERTINFO_CMS_EQVLABEL_CATTYPE              = 2539 ; /* securityCategories.securityCategory.TYPE */
    #CRYPT_CERTINFO_CMS_EQVLABEL_CATVALUE             = 2540 ; /* securityCategories.securityCategory.value */

;    /* 1 2 840 113549 1 9 16 2 12 signingCertificate */
    #CRYPT_CERTINFO_CMS_SIGNINGCERTIFICATE            = 2541 ; 
    #CRYPT_CERTINFO_CMS_SIGNINGCERT_ESSCERTID         = 2542 ; /* certs.essCertID */
    #CRYPT_CERTINFO_CMS_SIGNINGCERT_POLICIES          = 2543 ; /* policies.policyInformation.policyIdentifier */

;    /* 1 2 840 113549 1 9 16 2 15 signaturePolicyID */
    #CRYPT_CERTINFO_CMS_SIGNATUREPOLICYID             = 2544 ; 
    #CRYPT_CERTINFO_CMS_SIGPOLICYID                        = 2545 ; /* sigPolicyID */
    #CRYPT_CERTINFO_CMS_SIGPOLICYHASH                    = 2546 ; /* sigPolicyHash */
    #CRYPT_CERTINFO_CMS_SIGPOLICY_CPSURI                = 2547 ; /* sigPolicyQualifiers.sigPolicyQualifier.cPSuri */
    #CRYPT_CERTINFO_CMS_SIGPOLICY_ORGANIZATION        = 2548 ;

; /* sigPolicyQualifiers.sigPolicyQualifier.userNotice.noticeRef.organization */
    #CRYPT_CERTINFO_CMS_SIGPOLICY_NOTICENUMBERS       = 2549

; /* sigPolicyQualifiers.sigPolicyQualifier.userNotice.noticeRef.noticeNumbers */
    #CRYPT_CERTINFO_CMS_SIGPOLICY_EXPLICITTEXT        = 2550

; /* sigPolicyQualifiers.sigPolicyQualifier.userNotice.explicitText */
;    /* 1 2 840 113549 1 9 16 9 signatureTypeIdentifier */
    #CRYPT_CERTINFO_CMS_SIGTYPEIDENTIFIER             = 2551 ;
    #CRYPT_CERTINFO_CMS_SIGTYPEID_ORIGINATORSIG       = 2552 ; /* originatorSig */
    #CRYPT_CERTINFO_CMS_SIGTYPEID_DOMAINSIG              = 2553 ; /* domainSig */
    #CRYPT_CERTINFO_CMS_SIGTYPEID_ADDITIONALATTRIBUTES= 2554 ; /* additionalAttributesSig */
    #CRYPT_CERTINFO_CMS_SIGTYPEID_REVIEWSIG              = 2555 ; /* reviewSig */

;    /* 1 2 840 113549 1 9 25 3 randomNonce */
    #CRYPT_CERTINFO_CMS_NONCE                                = 2556 ; /* randomNonce */

; SCEP attributes:
;    2 16 840 1 113733 1 9 2 messageType
;    2 16 840 1 113733 1 9 3 pkiStatus
;    2 16 840 1 113733 1 9 4 failInfo
;    2 16 840 1 113733 1 9 5 senderNonce
;    2 16 840 1 113733 1 9 6 recipientNonce
;    2 16 840 1 113733 1 9 7 transID 
    #CRYPT_CERTINFO_SCEP_MESSAGETYPE                      = 2557 ; /* messageType */
    #CRYPT_CERTINFO_SCEP_PKISTATUS                          = 2558 ; /* pkiStatus */
    #CRYPT_CERTINFO_SCEP_FAILINFO                            = 2559 ; /* failInfo */
    #CRYPT_CERTINFO_SCEP_SENDERNONCE                      = 2560 ; /* senderNonce */
    #CRYPT_CERTINFO_SCEP_RECIPIENTNONCE                  = 2561 ; /* recipientNonce */
    #CRYPT_CERTINFO_SCEP_TRANSACTIONID                    = 2562 ; /* transID */

;    /* 1 3 6 1 4 1 311 2 1 10 spcAgencyInfo */
    #CRYPT_CERTINFO_CMS_SPCAGENCYINFO                 = 2563 ; 
    #CRYPT_CERTINFO_CMS_SPCAGENCYURL                      = 2564 ; /* spcAgencyInfo.url */

;    /* 1 3 6 1 4 1 311 2 1 11 spcStatementType */
    #CRYPT_CERTINFO_CMS_SPCSTATEMENTTYPE              = 2565 ; 
    #CRYPT_CERTINFO_CMS_SPCSTMT_INDIVIDUALCODESIGNING    = 2566 ; /* individualCodeSigning */
    #CRYPT_CERTINFO_CMS_SPCSTMT_COMMERCIALCODESIGNING    = 2567 ; /* commercialCodeSigning */

;    /* 1 3 6 1 4 1 311 2 1 12 spcOpusInfo */
    #CRYPT_CERTINFO_CMS_SPCOPUSINFO                   = 2568 ; 
    #CRYPT_CERTINFO_CMS_SPCOPUSINFO_NAME                = 2569 ; /* spcOpusInfo.NAME */
    #CRYPT_CERTINFO_CMS_SPCOPUSINFO_URL                    = 2570 ; /* spcOpusInfo.url */

    #CRYPT_CERTINFO_LAST                              = 2571 ;    /* Used internally */

    

;    /*********************/
;    /* Keyset attributes */
;    /*********************/ 
  #CRYPT_KEYINFO_FIRST                              = 3000   
    #CRYPT_KEYINFO_QUERY                                    = 3001 ; /* Keyset query */
    #CRYPT_KEYINFO_QUERY_REQUESTS                        = 3002 ; /* Query OF requests IN cert store */
    #CRYPT_KEYINFO_LAST                               = 3003 ; /* Used internally */


;    /*********************/
;    /* Device attributes */
;    /*********************/  
  #CRYPT_DEVINFO_FIRST                              = 4000
    #CRYPT_DEVINFO_INITIALISE                            = 4001 ; /* Initialise device FOR use */
    #CRYPT_DEVINFO_INITIALIZE                         = #CRYPT_DEVINFO_INITIALISE
    #CRYPT_DEVINFO_AUTHENT_USER                         = 4002 ; /* Authenticate user TO device */
    #CRYPT_DEVINFO_AUTHENT_SUPERVISOR                    = 4003 ; /* Authenticate supervisor TO dev.*/
    #CRYPT_DEVINFO_SET_AUTHENT_USER                      = 4004 ; /* SET user authent.value */
    #CRYPT_DEVINFO_SET_AUTHENT_SUPERVISOR                = 4005 ; /* SET supervisor auth.VAL.*/
    #CRYPT_DEVINFO_ZEROISE                              = 4006 ; /* Zeroise device */
    #CRYPT_DEVINFO_ZEROIZE                            = #CRYPT_DEVINFO_ZEROISE
    #CRYPT_DEVINFO_LOGGEDIN                                = 4007 ; /* Whether user is logged IN */
    #CRYPT_DEVINFO_LABEL                                  = 4008 ; /* Device/token LABEL */
    #CRYPT_DEVINFO_LAST                               = 4009 ; /* Used internally */


;    /***********************/
;    /* Envelope attributes */
;    /***********************/
  #CRYPT_ENVINFO_FIRST                              = 5000

; Pseudo-information ON an envelope OR meta-information which is used TO
; CONTROL the way that DATA IN an envelope is processed */
    #CRYPT_ENVINFO_DATASIZE                                  = 5001 ; /* DATA SIZE information */
    #CRYPT_ENVINFO_COMPRESSION                            = 5002 ; /* Compression information */
    #CRYPT_ENVINFO_CONTENTTYPE                            = 5003 ; /* Inner CMS content TYPE */
    #CRYPT_ENVINFO_DETACHEDSIGNATURE                  = 5004 ; /* Detached signature */
    #CRYPT_ENVINFO_SIGNATURE_RESULT                      = 5005 ; /* Signature CHECK result */
    #CRYPT_ENVINFO_INTEGRITY                              = 5006 ; /* Integrity-protection level */

; /* Resources required FOR enveloping/deenveloping */
    #CRYPT_ENVINFO_PASSWORD                                  = 5007 ; /* User password */
    #CRYPT_ENVINFO_KEY                                        = 5008 ; /* Conventional encryption key */
    #CRYPT_ENVINFO_SIGNATURE                              = 5009 ; /* Signature/signature CHECK key */
    #CRYPT_ENVINFO_SIGNATURE_EXTRADATA                  = 5010 ; /* Extra information added TO CMS sigs */
    #CRYPT_ENVINFO_RECIPIENT                              = 5011 ; /* Recipient email address */
    #CRYPT_ENVINFO_PUBLICKEY                              = 5012 ; /* PKC encryption key */
    #CRYPT_ENVINFO_PRIVATEKEY                              = 5013 ; /* PKC decryption key */
    #CRYPT_ENVINFO_PRIVATEKEY_LABEL                      = 5014 ; /* LABEL OF PKC decryption key */
    #CRYPT_ENVINFO_ORIGINATOR                              = 5015 ; /* Originator info/key */
    #CRYPT_ENVINFO_SESSIONKEY                              = 5016 ; /* Session key */
    #CRYPT_ENVINFO_HASH                                        = 5017 ; /* Hash value */
    #CRYPT_ENVINFO_TIMESTAMP                              = 5018 ; /* Timestamp information */

;    /* Keysets used TO retrieve keys needed FOR enveloping/de enveloping */
    #CRYPT_ENVINFO_KEYSET_SIGCHECK                      = 5019 ; /* Signature CHECK keyset */
    #CRYPT_ENVINFO_KEYSET_ENCRYPT                        = 5020 ; /* PKC encryption keyset */
    #CRYPT_ENVINFO_KEYSET_DECRYPT                        = 5021 ; /* PKC decryption keyset */ 

    #CRYPT_ENVINFO_LAST                               = 5022 ;/* Used internally */


;    /**********************/
;    /* Session attributes */
;    /**********************/
  #CRYPT_SESSINFO_FIRST                             = 6000 ; /* Used internally */

; /* Pseudo-information about the session */
    #CRYPT_SESSINFO_ACTIVE                                  = 6001 ; /* Whether session is active */
    #CRYPT_SESSINFO_CONNECTIONACTIVE                  = 6002 ; /* Whether network connection is active */

; /* Security-related information */
    #CRYPT_SESSINFO_USERNAME                              = 6003 ; /* User NAME */
    #CRYPT_SESSINFO_PASSWORD                              = 6004 ; /* Password */
    #CRYPT_SESSINFO_PRIVATEKEY                            = 6005 ; /* SERVER/CLIENT PRIVATE key */
    #CRYPT_SESSINFO_KEYSET                                  = 6006 ; /* Certificate store */
    #CRYPT_SESSINFO_AUTHRESPONSE                        = 6007 ; /* Session authorisation OK */

; /* CLIENT/SERVER information */
    #CRYPT_SESSINFO_SERVER_NAME                            = 6008 ; /* SERVER NAME */
    #CRYPT_SESSINFO_SERVER_PORT                            = 6009 ; /* SERVER PORT number */
    #CRYPT_SESSINFO_SERVER_FINGERPRINT                = 6010 ; /* SERVER key fingerprint */
    #CRYPT_SESSINFO_CLIENT_NAME                            = 6011 ; /* CLIENT NAME */
    #CRYPT_SESSINFO_CLIENT_PORT                            = 6012 ; /* CLIENT PORT number */
    #CRYPT_SESSINFO_SESSION                                  = 6013 ; /* Transport mechanism */
    #CRYPT_SESSINFO_NETWORKSOCKET                        = 6014 ; /* User-supplied network socket */

; /* Generic protocol-related information */
    #CRYPT_SESSINFO_VERSION                                  = 6015 ; /* Protocol version */
    #CRYPT_SESSINFO_REQUEST                                  = 6016 ; /* Cert.request object */
    #CRYPT_SESSINFO_RESPONSE                              = 6017 ; /* Cert.response object */
    #CRYPT_SESSINFO_CACERTIFICATE                        = 6018 ; /* Issuing CA certificate */

; /* Protocol-specific information */
    #CRYPT_SESSINFO_TSP_MSGIMPRINT                      = 6019 ; /* TSP message imprint */
    #CRYPT_SESSINFO_CMP_REQUESTTYPE                      = 6020 ; /* Request TYPE */
    #CRYPT_SESSINFO_CMP_PKIBOOT                            = 6021 ; /* Unused, TO be removed IN 3.4 */
    #CRYPT_SESSINFO_CMP_PRIVKEYSET                      = 6022 ; /* PRIVATE-key keyset */
    #CRYPT_SESSINFO_SSH_CHANNEL                            = 6023 ; /* SSH current channel */
    #CRYPT_SESSINFO_SSH_CHANNEL_TYPE                  = 6024 ; /* SSH channel TYPE */
    #CRYPT_SESSINFO_SSH_CHANNEL_ARG1                  = 6025 ; /* SSH channel argument 1 */
    #CRYPT_SESSINFO_SSH_CHANNEL_ARG2                  = 6026 ; /* SSH channel argument 2 */
    #CRYPT_SESSINFO_SSH_CHANNEL_ACTIVE                = 6027 ; /* SSH channel active */

    #CRYPT_SESSINFO_LAST                              = 6028 ; /* Used internally */


;    /**********************/
;    /* User attributes */
;    /**********************/
  #CRYPT_USERINFO_FIRST                             = 7000

; /* Security-related information */
    #CRYPT_USERINFO_PASSWORD                              = 7001 ; /* Password */
                                         
; /* User role-related information */              
    #CRYPT_USERINFO_CAKEY_CERTSIGN                      = 7002 ; /* CA cert signing key */
    #CRYPT_USERINFO_CAKEY_CRLSIGN                        = 7003 ; /* CA CRL signing key */
    #CRYPT_USERINFO_CAKEY_RTCSSIGN                      = 7004 ; /* CA RTCS signing key */
    #CRYPT_USERINFO_CAKEY_OCSPSIGN                      = 7005 ; /* CA OCSP signing key */

; /* Used internally for range checking */
    #CRYPT_USERINFO_LAST                              = 7006 

  #CRYPT_ATTRIBUTE_LAST                             = #CRYPT_USERINFO_LAST

;END ENUM CRYPT_ATTRIBUTE_TYPE  
                
                                       


;  /****************************************************************************
;  *                                                                                                                 *
;  *                        Attribute Subtypes & Related Values                                      *
;  *                                                                                                                 *
;  ****************************************************************************/ 

; /* Flags for the X.509 keyUsage extension */                                       
#CRYPT_KEYUSAGE_NONE                                = $0  ; 
#CRYPT_KEYUSAGE_DIGITALSIGNATURE                    = $001  ; 
#CRYPT_KEYUSAGE_NONREPUDIATION                      = $002  ; 
#CRYPT_KEYUSAGE_KEYENCIPHERMENT                     = $004  ; 
#CRYPT_KEYUSAGE_DATAENCIPHERMENT                    = $008  ; 
#CRYPT_KEYUSAGE_KEYAGREEMENT                        = $010  ; 
#CRYPT_KEYUSAGE_KEYCERTSIGN                         = $020  ; 
#CRYPT_KEYUSAGE_CRLSIGN                             = $040  ; 
#CRYPT_KEYUSAGE_ENCIPHERONLY                        = $080  ; 
#CRYPT_KEYUSAGE_DECIPHERONLY                        = $100  ; 
#CRYPT_KEYUSAGE_LAST                                = $200  ; 
                                                    
;ENUM                                               
    #CRYPT_CRLREASON_UNSPECIFIED                      = 00 ; CRYPT_CRLREASON_UNSPECIFIED,                                  
    #CRYPT_CRLREASON_KEYCOMPROMISE                    = 01 ; CRYPT_CRLREASON_KEYCOMPROMISE,                                
    #CRYPT_CRLREASON_CACOMPROMISE                     = 02 ; CRYPT_CRLREASON_CACOMPROMISE,                                 
    #CRYPT_CRLREASON_AFFILIATIONCHANGED               = 03 ; CRYPT_CRLREASON_AFFILIATIONCHANGED,                           
    #CRYPT_CRLREASON_SUPERSEDED                       = 04 ; CRYPT_CRLREASON_SUPERSEDED,                                   
    #CRYPT_CRLREASON_CESSATIONOFOPERATION             = 05 ; CRYPT_CRLREASON_CESSATIONOFOPERATION,                         
    #CRYPT_CRLREASON_CERTIFICATEHOLD                  = 06 ; CRYPT_CRLREASON_CERTIFICATEHOLD,                             
    #CRYPT_CRLREASON_REMOVEFROMCRL                    = 07 ; CRYPT_CRLREASON_REMOVEFROMCRL = 8,
  #CRYPT_CRLREASON_PRIVILEGEWITHDRAWN               = 08 ;                       
  #CRYPT_CRLREASON_AACOMPROMISE                     = 09 ;                       
  #CRYPT_CRLREASON_LAST                             = 10 ; /* END OF standard CRL reasons */   
  #CRYPT_CRLREASON_NEVERVALID                       = 11 ;                      
  #CRYPT_CRLEXTREASON_LAST                          = 20 ;                        
;END ENUM                                                       
                                                                                                                                            


; X.509 CRL reason flags.  These identify the same thing as the cRLReason
; codes but allow for multiple reasons to be specified.  Note that these
; don;t follow the X.509 naming since in that scheme the enumerated types
; & bitflags have the same names */                                                 
#CRYPT_CRLREASONFLAG_UNUSED                         = $001                
#CRYPT_CRLREASONFLAG_KEYCOMPROMISE                  = $002         
#CRYPT_CRLREASONFLAG_CACOMPROMISE                   = $004          
#CRYPT_CRLREASONFLAG_AFFILIATIONCHANGED             = $008    
#CRYPT_CRLREASONFLAG_SUPERSEDED                     = $010            
#CRYPT_CRLREASONFLAG_CESSATIONOFOPERATION           = $020  
#CRYPT_CRLREASONFLAG_CERTIFICATEHOLD                = $040       
#CRYPT_CRLREASONFLAG_LAST                           = $080 ;     /* Last poss.value */                 
                                                    
                                                    
; /* X.509 CRL holdInstruction codes */                                              
;ENUM                                                      
    #CRYPT_HOLDINSTRUCTION_NONE                       = 00      
    #CRYPT_HOLDINSTRUCTION_CALLISSUER                 = 01       
    #CRYPT_HOLDINSTRUCTION_REJECT                     = 02       
    #CRYPT_HOLDINSTRUCTION_PICKUPTOKEN                = 03       
    #CRYPT_HOLDINSTRUCTION_LAST                       = 04       
;END ENUM                                           
                                                    
                                                    
;/* Certificate checking compliance levels */                                    
;ENUM                                                
    #CRYPT_COMPLIANCELEVEL_OBLIVIOUS                  = 00
    #CRYPT_COMPLIANCELEVEL_REDUCED                    = 01
    #CRYPT_COMPLIANCELEVEL_STANDARD                   = 02
    #CRYPT_COMPLIANCELEVEL_PKIX_PARTIAL               = 03
    #CRYPT_COMPLIANCELEVEL_PKIX_FULL                  = 04
    #CRYPT_COMPLIANCELEVEL_LAST                       = 05
;END ENUM                                            
                                                    
                                                    
;/* Flags for the Netscape netscape-cert-type extension */                                         
#CRYPT_NS_CERTTYPE_SSLCLIENT                        = $001
#CRYPT_NS_CERTTYPE_SSLSERVER                        = $002
#CRYPT_NS_CERTTYPE_SMIME                            = $004
#CRYPT_NS_CERTTYPE_OBJECTSIGNING                    = $008
#CRYPT_NS_CERTTYPE_RESERVED                         = $010
#CRYPT_NS_CERTTYPE_SSLCA                            = $020
#CRYPT_NS_CERTTYPE_SMIMECA                          = $040
#CRYPT_NS_CERTTYPE_OBJECTSIGNINGCA                  = $080
#CRYPT_NS_CERTTYPE_LAST                             = $100 ; /* Last possible value */ 
                                                    
                                                    
;/* Flags for the SET certificate-type extension
#CRYPT_SET_CERTTYPE_CARD                            = $001
#CRYPT_SET_CERTTYPE_MER                             = $002
#CRYPT_SET_CERTTYPE_PGWY                            = $004
#CRYPT_SET_CERTTYPE_CCA                             = $008
#CRYPT_SET_CERTTYPE_MCA                             = $010
#CRYPT_SET_CERTTYPE_PCA                             = $020
#CRYPT_SET_CERTTYPE_GCA                             = $040
#CRYPT_SET_CERTTYPE_BCA                             = $080
#CRYPT_SET_CERTTYPE_RCA                             = $100
#CRYPT_SET_CERTTYPE_ACQ                             = $200
#CRYPT_SET_CERTTYPE_LAST                            = $400 ; /* Last possible value */
                

; /* CMS contentType values */                        
;ENUM #CRYPT_CONTENT_TYPE                          
    #CRYPT_CONTENT_NONE                               = 00    
    #CRYPT_CONTENT_DATA                               = 01     
    #CRYPT_CONTENT_SIGNEDDATA                         = 02     
    #CRYPT_CONTENT_ENVELOPEDDATA                      = 03     
    #CRYPT_CONTENT_SIGNEDANDENVELOPEDDATA             = 04     
    #CRYPT_CONTENT_DIGESTEDDATA                       = 05     
    #CRYPT_CONTENT_ENCRYPTEDDATA                      = 06     
    #CRYPT_CONTENT_COMPRESSEDDATA                     = 07 
  #CRYPT_CONTENT_AUTHDATA                           = 08 
  #CRYPT_CONTENT_AUTHENVDATA                        = 09 
  #CRYPT_CONTENT_TSTINFO                            = 10 
  #CRYPT_CONTENT_SPCINDIRECTDATACONTEXT             = 11 
  #CRYPT_CONTENT_RTCSREQUEST                        = 12 
  #CRYPT_CONTENT_RTCSRESPONSE                       = 13 
  #CRYPT_CONTENT_RTCSRESPONSE_EXT                   = 14 
  #CRYPT_CONTENT_MRTD                               = 15 
  #CRYPT_CONTENT_LAST                               = 16 
;END ENUM                                           
                                                    
                                                             
;/* ESS securityClassification codes */                                                         
;ENUM                                                        
    #CRYPT_CLASSIFICATION_UNMARKED                    = 00                                            
    #CRYPT_CLASSIFICATION_UNCLASSIFIED                = 01
    #CRYPT_CLASSIFICATION_RESTRICTED                  = 02
    #CRYPT_CLASSIFICATION_CONFIDENTIAL                = 03
    #CRYPT_CLASSIFICATION_SECRET                      = 04
    #CRYPT_CLASSIFICATION_TOP_SECRET                  = 05
    #CRYPT_CLASSIFICATION_LAST                        = 255
;END ENUM                                           
                                                    
                                                    
;/* RTCS certificate status */                                                  
;ENUM                                               
    #CRYPT_CERTSTATUS_VALID                           = 00
    #CRYPT_CERTSTATUS_NOTVALID                        = 01
    #CRYPT_CERTSTATUS_NONAUTHORITATIVE                = 02
    #CRYPT_CERTSTATUS_UNKNOWN                         = 03
                                                    
;END ENUM                                           
                                                    
                                                    
;/* OCSP revocation status */                                            
;ENUM                                               
    #CRYPT_OCSPSTATUS_NOTREVOKED                      = 00
    #CRYPT_OCSPSTATUS_REVOKED                         = 01
    #CRYPT_OCSPSTATUS_UNKNOWN                         = 02
;END ENUM                                         
      
      
; /* The amount of detail to include in signatures when signing certificate objects */                                         
;ENUM #CRYPT_SIGNATURELEVEL_TYPE                  
    #CRYPT_SIGNATURELEVEL_NONE                        = 00 ; /* Include only signature */        
    #CRYPT_SIGNATURELEVEL_SIGNERCERT                  = 01 ; /* Include signer cert */           
    #CRYPT_SIGNATURELEVEL_ALL                         = 02 ; /* Include ALL relevant info */     
    #CRYPT_SIGNATURELEVEL_LAST                        = 03 ; /* Last possible sig.level TYPE */  
;END ENUM                                         
                                                  
       
; The level of integrity protection to apply to enveloped data.  The 
; default envelope protection for an envelope with keying information 
; applied is encryption, this can be modified to use MAC-only protection
; (WITH no encryption) OR hybrid encryption + authentication */  
;ENUM CRYPT_INTEGRITY_TYPE
    #CRYPT_INTEGRITY_NONE                                    = 00 ; /* No integrity protection */
    #CRYPT_INTEGRITY_MACONLY                            = 01 ; /* MAC only, no encryption */
    #CRYPT_INTEGRITY_FULL                                    = 02 ; /* Encryption + ingerity protection */
;END ENUM   


; The certificate export format type, which defines the format in which a
; certificate object is exported */                        
;ENUM CRYPT_CERTFORMAT_TYPE                      
    #CRYPT_CERTFORMAT_NONE                            = 00 ; /* No certificate format */      
    #CRYPT_CERTFORMAT_CERTIFICATE                     = 01 ; /* DER-encoded certificate */    
    #CRYPT_CERTFORMAT_CERTCHAIN                       = 02 ; /* PKCS #7 certificate chain */  
    #CRYPT_CERTFORMAT_TEXT_CERTIFICATE                = 03 ; /* base-64 wrapped cert */       
    #CRYPT_CERTFORMAT_TEXT_CERTCHAIN                  = 04 ; /* BASE-64 wrapped cert chain */ 
    #CRYPT_CERTFORMAT_XML_CERTIFICATE                 = 05 ; /* XML wrapped cert */           
    #CRYPT_CERTFORMAT_XML_CERTCHAIN                   = 06 ; /* XML wrapped cert chain */     
    #CRYPT_CERTFORMAT_LAST                            = 07 ; /* Last possible cert.format type */
;END ENUM                                           
                                                    
                                                    
;ENUM CRYPT_REQUESTTYPE_TYPE                        
    #CRYPT_REQUESTTYPE_NONE                           = 00 ; /* No request TYPE */                
    #CRYPT_REQUESTTYPE_INITIALISATION                 = 01 ; /* Initialisation request */         
    #CRYPT_REQUESTTYPE_INITIALIZATION                 = #CRYPT_REQUESTTYPE_INITIALISATION 
    #CRYPT_REQUESTTYPE_CERTIFICATE                    = 03 ; /* Certification request */          
    #CRYPT_REQUESTTYPE_KEYUPDATE                      = 04 ; /* Key update request */             
    #CRYPT_REQUESTTYPE_REVOCATION                     = 05 ; /* Cert revocation request */        
    #CRYPT_REQUESTTYPE_PKIBOOT                        = 06 ; /* PKIBoot request */                
    #CRYPT_REQUESTTYPE_LAST                           = 07 ; /* Last possible request TYPE */     
;END ENUM CRYPT_REQUESTTYPE_TYPE                                   
                                                    
; /* Key ID types */                                            
;ENUM CRYPT_KEYID_TYPE                              
    #CRYPT_KEYID_NONE                                 = 00 ; /* No key ID type */
    #CRYPT_KEYID_NAME                                 = 01 ; /* Key owner name */
    #CRYPT_KEYID_URI                                          = 02 ; /* Key owner URI */
    #CRYPT_KEYID_EMAIL                                = #CRYPT_KEYID_URI ; /* Synonym: owner email ADDR.*/  
    #CRYPT_KEYID_LAST                                 = 03 ; /* Last possible key ID type */
;END ENUM CRYPT_KEYID_TYPE                                      
                                                    
;/* The encryption object types */                                                 
;ENUM CRYPT_OBJECT_TYPE                             
    #CRYPT_OBJECT_NONE                                = 00 ; /* No object type */                    
    #CRYPT_OBJECT_ENCRYPTED_KEY                       = 01 ; /* Conventionally encrypted key */  
    #CRYPT_OBJECT_PKCENCRYPTED_KEY                    = 02 ; /* PKC-encrypted key */           
    #CRYPT_OBJECT_KEYAGREEMENT                        = 03 ; /* Key agreement information */     
    #CRYPT_OBJECT_SIGNATURE                           = 04 ; /* Signature */                       
    #CRYPT_OBJECT_LAST                                = 05 ; /* Last possible object type */           
;END ENUM CRYPT_OBJECT_TYPE                                       
                                                    
; /* Object/attribute error type information */                                                
;ENUM CRYPT_ERRTYPE_TYPE                            
    #CRYPT_ERRTYPE_NONE                               = 00 ; /* No error information */                            
    #CRYPT_ERRTYPE_ATTR_SIZE                          = 01 ; /* Attribute data too small or large */            
    #CRYPT_ERRTYPE_ATTR_VALUE                         = 02 ; /* Attribute value is invalid */                   
    #CRYPT_ERRTYPE_ATTR_ABSENT                        = 03 ; /* Required attribute missing */                 
    #CRYPT_ERRTYPE_ATTR_PRESENT                       = 04 ; /* Non-allowed attribute present */              
    #CRYPT_ERRTYPE_CONSTRAINT                         = 05 ; /* Cert: Constraint violation in object */         
    #CRYPT_ERRTYPE_ISSUERCONSTRAINT                   = 06 ; /* Cert: Constraint viol.in issuing cert */    
    #CRYPT_ERRTYPE_LAST                               = 07 ; /* Last possible error info type */                  
;END ENUM CRYPT_ERRTYPE_TYPE                                     
                                                    
                                                    
;ENUM CRYPT_CERTACTION_TYPE                         
    #CRYPT_CERTACTION_NONE                            = 00 ; /* No cert management action */                    
    #CRYPT_CERTACTION_CREATE                          = 01 ; /* Create cert store */                            
    #CRYPT_CERTACTION_CONNECT                         = 02 ; /* Connect to cert store */                        
    #CRYPT_CERTACTION_DISCONNECT                      = 03 ; /* Disconnect from cert store */                 
    #CRYPT_CERTACTION_ERROR                           = 04 ; /* Error information */                            
    #CRYPT_CERTACTION_ADDUSER                         = 05 ; /* Add PKI user */                                  
    #CRYPT_CERTACTION_DELETEUSER                        = 06 ; /* Delete PKI user */                            
    #CRYPT_CERTACTION_REQUEST_CERT                    = 07 ; /* Cert request */                             
    #CRYPT_CERTACTION_REQUEST_RENEWAL                 = 08 ; /* Cert renewal request */                    
    #CRYPT_CERTACTION_REQUEST_REVOCATION              = 09 ; /* Cert revocation request */              
    #CRYPT_CERTACTION_CERT_CREATION                   = 10 ; /* Cert creation */                            
    #CRYPT_CERTACTION_CERT_CREATION_COMPLETE          = 11 ; /* Confirmation of cert creation */    
    #CRYPT_CERTACTION_CERT_CREATION_DROP              = 12 ; /* Cancellation of cert creation */      
    #CRYPT_CERTACTION_CERT_CREATION_REVERSE           = 13 ; /* Cancel of creation w.revocation */  
    #CRYPT_CERTACTION_RESTART_CLEANUP                 = 14 ; /* Delete reqs after restart */              
    #CRYPT_CERTACTION_RESTART_REVOKE_CERT             = 15 ; /* Complete revocation after restart */  
    #CRYPT_CERTACTION_ISSUE_CERT                      = 16 ; /* Cert issue */                                 
    #CRYPT_CERTACTION_ISSUE_CRL                       = 17 ; /* CRL issue */                                  
    #CRYPT_CERTACTION_REVOKE_CERT                     = 18 ; /* Cert revocation */                            
    #CRYPT_CERTACTION_EXPIRE_CERT                     = 19 ; /* Cert expiry */                                
    #CRYPT_CERTACTION_CLEANUP                         = 20 ; /* Clean up on restart */                          
    #CRYPT_CERTACTION_LAST                            = 21 ; /* Last possible cert store log action */            
;END ENUM CRYPT_CERTACTION_TYPE                                         
       



;  /****************************************************************************
;  *                                                                                                                 *
;  *                                            General Constants                                             *
;  *                                                                                                                 *
;  ****************************************************************************/
                                              
#CRYPT_MAX_KEYSIZE                                  =  256 ; /* The maximum user key size - 2048 bits */                     
#CRYPT_MAX_IVSIZE                                   =  32  ; /* The maximum IV size - 256 bits */                     
#CRYPT_MAX_PKCSIZE                                  =  512 ; The maximum public-key component size - 4096 bits, and maximum component 
#CRYPT_MAX_PKCSIZE_ECC                                =  72  ; size FOR ECCs - 576 bits (TO HANDLE the P521 curve) */                   
#CRYPT_MAX_HASHSIZE                                 =  32  ; /* The maximum hash size - 256 bits */                   
#CRYPT_MAX_TEXTSIZE                                 =  64  ; /* The maximum size of a text string (e.g.key owner name) */                   
#CRYPT_USE_DEFAULT                                  = -100 ; A magic value indicating that the default setting                   
#CRYPT_UNUSED                                       = -101 ; /* A magic value for unused parameters */  
    
; Cursor positioning codes for certificate/CRL extensions.  The parentheses 
; are to catch potential erroneous use in an expression */
#CRYPT_CURSOR_FIRST                                 = -200
#CRYPT_CURSOR_PREVIOUS                              = -201
#CRYPT_CURSOR_NEXT                                  = -202
#CRYPT_CURSOR_LAST                                  = -203
               
; The type of information polling to perform to get random seed 
; information.  These values have to be negative because they;re used
; as magic length values for cryptAddRandom().  The parentheses are to 
; catch potential erroneous use IN an expression */ 
#CRYPT_RANDOM_FASTPOLL                              = -300
#CRYPT_RANDOM_SLOWPOLL                              = -301 

;/* Whether the PKC key is a public or private key */
#CRYPT_KEYTYPE_PRIVATE                              =  0                   
#CRYPT_KEYTYPE_PUBLIC                               =  1
                                                    
                                                    
;/* Keyset open options */                                       
;ENUM CRYPT_KEYOPT_TYPE                             
    #CRYPT_KEYOPT_NONE                                = 00 ; /* No options */                         
    #CRYPT_KEYOPT_READONLY                            = 01 ; /* Open keyset in read-only mode */    
    #CRYPT_KEYOPT_CREATE                              = 02 ; /* Create a new keyset */                
    #CRYPT_KEYOPT_LAST                                = 03 ; /* Last possible key option type */
;END ENUM CRYPT_KEYOPT_TYPE                                    
              

       

;  /****************************************************************************
;  *                                                                                                                 *
;  *                                    Encryption DATA Structures                                       *
;  *                                                                                                                 *
;  ****************************************************************************/


Structure CRYPT_QUERY_INFO
    algoName.s{64}        ;      As ASCIIZ * 64          ; /* Algorithm NAME - C_CHR[CRYPT_MAX_TEXTSIZE]
    blockSize.l             ;As LONG                 ; /* Block size of the algorithm */      
    minKeySize.l            ;As LONG                 ; /* Minimum key size in bytes */        
    keySize.l               ;As LONG                 ; /* Recommended key size in bytes */      
    maxKeySize.l            ;As LONG                 ; /* Maximum key size in bytes */        
EndStructure

; Results returned from the encoded object query.  These provide info
; on the objects created by cryptExportKey() & cryptCreateSignature()


Structure CRYPT_OBJECT_INFO
    objectType.l            ;As LONG                 ; CRYPT_OBJECT_TYPE ; /* The object type */
    cryptAlgo.l             ;As LONG                 ; CRYPT_ALGO_TYPE   ; /* The encryption algorithm And mode */
    cryptMode.l             ;As LONG                 ; CRYPT_MODE_TYPE   ; /* The encryption algorithm And mode */
    hashAlgo.l              ;As LONG                 ; CRYPT_ALGO_TYPE   ; /* The hash algorithm For Signature objects */
    salt.b[31]              ;As BYTE                 ; (0 TO 32-1) /* The salt for derived keys */
    saltSize.l              ;As LONG                 ; 32
EndStructure; CRYPT_OBJECT_INFO                    

;Dim saltArray.b(31)
;CRYPT_OBJECT_INFO\salt = @salt()                  
                        
; Key information for the public-key encryption algorithms.  These fields
; are not accessed directly, but can be manipulated with the init/set/
; destroyComponents() macros */
Structure CRYPT_PKCINFO_RSA                          ; CRYPT_MAX_PKCSIZE = (0 TO 512-1)
;    /* Status information */                      
    isPublicKey.l           ;As LONG                 ; /* Whether this is a public or private key */ 
                                                
;    /* Public components */                       
    n.b[511]                ;As BYTE                 ; /* Modulus */                           
    nLen .l                 ;As LONG                 ; /* Length OF modulus IN bits */         
    e.b[511]                ;As BYTE                 ; /* Public exponent */                   
    eLen.l                  ;As LONG                 ; /* Length OF public exponent IN bits */ 
                                                
;    /* Private components */                      
    d.b[511]                ;As BYTE                 ; /* PRIVATE exponent */                     
    dLen.l                  ;As LONG                 ; /* Length OF PRIVATE exponent IN bits */   
    p.b[511]                ;As BYTE                 ; /* Prime factor 1 */                       
    pLen.l                  ;As LONG                 ; /* Length OF prime factor 1 IN bits */     
    q.b[511]                ;As BYTE                 ; /* Prime factor 2 */                       
    qLen.l                  ;As LONG                 ; /* Length OF prime factor 2 IN bits */     
    u.b[511]                ;As BYTE                 ; /* Mult.inverse OF q, MOD p */             
    uLen.l                  ;As LONG                 ; /* Length OF PRIVATE exponent IN bits */   
    e1.b[511]               ;As BYTE                 ; /* Private exponent 1 (PKCS) */            
    e1Len.l                 ;As LONG                 ; /* Length OF PRIVATE exponent IN bits */   
    e2.b[511]               ;As BYTE                 ; /* Private exponent 2 (PKCS) */            
    e2Len.l                 ;As LONG                 ; /* Length OF PRIVATE exponent IN bits */   
EndStructure  ; CRYPT_PKCINFO_RSA                    
                                                
                                                
                                                
Structure CRYPT_PKCINFO_DLP                          ; CRYPT_MAX_PKCSIZE = (0 TO 512-1)
;    /* Status information */                      
    isPublicKey.l           ;As LONG                 ; /* Whether this is a public or private key */
                                                
;    /* Public components */                       
    p.b[511]                ;As BYTE                 ; /* Prime modulus */                      
    pLen.l                ;As LONG                 ; /* Length OF prime modulus IN bits */    
    q.b[511]                ;As BYTE                 ; /* Prime divisor */                      
    qLen.l                ;As LONG                 ; /* Length OF prime divisor IN bits */    
    g.b[511]                ;As BYTE                 ; /* h^( ( p - 1 ) / q ) mod p */          
    gLen.l                ;As LONG                 ; /* Length OF g IN bits */                
    y.b[511]                ;As BYTE                 ; /* Public random LONG    */              
    yLen.l                ;As LONG                 ; /* Length OF public LONG    IN bits */   
                                                
;    /* Private components */                      
    x.b[511]                ;As BYTE                 ; /* Private random LONG    */            
    xLen.l                ;As LONG                 ; /* Length OF PRIVATE LONG    IN bits */ 
EndStructure ; CRYPT_PKCINFO_DLP                
     
  
;ENUM CRYPT_ECCCURVE_TYPE
; Named ECC curves.  When updating these remember to also update the 
; ECC fieldSizeInfo table in context/kg_ecc.c, the eccOIDinfo table and 
; sslEccCurveInfo table in context/key_rd.c, and the curveIDTbl in 
; session/ssl.c */
    #CRYPT_ECCCURVE_NONE                         = 00 ; /* No ECC curve TYPE */
    #CRYPT_ECCCURVE_P192                         = 01 ; /* NIST P192/X9.62 P192r1/SECG p192r1 curve */
    #CRYPT_ECCCURVE_P224                         = 02 ; /* NIST P224/X9.62 P224r1/SECG p224r1 curve */
    #CRYPT_ECCCURVE_P256                         = 03 ; /* NIST P256/X9.62 P256v1/SECG p256r1 curve */
    #CRYPT_ECCCURVE_P384                         = 04 ; /* NIST P384, SECG p384r1 curve */
    #CRYPT_ECCCURVE_P521                         = 05 ; /* NIST P521, SECG p521r1 */
    #CRYPT_ECCCURVE_LAST                         = 06 ; /* Last valid ECC curve TYPE */
;END ENUM 


Structure CRYPT_PKCINFO_ECC  ; CRYPT_MAX_PKCSIZE_ECC = 72   ; size For ECCs - 576 bits 
;    /* STATUS information */
    isPublicKey.l           ;As LONG                   ; /* Whether this is a public OR PRIVATE key */

;    /* Curve domain parameters. Either the curveType OR the EXPLICIT domain parameters must be provided */
    curveType.l             ;As LONG                 ; CRYPT_ECCCURVE_TYPE ;    /* Named curve */  
    p.b[511]                ;As BYTE                 ; /* Prime defining Fq */    
                                                
    pLen.l                  ;As LONG                 ; /* Length OF prime IN bits */
    a.b[511]                ;As BYTE                 ; /* Element IN Fq defining curve */
    aLen.l                  ;As LONG                 ; /* Length OF element a IN bits */
    b.b[511]                ;As BYTE                 ; /* Element IN Fq defining curve */
    bLen.l                  ;As LONG                 ; /* Length OF element b IN bits */
    gx.b[511]               ;As BYTE                 ; /* Element IN Fq defining point */
    gxLen.l                 ;As LONG                 ; /* Length OF element gx IN bits */
    gy.b[511]               ;As BYTE                 ; /* Element IN Fq defining point */
    gyLen.l                 ;As LONG                 ; /* Length OF element gy IN bits */
    n.b[511]                ;As BYTE                 ; /* Order OF point */
    nLen.l                  ;As LONG                 ; /* Length OF order IN bits */
    h.b[511]                ;As BYTE                 ; /* OPTIONAL cofactor */
    hLen.l                  ;As LONG                 ; /* Length OF cofactor IN bits */
                                                
;    /* Public components */                       
    qx.b[511]               ;As BYTE                 ; /* Point Q ON the curve */
    qxLen.l                 ;As LONG                 ; /* Length OF point xq IN bits */
    qy.b[511]               ;As BYTE                 ; /* Point Q ON the curve */
    qyLen.l                 ;As LONG                 ; /* Length OF point xy IN bits */
                                                
;    /* PRIVATE components */                      
    d.b[511]               ; As BYTE                 ; /* PRIVATE RANDOM LONG    */
    dLen.l                  ;As LONG                 ; /* Length OF LONG    IN bits */
EndStructure ; CRYPT_PKCINFO_ECC 

   

;  /****************************************************************************
;  *                                                                                                                  *
;  *                                           STATUS Codes                                                     *
;  *                                                                                                                  *
;  ****************************************************************************/  

; /* Errors in function calls */
#CRYPT_OK                      =  0   ; /* No error */ 
#CRYPT_ERROR_PARAM1            = -1   ; /* Bad argument, parameter 1 */   
#CRYPT_ERROR_PARAM2            = -2   ; /* Bad argument, parameter 2 */   
#CRYPT_ERROR_PARAM3            = -3   ; /* Bad argument, parameter 3 */   
#CRYPT_ERROR_PARAM4            = -4   ; /* Bad argument, parameter 4 */   
#CRYPT_ERROR_PARAM5            = -5   ; /* Bad argument, parameter 5 */   
#CRYPT_ERROR_PARAM6            = -6   ; /* Bad argument, parameter 6 */   
#CRYPT_ERROR_PARAM7            = -7   ; /* Bad argument, parameter 7 */ 

;/* Errors due to insufficient resources */  
#CRYPT_ERROR_MEMORY            = -10  ; /* Out of memory */                         
#CRYPT_ERROR_NOTINITED         = -11  ; /* Data has not been initialised */         
#CRYPT_ERROR_INITED            = -12  ; /* Data has already been init;d */          
#CRYPT_ERROR_NOSECURE          = -13  ; /* Opn.not avail.at requested sec.level */  
#CRYPT_ERROR_RANDOM            = -14  ; /* No reliable random data available */     
#CRYPT_ERROR_FAILED            = -15  ; /* Operation failed */  
#CRYPT_ERROR_INTERNAL          = -16  ; /* Internal consistency check failed */       
             
;/* Security violations */
#CRYPT_ERROR_NOTAVAIL          = -20  ; /* This type of opn.not available */             
#CRYPT_ERROR_PERMISSION        = -21  ; /* No permiss.TO perform this operation */     
#CRYPT_ERROR_WRONGKEY          = -22  ; /* Incorrect key used to decrypt data */       
#CRYPT_ERROR_INCOMPLETE        = -23  ; /* Operation incomplete/still IN progress */   
#CRYPT_ERROR_COMPLETE          = -24  ; /* Operation complete/can;t Continue */        
#CRYPT_ERROR_TIMEOUT           = -25  ; /* Operation timed out before completion */    
#CRYPT_ERROR_INVALID           = -26  ; /* Invalid/inconsistent information */         
#CRYPT_ERROR_SIGNALLED         = -27  ; /* Resource destroyed by extnl.event */
   
;/* High-level function errors */     
#CRYPT_ERROR_OVERFLOW          = -30  ; /* Resources/space exhausted */        
#CRYPT_ERROR_UNDERFLOW         = -31  ; /* Not enough data available */        
#CRYPT_ERROR_BADDATA           = -32  ; /* Bad/unrecognised data format */     
#CRYPT_ERROR_SIGNATURE         = -33  ; /* Signature/integrity check failed */ 

;/* Data access function errors */
#CRYPT_ERROR_OPEN              = -40  ; /* Cannot OPEN object */                     
#CRYPT_ERROR_READ              = -41  ; /* Cannot READ item from object */           
#CRYPT_ERROR_WRITE             = -42  ; /* Cannot WRITE item to object */            
#CRYPT_ERROR_NOTFOUND          = -43  ; /* Requested item not found in object */     
#CRYPT_ERROR_DUPLICATE         = -44  ; /* Item already present in object */ 

;/* Data enveloping errors */     
#CRYPT_ENVELOPE_RESOURCE       = -50  ; /* Need resource to proceed */ 
             


;  /****************************************************************************
;  *                                                                                                                 *
;  *                                        General Functions                                         *
;  *                                                                                                                 *
;  ****************************************************************************/ 

#Cryptlib = 1

;Global #Cryptlib.l
OpenLibrary(#Cryptlib, "cl32.dll")

Global *cryptInit = GetFunction(#Cryptlib, "cryptInit")
Global *cryptEnd = GetFunction(#Cryptlib, "cryptEnd")
Global *cryptQueryCapability = GetFunction(#Cryptlib, "cryptQueryCapability")
Global *cryptCreateContext = GetFunction(#Cryptlib, "cryptCreateContext")
Global *cryptDestroyContext = GetFunction(#Cryptlib, "cryptDestroyContext")
Global *cryptDestroyObject = GetFunction(#Cryptlib, "cryptDestroyObject")
Global *cryptGenerateKey = GetFunction(#Cryptlib, "cryptGenerateKey")
Global *cryptGenerateKeyAsync = GetFunction(#Cryptlib, "cryptGenerateKeyAsync")
Global *cryptAsyncQuery = GetFunction(#Cryptlib, "cryptAsyncQuery")
Global *cryptAsyncCancel = GetFunction(#Cryptlib, "cryptAsyncCancel")
Global *cryptEncrypt = GetFunction(#Cryptlib, "cryptEncrypt")
Global *cryptDecrypt = GetFunction(#Cryptlib, "cryptDecrypt")
Global *cryptSetAttribute = GetFunction(#Cryptlib, "cryptSetAttribute")
Global *cryptSetAttributeString = GetFunction(#Cryptlib, "cryptSetAttributeString")
Global *cryptGetAttribute = GetFunction(#Cryptlib, "cryptGetAttribute")
Global *cryptGetAttributeString = GetFunction(#Cryptlib, "cryptGetAttributeString")
Global *cryptDeleteAttribute = GetFunction(#Cryptlib, "cryptDeleteAttribute")
Global *cryptAddRandom = GetFunction(#Cryptlib, "cryptAddRandom")
Global *cryptQueryObject = GetFunction(#Cryptlib, "cryptQueryObject")
Global *cryptExportKey = GetFunction(#Cryptlib, "cryptExportKey")
Global *cryptExportKeyEx = GetFunction(#Cryptlib, "cryptExportKeyEx")
Global *cryptImportKey = GetFunction(#Cryptlib, "cryptImportKey")
Global *cryptImportKeyEx = GetFunction(#Cryptlib, "cryptImportKeyEx")
Global *cryptCreateSignature = GetFunction(#Cryptlib, "cryptCreateSignature")
Global *cryptCreateSignatureEx = GetFunction(#Cryptlib, "cryptCreateSignatureEx")
Global *cryptCheckSignature = GetFunction(#Cryptlib, "cryptCheckSignature")
Global *cryptCheckSignatureEx = GetFunction(#Cryptlib, "cryptCheckSignatureEx")
Global *cryptKeysetOpen = GetFunction(#Cryptlib, "cryptKeysetOpen")
Global *cryptKeysetClose = GetFunction(#Cryptlib, "cryptKeysetClose")
Global *cryptGetPublicKey = GetFunction(#Cryptlib, "cryptGetPublicKey")
Global *cryptGetPrivateKey = GetFunction(#Cryptlib, "cryptGetPrivateKey")
Global *cryptGetKey = GetFunction(#Cryptlib, "cryptGetKey")
Global *cryptAddPublicKey = GetFunction(#Cryptlib, "cryptAddPublicKey")
Global *cryptAddPrivateKey = GetFunction(#Cryptlib, "cryptAddPrivateKey")
Global *cryptDeleteKey = GetFunction(#Cryptlib, "cryptDeleteKey")
Global *cryptCreateCert = GetFunction(#Cryptlib, "cryptCreateCert")
Global *cryptDestroyCert = GetFunction(#Cryptlib, "cryptDestroyCert")
Global *cryptGetCertExtension = GetFunction(#Cryptlib, "cryptGetCertExtension")
Global *cryptAddCertExtension = GetFunction(#Cryptlib, "cryptAddCertExtension")
Global *cryptDeleteCertExtension = GetFunction(#Cryptlib, "cryptDeleteCertExtension")
Global *cryptSignCert = GetFunction(#Cryptlib, "cryptSignCert")
Global *cryptCheckCert = GetFunction(#Cryptlib, "cryptCheckCert")
Global *cryptImportCert = GetFunction(#Cryptlib, "cryptImportCert")
Global *cryptExportCert = GetFunction(#Cryptlib, "cryptExportCert")
Global *cryptCAAddItem = GetFunction(#Cryptlib, "cryptCAAddItem")
Global *cryptCAGetItem = GetFunction(#Cryptlib, "cryptCAGetItem")
Global *cryptCADeleteItem = GetFunction(#Cryptlib, "cryptCADeleteItem")
Global *cryptCACertManagement = GetFunction(#Cryptlib, "cryptCACertManagement")
Global *cryptCreateSession = GetFunction(#Cryptlib, "cryptCreateSession")
Global *cryptDestroySession = GetFunction(#Cryptlib, "cryptDestroySession")
Global *cryptCreateEnvelope = GetFunction(#Cryptlib, "cryptCreateEnvelope")
Global *cryptDestroyEnvelope = GetFunction(#Cryptlib, "cryptDestroyEnvelope")
Global *cryptPushData = GetFunction(#Cryptlib, "cryptPushData")
Global *cryptFlushData = GetFunction(#Cryptlib, "cryptFlushData")
Global *cryptPopData = GetFunction(#Cryptlib, "cryptPopData")
Global *cryptDeviceOpen = GetFunction(#Cryptlib, "cryptDeviceOpen")
Global *cryptDeviceClose = GetFunction(#Cryptlib, "cryptDeviceClose")
Global *cryptDeviceQueryCapability = GetFunction(#Cryptlib, "cryptDeviceQueryCapability")
Global *cryptDeviceCreateContext = GetFunction(#Cryptlib, "cryptDeviceCreateContext")
Global *cryptLogin = GetFunction(#Cryptlib, "cryptLogin")
Global *cryptLogout = GetFunction(#Cryptlib, "cryptLogout")
Global *cryptUIGenerateKey = GetFunction(#Cryptlib, "cryptUIGenerateKey")
Global *cryptUIDisplayCert = GetFunction(#Cryptlib, "cryptUIDisplayCert")

Procedure.l cryptInit()
ProcedureReturn CallFunctionFast(*cryptInit)
EndProcedure

Procedure cryptEnd()
ProcedureReturn CallFunctionFast(*cryptEnd)
EndProcedure

Procedure.l cryptQueryCapability(device.l, cryptAlgo.l, CQI) ;CQI.CRYPT_QUERY_INFO
ProcedureReturn CallFunctionFast(*cryptQueryCapability, device.l, cryptAlgo, CQI)
EndProcedure

Procedure.l cryptCreateContext(hContext.l, cryptUser.l, cryptAlgo.l) 
ProcedureReturn CallFunctionFast(*cryptCreateContext, hContext, cryptUser, cryptAlgo)
EndProcedure

Procedure.l cryptDestroyContext(hContext.l) 
ProcedureReturn CallFunctionFast(*cryptDestroyContext, hContext)
EndProcedure

Procedure.l cryptDestroyObject(hCrypt.l) 
ProcedureReturn CallFunctionFast(*cryptDestroyObject, hCrypt)
EndProcedure

Procedure.l cryptGenerateKey(hContext.l) 
ProcedureReturn CallFunctionFast(*cryptGenerateKey, hContext)
EndProcedure

Procedure.l cryptGenerateKeyAsync(hContext.l) 
ProcedureReturn CallFunctionFast(*cryptGenerateKeyAsync, hContext)
EndProcedure 

Procedure.l cryptAsyncQuery(hCrypt.l) 
ProcedureReturn CallFunctionFast(*cryptAsyncQuery, hCrypt)
EndProcedure

Procedure.l cryptAsyncCancel(hCrypt.l) 
ProcedureReturn CallFunctionFast(*cryptAsyncCancel, hCrypt)
EndProcedure  

Procedure.l cryptEncrypt(hContext.l, pBuffer.i, length.l) 
ProcedureReturn CallFunctionFast(*cryptEncrypt, hContext, pBuffer, length)
EndProcedure

Procedure.l cryptDecrypt(hContext.l, pBuffer.i, length.l) 
ProcedureReturn CallFunctionFast(*cryptDecrypt, hContext.l, pBuffer.i, length.l)
EndProcedure

Procedure.l cryptSetAttribute(hCrypt.l,CryptAttType.l, value.l) 
ProcedureReturn CallFunctionFast(*cryptSetAttribute, hCrypt.l,CryptAttType.l, value.l)
EndProcedure

Procedure.l cryptSetAttributeString(hCrypt.l, CryptAttType.l, pBuff.i, StrLen.l) 
ProcedureReturn CallFunctionFast(*cryptSetAttributeString, hCrypt.l, CryptAttType.l, pBuff.i, StrLen.l)
EndProcedure

Procedure.l cryptGetAttribute(hCrypt.l, CryptAttType.l, pRetVal.l) 
ProcedureReturn CallFunctionFast(*cryptGetAttribute, hCrypt.l, CryptAttType.l, pRetVal.l)
EndProcedure

Procedure.l cryptGetAttributeString(hCrypt.l, CryptAttType.l, pBuff.i, pStrLen.l) 
ProcedureReturn CallFunctionFast(*cryptGetAttributeString, hCrypt.l, CryptAttType.l, pBuff.i, pStrLen.l)
EndProcedure

Procedure.l cryptDeleteAttribute(hCrypt.l, CryptAttType.l) 
ProcedureReturn CallFunctionFast(*cryptDeleteAttribute, hCrypt.l, CryptAttType.l) 
EndProcedure

Procedure.l cryptAddRandom(pData.i, RandDataLen.l) 
ProcedureReturn CallFunctionFast(*cryptAddRandom, pData.i, RandDataLen.l) 
EndProcedure

Procedure.l cryptQueryObject(pData.i, pCOI) ;pCOI.CRYPT_OBJECT_INFO)
ProcedureReturn CallFunctionFast(*cryptQueryObject, pData.i, pCOI)
EndProcedure

;  /****************************************************************************
;  *                                                                                                                 *
;  *                                        Mid-level Encryption Functions                             *
;  *                                                                                                                 *
;  ****************************************************************************/

Procedure.l cryptExportKey(pKey.i, pEncryptedKeyLength.l, exportKey.l, sessionKeyContext.l) 
ProcedureReturn CallFunctionFast(*cryptExportKey, pKey.i, pEncryptedKeyLength.l, exportKey.l, sessionKeyContext.l)
EndProcedure

Procedure.l cryptExportKeyEx(pKey.i, pEncryptedKeyLength.l, FormatType.l, exportKey.l, sessionKeyContext.l) 
ProcedureReturn CallFunctionFast(*cryptExportKeyEx, pKey.i, pEncryptedKeyLength.l, FormatType.l, exportKey.l, sessionKeyContext.l)
EndProcedure

Procedure cryptImportKey(pKey.i, importKey.l, sessionKeyContext.l)
ProcedureReturn CallFunctionFast(*cryptImportKey,  pKey.i, importKey.l, sessionKeyContext.l)
EndProcedure

Procedure cryptImportKeyEx(pKey.i, importKey.l, sessionKeyContext.l, pReturnedContext.l)
ProcedureReturn CallFunctionFast(*cryptImportKeyEx,  pKey.i, importKey.l, sessionKeyContext.l, pReturnedContext.l)
EndProcedure

Procedure cryptCreateSignature(pSig.i, pSignatureLength.l, signContext.l, hashContext.l)
ProcedureReturn CallFunctionFast(*cryptCreateSignature,  pSig.i, pSignatureLength.l, signContext.l, hashContext.l)
EndProcedure

Procedure cryptCreateSignatureEx(pSig.i, pSignatureLength.l, FormatType.l, signContext.l, hashContext.l, extraData.l)
ProcedureReturn CallFunctionFast(*cryptCreateSignatureEx,  pSig.i, pSignatureLength.l, FormatType.l, signContext.l, hashContext.l, extraData.l)
EndProcedure

Procedure cryptCheckSignature(pSig.i, sigCheckKey.l, hashContext.l)
ProcedureReturn CallFunctionFast(*cryptCheckSignature,  pSig.i, sigCheckKey.l, hashContext.l)
EndProcedure

Procedure cryptCheckSignatureEx(pSig.i, sigCheckKey.l, hashContext.l, pExtraData.l)
ProcedureReturn CallFunctionFast(*cryptCheckSignatureEx,  pSig.i, sigCheckKey.l, hashContext.l, pExtraData.l)
EndProcedure

;  /****************************************************************************
;  *                                                                                                                 *
;  *                                                  Keyset Functions                                       *
;  *                                                                                                                 *
;  ****************************************************************************/

Procedure cryptKeysetOpen(pKeyset.l, cryptUser.l, keysetType.l, zName.s, options.l)
ProcedureReturn CallFunctionFast(*cryptKeysetOpen,  pKeyset.l, cryptUser.l, keysetType.l, @zName, options.l)
EndProcedure

Procedure cryptKeysetClose(keyset.l)
ProcedureReturn CallFunctionFast(*cryptKeysetClose,  keyset.l)
EndProcedure

Procedure cryptGetPublicKey(keyset.l, pContext.l, keyIDtype.l, zKeyID.s)
ProcedureReturn CallFunctionFast(*cryptGetPublicKey,  keyset.l, pContext.l, keyIDtype.l, @zKeyID)
EndProcedure

Procedure cryptGetPrivateKey(keyset.l, pContext.l, keyIDtype.l, zKeyID.s, zPassword.s)
ProcedureReturn CallFunctionFast(*cryptGetPrivateKey,  keyset.l, pContext.l, keyIDtype.l, @zKeyID, @zPassword)
EndProcedure

Procedure cryptGetKey(keyset.l, CryptContext.l, keyIDtype.l, zKeyID.s, zPassword.s)
ProcedureReturn CallFunctionFast(*cryptGetKey,  keyset.l, CryptContext.l, keyIDtype.l, @zKeyID, @zPassword)
EndProcedure

Procedure cryptAddPublicKey(keyset.l, certificate.l)
ProcedureReturn CallFunctionFast(*cryptAddPublicKey,  keyset.l, certificate.l)
EndProcedure

Procedure cryptAddPrivateKey(keyset.l, cryptKey.l, zPassword.s)
ProcedureReturn CallFunctionFast(*cryptAddPrivateKey,  keyset.l, cryptKey.l, @zPassword)
EndProcedure

Procedure cryptDeleteKey(keyset.l, keyIDtype.l, zKeyID.s)
ProcedureReturn CallFunctionFast(*cryptDeleteKey,  keyset.l, keyIDtype.l, @zKeyID)
EndProcedure

;  /****************************************************************************
;  *                                                                                                                 *
;  *                                                Certificate Functions                                   *
;  *                                                                                                                 *
;  ****************************************************************************/

Procedure cryptCreateCert(pCert.l, cryptUser.l, certType.l)
ProcedureReturn CallFunctionFast(*cryptCreateCert,  pCert.l, cryptUser.l, certType.l)
EndProcedure

Procedure cryptDestroyCert(hCert.l)
ProcedureReturn CallFunctionFast(*cryptDestroyCert,  hCert.l)
EndProcedure

Procedure cryptGetCertExtension(hCert.l, zOid.s, pCriticalFlag.l, pExtension.i, pextensionLen.l)
ProcedureReturn CallFunctionFast(*cryptGetCertExtension,  hCert.l, @zOid, pCriticalFlag.l, pExtension.i, pextensionLen.l)
EndProcedure

Procedure cryptAddCertExtension(hCert.l, zOid.s, criticalFlag.l, pExtension.i, extensionLen.l)
ProcedureReturn CallFunctionFast(*cryptAddCertExtension,  hCert.l, @zOid, criticalFlag.l, pExtension.i, extensionLen.l)
EndProcedure

Procedure cryptDeleteCertExtension(hCert.l, zOid.s)
ProcedureReturn CallFunctionFast(*cryptDeleteCertExtension,  hCert.l, @zOid)
EndProcedure

Procedure cryptSignCert(hCert.l, signContext.l)
ProcedureReturn CallFunctionFast(*cryptSignCert,  hCert.l, signContext.l)
EndProcedure

Procedure cryptCheckCert(hCert.l, sigCheckKey.l)
ProcedureReturn CallFunctionFast(*cryptCheckCert,  hCert.l, sigCheckKey.l)
EndProcedure

Procedure cryptImportCert(pCertObj.i, certObjectLength.l, cryptUser.l, pCert.l)
ProcedureReturn CallFunctionFast(*cryptImportCert,  pCertObj.i, certObjectLength.l, cryptUser.l, pCert.l)
EndProcedure

Procedure cryptExportCert(pCertObj.i, pCertObjectLength.l, certFormatType.l, hCert.l)
ProcedureReturn CallFunctionFast(*cryptExportCert,  pCertObj.i, pCertObjectLength.l, certFormatType.l, hCert.l)
EndProcedure

Procedure cryptCAAddItem(keyset.l, hCert.l)
ProcedureReturn CallFunctionFast(*cryptCAAddItem,  keyset.l, hCert.l)
EndProcedure

Procedure cryptCAGetItem(keyset.l, pCert.l, certType.l, keyIDtype.l, zKeyID.s)
ProcedureReturn CallFunctionFast(*cryptCAGetItem,  keyset.l, pCert.l, certType.l, keyIDtype.l, @zKeyID)
EndProcedure

Procedure cryptCADeleteItem(keyset.l, keyIDtype.l, zKeyID.s)
ProcedureReturn CallFunctionFast(*cryptCADeleteItem,  keyset.l, keyIDtype.l, @zKeyID)
EndProcedure

Procedure cryptCACertManagement(pCert.l, CertAction.l, keyset.l, caKey.l, certRequest.l)
ProcedureReturn CallFunctionFast(*cryptCACertManagement,  pCert.l, CertAction.l, keyset.l, caKey.l, certRequest.l)
EndProcedure

;  /****************************************************************************
;  *                                                                                                                 *
;  *                                        Envelope & Session Functions                               *
;  *                                                                                                                 *
;  ****************************************************************************/

Procedure.l cryptCreateSession(pSession.l, cryptUser.l, SessionType.l)
ProcedureReturn CallFunctionFast(*cryptCreateSession, pSession.l, cryptUser.l, SessionType.l)
EndProcedure

Procedure.l cryptDestroySession(session.l)       
ProcedureReturn CallFunctionFast(*cryptDestroySession, session.l)
EndProcedure

Procedure.l cryptCreateEnvelope(pEnvelope.l, cryptUser.l, FormatType.l)     
ProcedureReturn CallFunctionFast(*cryptCreateEnvelope, pEnvelope.l, cryptUser.l, FormatType.l)
EndProcedure

Procedure.l cryptDestroyEnvelope(envelope.l)      
ProcedureReturn CallFunctionFast(*cryptDestroyEnvelope, envelope.l)
EndProcedure

Procedure.l cryptPushData(envelope.l, pBuff.i, StrLen.l,  pBytesCopied.l)     
ProcedureReturn CallFunctionFast(*cryptPushData, envelope.l, pBuff.i, StrLen.l,  pBytesCopied.l)
EndProcedure
 
Procedure.l cryptFlushData(envelope.l)           
ProcedureReturn CallFunctionFast(*cryptFlushData, envelope.l)
EndProcedure

Procedure.l cryptPopData(envelope.l, pBuff.i, StrLen.l, pBytesCopied.l)          
ProcedureReturn CallFunctionFast(*cryptPopData, envelope.l, pBuff.i, StrLen.l, pBytesCopied.l)
EndProcedure

;  /****************************************************************************
;  *                                                                                                                 *
;  *                                              Device Functions                                           *
;  *                                                                                                                 *
;  ****************************************************************************/

Procedure cryptDeviceOpen(pDevice.l, cryptUser.l, deviceType.l, zName.s)
ProcedureReturn CallFunctionFast(*cryptDeviceOpen,  pDevice.l, cryptUser.l, deviceType.l, @zName)
EndProcedure

Procedure cryptDeviceClose(device.l)
ProcedureReturn CallFunctionFast(*cryptDeviceClose,  device.l)
EndProcedure

Procedure cryptDeviceQueryCapability(device.l, cryptAlgo.l, pCryptQueryInfo) ;pCryptQueryInfo.CRYPT_QUERY_INFO
ProcedureReturn CallFunctionFast(*cryptDeviceQueryCapability,  device.l, cryptAlgo.l, pCryptQueryInfo)
EndProcedure

Procedure cryptDeviceCreateContext(device.l, pContext.l, cryptAlgo.l)
ProcedureReturn CallFunctionFast(*cryptDeviceCreateContext,  device.l, pContext.l, cryptAlgo.l)
EndProcedure

;  /****************************************************************************
;  *                                                                                                                 *
;  *                                          User Management Functions                                   *
;  *                                                                                                                 *    
;  ****************************************************************************/

Procedure cryptLogin(pUser.l, zName.s, zPassword.s)
ProcedureReturn CallFunctionFast(*cryptLogin,  pUser.l, @zName, @zPassword)
EndProcedure

Procedure cryptLogout(user.l)
ProcedureReturn CallFunctionFast(*cryptLogout,  user.l)
EndProcedure

;  /****************************************************************************
;  *                                                                                                                 *
;  *                                          User Interface Functions                                   *
;  *                                                                                                                 *
;  ****************************************************************************/

Procedure cryptUIGenerateKey(CryptDevice.l, CryptContext.l, CryptCert.l, zPassword.s, hWnd.l)
ProcedureReturn CallFunctionFast(*cryptUIGenerateKey,  CryptDevice.l, CryptContext.l, CryptCert.l, @zPassword, hWnd.l)
EndProcedure

Procedure cryptUIDisplayCert(CryptCert.l, hWnd.l)
ProcedureReturn CallFunctionFast(*cryptUIDisplayCert,  CryptCert.l, hWnd.l)
EndProcedure


; IDE Options = PureBasic 5.31 (Windows - x86)
; CursorPosition = 15
; Folding = -----------
; EnableXP