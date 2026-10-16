CLASS zcl_alloc_return_margin DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             refund TYPE i,
             cost   TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS impact
      IMPORTING
        iv_refund        TYPE i
        iv_cost          TYPE i
      RETURNING
        VALUE(rv_impact) TYPE i.

    METHODS margin_percent
      IMPORTING
        iv_refund     TYPE i
        iv_cost       TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS total
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rv_impact) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_margin IMPLEMENTATION.

  METHOD impact.
    " The margin given away is what was refunded minus what the goods cost; it is
    " positive when the customer was refunded more than the goods are worth, and
    " negative when the refund was less than cost.
    rv_impact = iv_refund - iv_cost.
  ENDMETHOD.

  METHOD margin_percent.
    IF iv_refund <= 0.
      RETURN.
    ENDIF.

    rv_pct = impact( iv_refund = iv_refund
                     iv_cost   = iv_cost ) * 100 DIV iv_refund.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_impact = rv_impact + impact( iv_refund = ls_line-refund
                                      iv_cost   = ls_line-cost ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
