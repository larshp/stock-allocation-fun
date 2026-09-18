CLASS zcl_alloc_policy_cmp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_policy,
             policy_id TYPE string,
             stock     TYPE zcl_alloc_fill_sim=>ty_series_tt,
           END OF ty_policy.
    TYPES ty_policy_tt TYPE STANDARD TABLE OF ty_policy WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_row,
             policy_id TYPE string,
             fill_x100 TYPE i,
             served    TYPE menge_d,
             stockouts TYPE i,
             best      TYPE abap_bool,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    METHODS compare
      IMPORTING
        it_policies    TYPE ty_policy_tt
        it_demand      TYPE zcl_alloc_fill_sim=>ty_series_tt
      RETURNING
        VALUE(rt_rows) TYPE ty_row_tt.

ENDCLASS.


CLASS zcl_alloc_policy_cmp IMPLEMENTATION.

  METHOD compare.
    DATA lo_sim   TYPE REF TO zcl_alloc_fill_sim.
    DATA ls_input TYPE zcl_alloc_fill_sim=>ty_input.
    DATA ls_sim   TYPE zcl_alloc_fill_sim=>ty_result.
    DATA ls_row   TYPE ty_row.
    DATA lv_best  TYPE i.
    DATA lv_index TYPE i.

    lo_sim = NEW zcl_alloc_fill_sim( ).
    ls_input-demand = it_demand.

    LOOP AT it_policies INTO DATA(ls_policy).
      ls_input-stock = ls_policy-stock.
      ls_sim = lo_sim->simulate( ls_input ).

      CLEAR ls_row.
      ls_row-policy_id = ls_policy-policy_id.
      ls_row-fill_x100 = ls_sim-fill_x100.
      ls_row-served = ls_sim-served.
      ls_row-stockouts = ls_sim-stockouts.
      APPEND ls_row TO rt_rows.

      IF ls_row-fill_x100 > lv_best.
        lv_best = ls_row-fill_x100.
        lv_index = lines( rt_rows ).
      ENDIF.
    ENDLOOP.

    IF lv_index > 0.
      READ TABLE rt_rows ASSIGNING FIELD-SYMBOL(<ls_row>) INDEX lv_index.
      IF sy-subrc = 0.
        <ls_row>-best = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
