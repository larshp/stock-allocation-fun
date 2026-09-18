CLASS zcl_alloc_mape DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_pct_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS percentage_of
      IMPORTING
        it_forecast   TYPE zcl_alloc_mad=>ty_series_tt
        it_actual     TYPE zcl_alloc_mad=>ty_series_tt
      RETURNING
        VALUE(rt_pct) TYPE ty_pct_tt.

    METHODS calculate
      IMPORTING
        it_forecast    TYPE zcl_alloc_mad=>ty_series_tt
        it_actual      TYPE zcl_alloc_mad=>ty_series_tt
      RETURNING
        VALUE(rv_mape) TYPE i.

ENDCLASS.


CLASS zcl_alloc_mape IMPLEMENTATION.

  METHOD percentage_of.
    DATA lv_limit TYPE i.
    DATA lv_pos   TYPE i.
    DATA lv_diff  TYPE menge_d.

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

      APPEND lv_diff * 100 DIV lv_ac TO rt_pct.
    ENDWHILE.
  ENDMETHOD.

  METHOD calculate.
    DATA lt_pct   TYPE ty_pct_tt.
    DATA lv_sum   TYPE i.
    DATA lv_count TYPE i.

    lt_pct = percentage_of( it_forecast = it_forecast
                            it_actual   = it_actual ).

    lv_count = lines( lt_pct ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    LOOP AT lt_pct INTO DATA(lv_pct).
      lv_sum = lv_sum + lv_pct.
    ENDLOOP.

    rv_mape = lv_sum DIV lv_count.
  ENDMETHOD.

ENDCLASS.
