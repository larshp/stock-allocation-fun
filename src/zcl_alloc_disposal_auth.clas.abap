CLASS zcl_alloc_disposal_auth DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_authorised
      IMPORTING
        iv_role         TYPE string
        iv_hazard_class TYPE string
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

    METHODS reason
      IMPORTING
        iv_role          TYPE string
        iv_hazard_class  TYPE string
      RETURNING
        VALUE(rv_reason) TYPE string.

    METHODS needs_second
      IMPORTING
        iv_hazard_class TYPE string
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_disposal_auth IMPLEMENTATION.

  METHOD is_authorised.
    " A manager may authorise any disposal; a clerk only a non-hazardous one.
    IF iv_role IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_role = 'MANAGER'.
      rv_ok = abap_true.
    ELSEIF iv_role = 'CLERK'.
      rv_ok = xsdbool( iv_hazard_class IS INITIAL
                       OR iv_hazard_class = 'NONE' ).
    ENDIF.
  ENDMETHOD.

  METHOD reason.
    IF iv_role IS INITIAL.
      rv_reason = 'NO_ROLE'.
    ELSEIF is_authorised( iv_role         = iv_role
                          iv_hazard_class = iv_hazard_class ) = abap_true.
      rv_reason = 'OK'.
    ELSE.
      rv_reason = 'NOT_AUTHORISED'.
    ENDIF.
  ENDMETHOD.

  METHOD needs_second.
    " The toxic and corrosive classes need a second signature.
    rv_ok = xsdbool( iv_hazard_class = 'HAZ_6' OR iv_hazard_class = 'HAZ_8' ).
  ENDMETHOD.

ENDCLASS.
