CLASS zcl_alloc_planned_order DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS proposal
      IMPORTING
        iv_net_req         TYPE i
        iv_lot_size        TYPE i
      RETURNING
        VALUE(rv_quantity) TYPE i.

    METHODS is_needed
      IMPORTING
        iv_net_req   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS quantity
      IMPORTING
        iv_net_req         TYPE i
        iv_min_order       TYPE i
      RETURNING
        VALUE(rv_quantity) TYPE i.

ENDCLASS.


CLASS zcl_alloc_planned_order IMPLEMENTATION.

  METHOD proposal.
    " A lot size rounds the net requirement up to whole lots; without one the
    " proposal is the net requirement itself.
    IF iv_net_req <= 0.
      RETURN.
    ENDIF.

    IF iv_lot_size <= 0.
      rv_quantity = iv_net_req.
      RETURN.
    ENDIF.

    rv_quantity = ( iv_net_req + iv_lot_size - 1 ) DIV iv_lot_size * iv_lot_size.
  ENDMETHOD.

  METHOD is_needed.
    rv_ok = xsdbool( iv_net_req > 0 ).
  ENDMETHOD.

  METHOD quantity.
    " The order quantity respects the minimum order size.
    IF iv_net_req <= 0.
      RETURN.
    ENDIF.

    IF iv_net_req < iv_min_order.
      rv_quantity = iv_min_order.
    ELSE.
      rv_quantity = iv_net_req.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
