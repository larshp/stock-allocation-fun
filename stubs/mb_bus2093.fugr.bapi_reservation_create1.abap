FUNCTION bapi_reservation_create1.
  " Fail closed: this stub never pretends that SAP business processing succeeded.
  CLEAR reservation.
  APPEND VALUE #( type = 'E' id = '00' number = '001'
                  message = 'SAP reservation BAPI is unavailable in the local stub' ) TO return.
ENDFUNCTION.
