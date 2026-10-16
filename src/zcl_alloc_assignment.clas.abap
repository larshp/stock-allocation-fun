CLASS zcl_alloc_assignment DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_ids_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_used,
             id TYPE string,
           END OF ty_used.
    TYPES ty_used_tt TYPE STANDARD TABLE OF ty_used WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_pair,
             demand_id TYPE string,
             source_id TYPE string,
             cost      TYPE menge_d,
           END OF ty_pair.
    TYPES ty_pair_tt TYPE STANDARD TABLE OF ty_pair WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             demand_id TYPE string,
             source_id TYPE string,
             cost      TYPE menge_d,
             assigned  TYPE abap_bool,
           END OF ty_result.
    TYPES ty_result_tt TYPE STANDARD TABLE OF ty_result WITH DEFAULT KEY.

    METHODS solve
      IMPORTING
        it_demands       TYPE ty_ids_tt
        it_pairs         TYPE ty_pair_tt
      RETURNING
        VALUE(rt_result) TYPE ty_result_tt.

ENDCLASS.


CLASS zcl_alloc_assignment IMPLEMENTATION.

  METHOD solve.
    DATA lt_pairs  TYPE ty_pair_tt.
    DATA lt_used_s TYPE ty_used_tt.
    DATA lt_used_d TYPE ty_used_tt.
    DATA ls_result TYPE ty_result.
    DATA ls_used   TYPE ty_used.
    DATA lv_found  TYPE abap_bool.

    LOOP AT it_demands INTO DATA(lv_demand_id).
      lv_found = abap_false.

      lt_pairs = it_pairs.
      SORT lt_pairs BY cost ASCENDING.

      LOOP AT lt_pairs INTO DATA(ls_pair).
        IF ls_pair-demand_id <> lv_demand_id.
          CONTINUE.
        ENDIF.

        READ TABLE lt_used_d INTO ls_used
          WITH KEY id = ls_pair-demand_id.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.

        READ TABLE lt_used_s INTO ls_used
          WITH KEY id = ls_pair-source_id.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.

        CLEAR ls_result.
        ls_result-demand_id = ls_pair-demand_id.
        ls_result-source_id = ls_pair-source_id.
        ls_result-cost = ls_pair-cost.
        ls_result-assigned = abap_true.
        APPEND ls_result TO rt_result.

        CLEAR ls_used.
        ls_used-id = ls_pair-demand_id.
        APPEND ls_used TO lt_used_d.

        CLEAR ls_used.
        ls_used-id = ls_pair-source_id.
        APPEND ls_used TO lt_used_s.

        lv_found = abap_true.
        EXIT.
      ENDLOOP.

      IF lv_found = abap_false.
        CLEAR ls_result.
        ls_result-demand_id = lv_demand_id.
        APPEND ls_result TO rt_result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
