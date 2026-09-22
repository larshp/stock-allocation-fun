FUNCTION bapi_goodsmvt_create.
  CLEAR goodsmvt_headret.
  APPEND VALUE #( type = 'E' id = '00' number = '001'
                  message = 'SAP goods movement BAPI is unavailable in the local stub' ) TO return.
ENDFUNCTION.
