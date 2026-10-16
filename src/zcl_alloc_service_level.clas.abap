CLASS zcl_alloc_service_level DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             matnr         TYPE matnr,
             requested_qty TYPE menge_d,
             allocated_qty TYPE menge_d,
           END OF ty_input.
    TYPES ty_input_tt TYPE STANDARD TABLE OF ty_input WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_level,
             matnr         TYPE matnr,
             requested_qty TYPE menge_d,
             allocated_qty TYPE menge_d,
             shortage_qty  TYPE menge_d,
             fill_rate_pct TYPE i,
             lines         TYPE i,
           END OF ty_level.
    TYPES ty_level_tt TYPE STANDARD TABLE OF ty_level WITH DEFAULT KEY.

    METHODS summarize
      IMPORTING
        it_lines         TYPE ty_input_tt
      RETURNING
        VALUE(rt_levels) TYPE ty_level_tt.

ENDCLASS.


CLASS zcl_alloc_service_level IMPLEMENTATION.

  METHOD summarize.
    DATA lt_work TYPE ty_input_tt.
    DATA ls_level TYPE ty_level.
    DATA lv_started TYPE abap_bool.

    lt_work = it_lines.
    SORT lt_work BY matnr ASCENDING.

    LOOP AT lt_work INTO DATA(ls_line).
      IF lv_started = abap_false OR ls_line-matnr <> ls_level-matnr.
        IF lv_started = abap_true.
          IF ls_level-requested_qty > 0.
            ls_level-fill_rate_pct = ls_level-allocated_qty * 100
              DIV ls_level-requested_qty.
          ENDIF.
          APPEND ls_level TO rt_levels.
        ENDIF.
        CLEAR ls_level.
        ls_level-matnr = ls_line-matnr.
        lv_started = abap_true.
      ENDIF.

      ls_level-requested_qty = ls_level-requested_qty + ls_line-requested_qty.
      ls_level-allocated_qty = ls_level-allocated_qty + ls_line-allocated_qty.
      ls_level-lines = ls_level-lines + 1.
    ENDLOOP.

    IF lv_started = abap_true.
      IF ls_level-requested_qty > 0.
        ls_level-fill_rate_pct = ls_level-allocated_qty * 100
          DIV ls_level-requested_qty.
      ENDIF.
      ls_level-shortage_qty = ls_level-requested_qty - ls_level-allocated_qty.
      APPEND ls_level TO rt_levels.
    ENDIF.

    LOOP AT rt_levels ASSIGNING FIELD-SYMBOL(<ls_level>).
      <ls_level>-shortage_qty = <ls_level>-requested_qty
        - <ls_level>-allocated_qty.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
