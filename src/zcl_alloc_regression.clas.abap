CLASS zcl_alloc_regression DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             slope_x1000 TYPE i,
             intercept   TYPE menge_d,
             points      TYPE i,
             rising      TYPE abap_bool,
           END OF ty_result.

    METHODS fit
      IMPORTING
        it_x             TYPE ty_series_tt
        it_y             TYPE ty_series_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_regression IMPLEMENTATION.

  METHOD fit.
    DATA lv_count TYPE i.
    DATA lv_pos   TYPE i.
    DATA lv_sx    TYPE menge_d.
    DATA lv_sy    TYPE menge_d.
    DATA lv_sxx   TYPE menge_d.
    DATA lv_sxy   TYPE menge_d.
    DATA lv_num   TYPE menge_d.
    DATA lv_den   TYPE menge_d.
    DATA lv_up    TYPE menge_d.
    DATA lv_down  TYPE menge_d.

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
      lv_sxy = lv_sxy + lv_x * lv_y.
    ENDWHILE.

    lv_num = lv_count * lv_sxy - lv_sx * lv_sy.
    lv_den = lv_count * lv_sxx - lv_sx * lv_sx.

    " A vertical set of points has no slope at all.
    IF lv_den = 0.
      RETURN.
    ENDIF.

    rs_result-points = lv_count.
    rs_result-slope_x1000 = lv_num * 1000 DIV lv_den.

    lv_up = lv_sy * 1000.
    lv_down = rs_result-slope_x1000 * lv_sx.
    rs_result-intercept = ( lv_up - lv_down ) DIV ( lv_count * 1000 ).

    IF rs_result-slope_x1000 > 0.
      rs_result-rising = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
