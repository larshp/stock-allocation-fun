CLASS zcl_alloc_forecast_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             values TYPE zcl_alloc_forecast=>ty_qty_tt,
             window TYPE i,
           END OF ty_input.

    METHODS constructor.

    METHODS build
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv      TYPE REF TO zcl_alloc_csv.
    DATA mo_forecast TYPE REF TO zcl_alloc_forecast.

ENDCLASS.


CLASS zcl_alloc_forecast_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
    mo_forecast = NEW zcl_alloc_forecast( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields   TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line     TYPE string.
    DATA lv_index    TYPE i.
    DATA lv_forecast TYPE menge_d.

    APPEND 'INDEX' TO lt_fields.
    APPEND 'QUANTITY' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT is_input-values INTO DATA(lv_quantity).
      lv_index = lv_index + 1.

      CLEAR lt_fields.
      APPEND |{ lv_index }| TO lt_fields.
      APPEND |{ lv_quantity }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.

    CLEAR lt_fields.
    APPEND 'FORECAST' TO lt_fields.

    lv_forecast = mo_forecast->next_quantity( it_quantities = is_input-values iv_window = is_input-window ).
    APPEND |{ lv_forecast }| TO lt_fields.

    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.
  ENDMETHOD.

ENDCLASS.
