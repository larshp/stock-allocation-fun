CLASS zcl_alloc_deeplink DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        iv_base        TYPE string
        it_params      TYPE zcl_alloc_query=>ty_param_tt
      RETURNING
        VALUE(rv_link) TYPE string.

    METHODS is_absolute
      IMPORTING
        iv_link       TYPE string
      RETURNING
        VALUE(rv_abs) TYPE abap_bool.

  PRIVATE SECTION.
    CONSTANTS c_scheme TYPE string VALUE 'http'.
    CONSTANTS c_sep    TYPE string VALUE '?'.

ENDCLASS.


CLASS zcl_alloc_deeplink IMPLEMENTATION.

  METHOD build.
    DATA lo_query TYPE REF TO zcl_alloc_query.
    DATA lv_query TYPE string.

    rv_link = iv_base.

    lo_query = NEW zcl_alloc_query( ).
    lv_query = lo_query->build( it_params ).

    IF strlen( lv_query ) = 0.
      RETURN.
    ENDIF.

    rv_link = rv_link && c_sep.
    rv_link = rv_link && lv_query.
  ENDMETHOD.

  METHOD is_absolute.
    DATA lv_head TYPE string.

    IF strlen( iv_link ) < 4.
      RETURN.
    ENDIF.

    lv_head = substring( val = iv_link off = 0 len = 4 ).

    IF lv_head = c_scheme.
      rv_abs = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
