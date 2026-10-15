CLASS zcl_alloc_replenish_trend DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS direction
      IMPORTING
        it_values           TYPE ty_values_tt
      RETURNING
        VALUE(rv_direction) TYPE string.

    METHODS slope_sign
      IMPORTING
        it_values      TYPE ty_values_tt
      RETURNING
        VALUE(rv_sign) TYPE i.

    METHODS is_rising
      IMPORTING
        it_values    TYPE ty_values_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_replenish_trend IMPLEMENTATION.

  METHOD direction.
    DATA lv_count TYPE i.
    DATA lv_first TYPE i.
    DATA lv_last  TYPE i.

    " Fewer than two points cannot show a direction.
    lv_count = lines( it_values ).
    IF lv_count < 2.
      rv_direction = 'FLAT'.
      RETURN.
    ENDIF.

    READ TABLE it_values INTO lv_first INDEX 1.
    READ TABLE it_values INTO lv_last INDEX lv_count.

    IF lv_last > lv_first.
      rv_direction = 'RISING'.
    ELSEIF lv_last < lv_first.
      rv_direction = 'FALLING'.
    ELSE.
      rv_direction = 'FLAT'.
    ENDIF.
  ENDMETHOD.

  METHOD slope_sign.
    DATA lv_count TYPE i.
    DATA lv_first TYPE i.
    DATA lv_last  TYPE i.

    " The sign is one when rising, minus one when falling, zero when flat.
    lv_count = lines( it_values ).
    IF lv_count < 2.
      RETURN.
    ENDIF.

    READ TABLE it_values INTO lv_first INDEX 1.
    READ TABLE it_values INTO lv_last INDEX lv_count.

    IF lv_last > lv_first.
      rv_sign = 1.
    ELSEIF lv_last < lv_first.
      rv_sign = -1.
    ENDIF.
  ENDMETHOD.

  METHOD is_rising.
    DATA lv_direction TYPE string.

    " The series is rising when its first and last points say so.
    lv_direction = direction( it_values ).
    rv_ok = xsdbool( lv_direction = 'RISING' ).
  ENDMETHOD.

ENDCLASS.
