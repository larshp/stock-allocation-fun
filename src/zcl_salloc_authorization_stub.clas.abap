CLASS zcl_salloc_authorization_stub DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salloc_authorization.
    METHODS constructor IMPORTING iv_denied TYPE abap_bool DEFAULT abap_false.
  PRIVATE SECTION.
    DATA mv_denied TYPE abap_bool.
ENDCLASS.

CLASS zcl_salloc_authorization_stub IMPLEMENTATION.
  METHOD constructor.
    mv_denied = iv_denied.
  ENDMETHOD.

  METHOD zif_salloc_authorization~check_authorization.
    IF mv_denied = abap_true.
      RAISE EXCEPTION TYPE zcx_salloc_integration
        EXPORTING
          iv_operation = `AUTHORIZATION`
          iv_reason = `Configured authorization failure`.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
