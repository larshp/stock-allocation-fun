CLASS zcl_alloc_forecast_ses DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS smooth
      IMPORTING
        it_values          TYPE ty_values_tt
        iv_alpha_percent   TYPE i
      RETURNING
        VALUE(rt_smoothed) TYPE ty_values_tt.

    METHODS next_value
      IMPORTING
        it_values        TYPE ty_values_tt
        iv_alpha_percent TYPE i
      RETURNING
        VALUE(rv_next)   TYPE i.

    METHODS history_count
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_forecast_ses IMPLEMENTATION.

  METHOD history_count.
    rv_count = lines( it_values ).
  ENDMETHOD.

  METHOD smooth.
    DATA lv_alpha TYPE i.
    DATA lv_level TYPE i.
    DATA lv_first TYPE abap_bool.

    " The smoothing factor is a percentage, held between nothing and everything.
    lv_alpha = iv_alpha_percent.
    IF lv_alpha < 0.
      lv_alpha = 0.
    ELSEIF lv_alpha > 100.
      lv_alpha = 100.
    ENDIF.

    " The first value seeds the level; each later value blends with it.
    LOOP AT it_values INTO DATA(lv_value).
      IF lv_first = abap_false.
        lv_first = abap_true.
        lv_level = lv_value.
      ELSE.
        lv_level = ( lv_alpha * lv_value
                     + ( 100 - lv_alpha ) * lv_level ) DIV 100.
      ENDIF.

      APPEND lv_level TO rt_smoothed.
    ENDLOOP.
  ENDMETHOD.

  METHOD next_value.
    DATA lt_smoothed TYPE ty_values_tt.

    lt_smoothed = smooth( it_values        = it_values
                          iv_alpha_percent = iv_alpha_percent ).

    " The last smoothed level is the forecast for the next period.
    LOOP AT lt_smoothed INTO DATA(lv_level).
      rv_next = lv_level.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
