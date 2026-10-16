CLASS zcl_alloc_var_favourable DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS classify
      IMPORTING
        iv_variance     TYPE i
      RETURNING
        VALUE(rv_class) TYPE string.

    METHODS is_favourable
      IMPORTING
        iv_variance  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS is_adverse
      IMPORTING
        iv_variance  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_var_favourable IMPLEMENTATION.

  METHOD classify.
    " A variance below zero saves cost, above zero costs more.
    IF iv_variance < 0.
      rv_class = 'FAVOURABLE'.
    ELSEIF iv_variance > 0.
      rv_class = 'ADVERSE'.
    ELSE.
      rv_class = 'ZERO'.
    ENDIF.
  ENDMETHOD.

  METHOD is_favourable.
    " A saving is a variance below zero.
    rv_ok = xsdbool( iv_variance < 0 ).
  ENDMETHOD.

  METHOD is_adverse.
    " An overspend is a variance above zero.
    rv_ok = xsdbool( iv_variance > 0 ).
  ENDMETHOD.

ENDCLASS.
