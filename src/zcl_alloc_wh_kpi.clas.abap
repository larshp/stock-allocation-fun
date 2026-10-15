CLASS zcl_alloc_wh_kpi DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_kpi,
             name   TYPE string,
             value  TYPE i,
             target TYPE i,
             unit   TYPE string,
           END OF ty_kpi.
    TYPES ty_kpi_tt TYPE STANDARD TABLE OF ty_kpi WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_card,
             name        TYPE string,
             value       TYPE i,
             target      TYPE i,
             unit        TYPE string,
             on_target   TYPE abap_bool,
             achievement TYPE i,
           END OF ty_card.
    TYPES ty_card_tt TYPE STANDARD TABLE OF ty_card WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_kpis        TYPE ty_kpi_tt
      RETURNING
        VALUE(rt_card) TYPE ty_card_tt.

    METHODS on_target_count
      IMPORTING
        it_card         TYPE ty_card_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_wh_kpi IMPLEMENTATION.

  METHOD build.
    DATA ls_card TYPE ty_card.

    " Every KPI on this card is higher-is-better. A target of zero means none was
    " set, so the card reports no target and an achievement of zero.
    LOOP AT it_kpis INTO DATA(ls_kpi).
      CLEAR ls_card.
      ls_card-name = ls_kpi-name.
      ls_card-value = ls_kpi-value.
      ls_card-target = ls_kpi-target.
      ls_card-unit = ls_kpi-unit.

      IF ls_kpi-target > 0.
        ls_card-achievement = ls_kpi-value * 100 DIV ls_kpi-target.
        ls_card-on_target = xsdbool( ls_kpi-value >= ls_kpi-target ).
      ENDIF.

      APPEND ls_card TO rt_card.
    ENDLOOP.
  ENDMETHOD.

  METHOD on_target_count.
    LOOP AT it_card INTO DATA(ls_card).
      IF ls_card-on_target = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
