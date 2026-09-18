CLASS zcl_alloc_forecast_exc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_exception,
             position  TYPE i,
             forecast  TYPE menge_d,
             actual    TYPE menge_d,
             deviation TYPE i,
           END OF ty_exception.
    TYPES ty_exception_tt TYPE STANDARD TABLE OF ty_exception
                          WITH DEFAULT KEY.

    METHODS find
      IMPORTING
        it_forecast    TYPE zcl_alloc_mad=>ty_series_tt
        it_actual      TYPE zcl_alloc_mad=>ty_series_tt
        iv_threshold   TYPE i
      RETURNING
        VALUE(rt_list) TYPE ty_exception_tt.

ENDCLASS.


CLASS zcl_alloc_forecast_exc IMPLEMENTATION.

  METHOD find.
    DATA lv_limit  TYPE i.
    DATA lv_pos    TYPE i.
    DATA lv_diff   TYPE menge_d.
    DATA lv_dev    TYPE i.
    DATA ls_row    TYPE ty_exception.

    lv_limit = lines( it_forecast ).
    IF lines( it_actual ) < lv_limit.
      lv_limit = lines( it_actual ).
    ENDIF.

    lv_pos = 0.
    WHILE lv_pos < lv_limit.
      lv_pos = lv_pos + 1.

      READ TABLE it_forecast INTO DATA(lv_fc) INDEX lv_pos.
      READ TABLE it_actual INTO DATA(lv_ac) INDEX lv_pos.

      IF lv_ac <= 0.
        CONTINUE.
      ENDIF.

      lv_diff = lv_fc - lv_ac.
      IF lv_diff < 0.
        lv_diff = 0 - lv_diff.
      ENDIF.

      lv_dev = lv_diff * 100 DIV lv_ac.
      IF lv_dev <= iv_threshold.
        CONTINUE.
      ENDIF.

      CLEAR ls_row.
      ls_row-position = lv_pos.
      ls_row-forecast = lv_fc.
      ls_row-actual = lv_ac.
      ls_row-deviation = lv_dev.
      APPEND ls_row TO rt_list.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
