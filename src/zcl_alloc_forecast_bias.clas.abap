CLASS zcl_alloc_forecast_bias DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS bias
      IMPORTING
        it_actual      TYPE ty_values_tt
        it_forecast    TYPE ty_values_tt
      RETURNING
        VALUE(rv_bias) TYPE i.

    METHODS is_over
      IMPORTING
        iv_bias      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS magnitude
      IMPORTING
        iv_bias       TYPE i
      RETURNING
        VALUE(rv_mag) TYPE i.

ENDCLASS.


CLASS zcl_alloc_forecast_bias IMPLEMENTATION.

  METHOD bias.
    DATA lv_index TYPE i.

    " The bias is the running sum of the signed errors: positive means the
    " forecast ran low over the period.
    LOOP AT it_actual INTO DATA(lv_actual).
      lv_index = lv_index + 1.

      READ TABLE it_forecast INTO DATA(lv_forecast) INDEX lv_index.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      rv_bias = rv_bias + lv_actual - lv_forecast.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_over.
    rv_ok = xsdbool( iv_bias > 0 ).
  ENDMETHOD.

  METHOD magnitude.
    " The size of the bias is measured without the ABS built-in.
    IF iv_bias < 0.
      rv_mag = 0 - iv_bias.
    ELSE.
      rv_mag = iv_bias.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
