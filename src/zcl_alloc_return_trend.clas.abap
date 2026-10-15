CLASS zcl_alloc_return_trend DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS direction
      IMPORTING
        it_series     TYPE ty_series_tt
      RETURNING
        VALUE(rv_dir) TYPE string.

    METHODS slope_sign
      IMPORTING
        it_series      TYPE ty_series_tt
      RETURNING
        VALUE(rv_sign) TYPE i.

    METHODS is_rising
      IMPORTING
        it_series    TYPE ty_series_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_ends,
             first TYPE i,
             last  TYPE i,
           END OF ty_ends.

    METHODS ends
      IMPORTING
        it_series      TYPE ty_series_tt
      RETURNING
        VALUE(rs_ends) TYPE ty_ends.

ENDCLASS.


CLASS zcl_alloc_return_trend IMPLEMENTATION.

  METHOD ends.
    DATA lv_found TYPE abap_bool.

    " The first and last values of the series, with an empty series read as all
    " zeros, which leaves the direction flat.
    LOOP AT it_series INTO DATA(lv_value).
      IF lv_found = abap_false.
        rs_ends-first = lv_value.
        lv_found = abap_true.
      ENDIF.

      rs_ends-last = lv_value.
    ENDLOOP.
  ENDMETHOD.

  METHOD direction.
    DATA ls_ends TYPE ty_ends.

    ls_ends = ends( it_series ).

    IF ls_ends-last > ls_ends-first.
      rv_dir = 'UP'.
    ELSEIF ls_ends-last < ls_ends-first.
      rv_dir = 'DOWN'.
    ELSE.
      rv_dir = 'FLAT'.
    ENDIF.
  ENDMETHOD.

  METHOD slope_sign.
    DATA ls_ends TYPE ty_ends.

    ls_ends = ends( it_series ).

    IF ls_ends-last > ls_ends-first.
      rv_sign = 1.
    ELSEIF ls_ends-last < ls_ends-first.
      rv_sign = -1.
    ENDIF.
  ENDMETHOD.

  METHOD is_rising.
    rv_ok = xsdbool( direction( it_series ) = 'UP' ).
  ENDMETHOD.

ENDCLASS.
