CLASS zcl_alloc_correlation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    METHODS calculate
      IMPORTING
        it_x                  TYPE ty_series_tt
        it_y                  TYPE ty_series_tt
      RETURNING
        VALUE(rv_corr_x10000) TYPE i.

ENDCLASS.


CLASS zcl_alloc_correlation IMPLEMENTATION.

  METHOD calculate.
    DATA lo_root   TYPE REF TO zcl_alloc_safety_level.
    DATA lv_count  TYPE i.
    DATA lv_pos    TYPE i.
    DATA lv_sx     TYPE menge_d.
    DATA lv_sy     TYPE menge_d.
    DATA lv_sxx    TYPE menge_d.
    DATA lv_syy    TYPE menge_d.
    DATA lv_sxy    TYPE menge_d.
    DATA lv_num    TYPE menge_d.
    DATA lv_dx     TYPE menge_d.
    DATA lv_dy     TYPE menge_d.
    DATA lv_den    TYPE menge_d.
    DATA lv_r2     TYPE menge_d.
    DATA lv_scaled TYPE i.

    lv_count = lines( it_x ).
    IF lv_count < 2 OR lines( it_y ) < lv_count.
      RETURN.
    ENDIF.

    WHILE lv_pos < lv_count.
      lv_pos = lv_pos + 1.

      READ TABLE it_x INTO DATA(lv_x) INDEX lv_pos.
      READ TABLE it_y INTO DATA(lv_y) INDEX lv_pos.

      lv_sx = lv_sx + lv_x.
      lv_sy = lv_sy + lv_y.
      lv_sxx = lv_sxx + lv_x * lv_x.
      lv_syy = lv_syy + lv_y * lv_y.
      lv_sxy = lv_sxy + lv_x * lv_y.
    ENDWHILE.

    lv_num = lv_count * lv_sxy - lv_sx * lv_sy.
    lv_dx = lv_count * lv_sxx - lv_sx * lv_sx.
    lv_dy = lv_count * lv_syy - lv_sy * lv_sy.
    lv_den = lv_dx * lv_dy.

    IF lv_den <= 0.
      RETURN.
    ENDIF.

    " The square of the correlation is exact in ten-thousandths, the sign
    " comes from the covariance, and the square root is an integer one.
    lv_r2 = lv_num * lv_num * 10000 DIV lv_den.
    IF lv_r2 > 10000.
      lv_r2 = 10000.
    ENDIF.

    lv_scaled = lv_r2 * 10000.
    IF lv_scaled > 100000000.
      lv_scaled = 100000000.
    ENDIF.

    lo_root = NEW zcl_alloc_safety_level( ).
    rv_corr_x10000 = lo_root->sqrt_of( iv_value = lv_scaled ).

    IF lv_num < 0.
      rv_corr_x10000 = 0 - rv_corr_x10000.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
