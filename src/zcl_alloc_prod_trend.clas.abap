CLASS zcl_alloc_prod_trend DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS direction
      IMPORTING
        iv_first         TYPE i
        iv_last          TYPE i
      RETURNING
        VALUE(rv_choice) TYPE string.

    METHODS is_rising
      IMPORTING
        iv_first     TYPE i
        iv_last      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS delta
      IMPORTING
        iv_first        TYPE i
        iv_last         TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_prod_trend IMPLEMENTATION.

  METHOD direction.
    " The trend reads up, down or flat.
    IF iv_last > iv_first.
      rv_choice = 'UP'.
    ELSEIF iv_last < iv_first.
      rv_choice = 'DOWN'.
    ELSE.
      rv_choice = 'FLAT'.
    ENDIF.
  ENDMETHOD.

  METHOD is_rising.
    " The trend is rising once the last value is higher.
    rv_ok = xsdbool( iv_last > iv_first ).
  ENDMETHOD.

  METHOD delta.
    " The delta is the last value less the first one.
    rv_delta = iv_last - iv_first.
  ENDMETHOD.

ENDCLASS.
