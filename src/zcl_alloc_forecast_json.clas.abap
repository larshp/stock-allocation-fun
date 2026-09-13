CLASS zcl_alloc_forecast_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             values TYPE zcl_alloc_forecast=>ty_qty_tt,
             window TYPE i,
           END OF ty_input.

    METHODS constructor.

    METHODS build
      IMPORTING
        is_input       TYPE ty_input
      RETURNING
        VALUE(rv_json) TYPE string.

  PRIVATE SECTION.
    DATA mo_forecast TYPE REF TO zcl_alloc_forecast.

ENDCLASS.


CLASS zcl_alloc_forecast_json IMPLEMENTATION.

  METHOD constructor.
    mo_forecast = NEW zcl_alloc_forecast( ).
  ENDMETHOD.

  METHOD build.
    DATA lv_first    TYPE abap_bool.
    DATA lv_forecast TYPE menge_d.

    lv_forecast = mo_forecast->next_quantity( it_quantities = is_input-values iv_window = is_input-window ).

    rv_json = '{'.
    rv_json = rv_json && |"forecast":{ lv_forecast },|.
    rv_json = rv_json && |"window":{ is_input-window },|.
    rv_json = rv_json && '"values":['.

    lv_first = abap_true.

    LOOP AT is_input-values INTO DATA(lv_quantity).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      rv_json = rv_json && |{ lv_quantity }|.
    ENDLOOP.

    rv_json = rv_json && ']}'.
  ENDMETHOD.

ENDCLASS.
