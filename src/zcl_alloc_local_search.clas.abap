CLASS zcl_alloc_local_search DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_option,
             slot_id   TYPE string,
             option_id TYPE string,
             cost      TYPE menge_d,
           END OF ty_option.
    TYPES ty_option_tt TYPE STANDARD TABLE OF ty_option WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_choice,
             slot_id   TYPE string,
             option_id TYPE string,
             cost      TYPE menge_d,
           END OF ty_choice.
    TYPES ty_choice_tt TYPE STANDARD TABLE OF ty_choice WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_slot,
             id TYPE string,
           END OF ty_slot.
    TYPES ty_slot_tt TYPE STANDARD TABLE OF ty_slot WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_lookup,
             found TYPE abap_bool,
             cost  TYPE menge_d,
           END OF ty_lookup.

    TYPES: BEGIN OF ty_result,
             choices    TYPE ty_choice_tt,
             total_cost TYPE menge_d,
             steps      TYPE i,
             swaps      TYPE i,
             improved   TYPE abap_bool,
           END OF ty_result.

    METHODS improve
      IMPORTING
        it_options       TYPE ty_option_tt
        iv_max_steps     TYPE i
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    METHODS lookup
      IMPORTING
        it_options      TYPE ty_option_tt
        iv_slot         TYPE string
        iv_option       TYPE string
      RETURNING
        VALUE(rs_found) TYPE ty_lookup.

    METHODS build_slots
      IMPORTING
        it_options      TYPE ty_option_tt
      RETURNING
        VALUE(rt_slots) TYPE ty_slot_tt.

    METHODS is_used
      IMPORTING
        it_choices     TYPE ty_choice_tt
        iv_option      TYPE string
      RETURNING
        VALUE(rv_used) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_local_search IMPLEMENTATION.

  METHOD lookup.
    READ TABLE it_options INTO DATA(ls_option)
      WITH KEY slot_id = iv_slot option_id = iv_option.

    IF sy-subrc = 0.
      rs_found-found = abap_true.
      rs_found-cost = ls_option-cost.
    ENDIF.
  ENDMETHOD.

  METHOD build_slots.
    DATA ls_slot TYPE ty_slot.

    LOOP AT it_options INTO DATA(ls_option).
      READ TABLE rt_slots INTO ls_slot WITH KEY id = ls_option-slot_id.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_slot.
      ls_slot-id = ls_option-slot_id.
      APPEND ls_slot TO rt_slots.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_used.
    READ TABLE it_choices INTO DATA(ls_choice) WITH KEY option_id = iv_option.

    IF sy-subrc = 0.
      rv_used = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD improve.
    DATA lt_slots    TYPE ty_slot_tt.
    DATA lt_choices  TYPE ty_choice_tt.
    DATA ls_slot_a   TYPE ty_slot.
    DATA ls_slot_b   TYPE ty_slot.
    DATA ls_best     TYPE ty_choice.
    DATA ls_a        TYPE ty_choice.
    DATA ls_b        TYPE ty_choice.
    DATA ls_new      TYPE ty_choice.
    DATA ls_lookup_a TYPE ty_lookup.
    DATA ls_lookup_b TYPE ty_lookup.
    DATA lv_count    TYPE i.
    DATA lv_i        TYPE i.
    DATA lv_j        TYPE i.
    DATA lv_best     TYPE menge_d.
    DATA lv_first    TYPE abap_bool.
    DATA lv_cur      TYPE menge_d.
    DATA lv_swap     TYPE menge_d.
    DATA lv_any      TYPE abap_bool.

    lt_slots = build_slots( it_options ).

    LOOP AT lt_slots INTO DATA(ls_slot).
      CLEAR ls_best.
      lv_best = 0.
      lv_first = abap_true.

      LOOP AT it_options INTO DATA(ls_option).
        IF ls_option-slot_id <> ls_slot-id.
          CONTINUE.
        ENDIF.
        IF is_used( it_choices = lt_choices iv_option = ls_option-option_id )
           = abap_true.
          CONTINUE.
        ENDIF.

        IF lv_first = abap_true OR ls_option-cost < lv_best.
          lv_best = ls_option-cost.
          ls_best-option_id = ls_option-option_id.
          ls_best-cost = ls_option-cost.
          lv_first = abap_false.
        ENDIF.
      ENDLOOP.

      IF lv_first = abap_false.
        ls_best-slot_id = ls_slot-id.
        APPEND ls_best TO lt_choices.
      ENDIF.
    ENDLOOP.

    lv_count = lines( lt_slots ).

    DO iv_max_steps TIMES.
      rs_result-steps = rs_result-steps + 1.

      lv_i = 1.
      WHILE lv_i < lv_count.
        lv_j = lv_i + 1.

        WHILE lv_j <= lv_count.
          READ TABLE lt_slots INTO ls_slot_a INDEX lv_i.
          READ TABLE lt_slots INTO ls_slot_b INDEX lv_j.

          READ TABLE lt_choices INTO ls_a WITH KEY slot_id = ls_slot_a-id.
          READ TABLE lt_choices INTO ls_b WITH KEY slot_id = ls_slot_b-id.

          ls_lookup_a = lookup( it_options = it_options
                                iv_slot    = ls_slot_a-id
                                iv_option  = ls_b-option_id ).
          ls_lookup_b = lookup( it_options = it_options
                                iv_slot    = ls_slot_b-id
                                iv_option  = ls_a-option_id ).

          IF ls_lookup_a-found = abap_true AND ls_lookup_b-found = abap_true.
            lv_cur = ls_a-cost + ls_b-cost.
            lv_swap = ls_lookup_a-cost + ls_lookup_b-cost.

            IF lv_swap < lv_cur.
              CLEAR ls_new.
              ls_new-slot_id = ls_slot_a-id.
              ls_new-option_id = ls_b-option_id.
              ls_new-cost = ls_lookup_a-cost.
              DELETE lt_choices WHERE slot_id = ls_slot_a-id.
              APPEND ls_new TO lt_choices.

              CLEAR ls_new.
              ls_new-slot_id = ls_slot_b-id.
              ls_new-option_id = ls_a-option_id.
              ls_new-cost = ls_lookup_b-cost.
              DELETE lt_choices WHERE slot_id = ls_slot_b-id.
              APPEND ls_new TO lt_choices.

              rs_result-swaps = rs_result-swaps + 1.
              lv_any = abap_true.
            ENDIF.
          ENDIF.

          lv_j = lv_j + 1.
        ENDWHILE.

        lv_i = lv_i + 1.
      ENDWHILE.
    ENDDO.

    LOOP AT lt_slots INTO ls_slot.
      READ TABLE lt_choices INTO ls_a WITH KEY slot_id = ls_slot-id.
      IF sy-subrc = 0.
        APPEND ls_a TO rs_result-choices.
        rs_result-total_cost = rs_result-total_cost + ls_a-cost.
      ENDIF.
    ENDLOOP.

    IF lv_any = abap_true.
      rs_result-improved = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
