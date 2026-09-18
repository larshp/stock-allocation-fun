CLASS zcl_alloc_crossdock DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_inbound,
             source_id TYPE string,
             quantity  TYPE menge_d,
             arrival   TYPE i,
           END OF ty_inbound.
    TYPES ty_inbound_tt TYPE STANDARD TABLE OF ty_inbound WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_outbound,
             target_id TYPE string,
             quantity  TYPE menge_d,
             departure TYPE i,
           END OF ty_outbound.
    TYPES ty_outbound_tt TYPE STANDARD TABLE OF ty_outbound
                         WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_move,
             source_id TYPE string,
             target_id TYPE string,
             quantity  TYPE menge_d,
             wait      TYPE i,
           END OF ty_move.
    TYPES ty_move_tt TYPE STANDARD TABLE OF ty_move WITH DEFAULT KEY.

    METHODS propose
      IMPORTING
        it_inbound      TYPE ty_inbound_tt
        it_outbound     TYPE ty_outbound_tt
      RETURNING
        VALUE(rt_moves) TYPE ty_move_tt.

    METHODS shortfall_of
      IMPORTING
        it_outbound     TYPE ty_outbound_tt
        it_moves        TYPE ty_move_tt
      RETURNING
        VALUE(rv_short) TYPE menge_d.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_rem,
             pos TYPE i,
             rem TYPE menge_d,
           END OF ty_rem.
    TYPES ty_rem_tt TYPE STANDARD TABLE OF ty_rem WITH DEFAULT KEY.

ENDCLASS.


CLASS zcl_alloc_crossdock IMPLEMENTATION.

  METHOD propose.
    DATA lt_in_rem  TYPE ty_rem_tt.
    DATA lt_out_rem TYPE ty_rem_tt.
    DATA ls_in_rem  TYPE ty_rem.
    DATA ls_out_rem TYPE ty_rem.
    DATA ls_move    TYPE ty_move.
    DATA ls_in      TYPE ty_inbound.
    DATA ls_out     TYPE ty_outbound.
    DATA lv_in      TYPE i.
    DATA lv_out     TYPE i.
    DATA lv_take    TYPE menge_d.

    LOOP AT it_inbound INTO ls_in.
      CLEAR ls_in_rem.
      ls_in_rem-pos = sy-tabix.
      ls_in_rem-rem = ls_in-quantity.
      APPEND ls_in_rem TO lt_in_rem.
    ENDLOOP.

    LOOP AT it_outbound INTO ls_out.
      CLEAR ls_out_rem.
      ls_out_rem-pos = sy-tabix.
      ls_out_rem-rem = ls_out-quantity.
      APPEND ls_out_rem TO lt_out_rem.
    ENDLOOP.

    lv_out = 0.
    LOOP AT it_outbound INTO ls_out.
      lv_out = lv_out + 1.

      READ TABLE lt_out_rem INTO ls_out_rem WITH KEY pos = lv_out.
      IF sy-subrc <> 0 OR ls_out_rem-rem <= 0.
        CONTINUE.
      ENDIF.

      lv_in = 0.
      LOOP AT it_inbound INTO ls_in.
        lv_in = lv_in + 1.

        IF ls_out_rem-rem <= 0.
          EXIT.
        ENDIF.

        READ TABLE lt_in_rem INTO ls_in_rem WITH KEY pos = lv_in.
        IF sy-subrc <> 0 OR ls_in_rem-rem <= 0.
          CONTINUE.
        ENDIF.

        " Only goods that are already unloaded can be cross-docked.
        IF ls_in-arrival > ls_out-departure.
          CONTINUE.
        ENDIF.

        IF ls_in_rem-rem < ls_out_rem-rem.
          lv_take = ls_in_rem-rem.
        ELSE.
          lv_take = ls_out_rem-rem.
        ENDIF.

        CLEAR ls_move.
        ls_move-source_id = ls_in-source_id.
        ls_move-target_id = ls_out-target_id.
        ls_move-quantity = lv_take.
        ls_move-wait = ls_out-departure - ls_in-arrival.
        APPEND ls_move TO rt_moves.

        ls_in_rem-rem = ls_in_rem-rem - lv_take.
        DELETE lt_in_rem WHERE pos = lv_in.
        APPEND ls_in_rem TO lt_in_rem.

        ls_out_rem-rem = ls_out_rem-rem - lv_take.
        DELETE lt_out_rem WHERE pos = lv_out.
        APPEND ls_out_rem TO lt_out_rem.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD shortfall_of.
    DATA lv_demand TYPE menge_d.
    DATA lv_moved  TYPE menge_d.

    LOOP AT it_outbound INTO DATA(ls_out).
      lv_demand = lv_demand + ls_out-quantity.
    ENDLOOP.

    LOOP AT it_moves INTO DATA(ls_move).
      lv_moved = lv_moved + ls_move-quantity.
    ENDLOOP.

    rv_short = lv_demand - lv_moved.
    IF rv_short < 0.
      rv_short = 0.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
