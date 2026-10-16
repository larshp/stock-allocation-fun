CLASS zcl_alloc_replenish_confirm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_proposal,
             material  TYPE matnr,
             quantity  TYPE i,
             confirmed TYPE abap_bool,
           END OF ty_proposal.
    TYPES ty_proposal_tt TYPE STANDARD TABLE OF ty_proposal WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             quantity TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS confirm
      IMPORTING
        it_proposals        TYPE ty_proposal_tt
        iv_material         TYPE matnr
      RETURNING
        VALUE(rt_proposals) TYPE ty_proposal_tt.

    METHODS is_confirmed
      IMPORTING
        it_proposals TYPE ty_proposal_tt
        iv_material  TYPE matnr
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS convert_to_order
      IMPORTING
        it_proposals    TYPE ty_proposal_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_replenish_confirm IMPLEMENTATION.

  METHOD confirm.
    DATA ls_out TYPE ty_proposal.

    " Only the named material is marked as confirmed.
    LOOP AT it_proposals INTO DATA(ls_proposal).
      ls_out = ls_proposal.
      IF ls_proposal-material = iv_material.
        ls_out-confirmed = abap_true.
      ENDIF.
      APPEND ls_out TO rt_proposals.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_confirmed.
    " The material counts as confirmed once its flag is set.
    LOOP AT it_proposals INTO DATA(ls_proposal).
      IF ls_proposal-material = iv_material.
        rv_ok = ls_proposal-confirmed.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_to_order.
    DATA ls_line TYPE ty_line.

    " Only the confirmed proposals become order lines.
    LOOP AT it_proposals INTO DATA(ls_proposal).
      IF ls_proposal-confirmed = abap_true.
        ls_line-material = ls_proposal-material.
        ls_line-quantity = ls_proposal-quantity.
        APPEND ls_line TO rt_lines.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
