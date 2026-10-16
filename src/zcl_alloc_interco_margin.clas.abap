CLASS zcl_alloc_interco_margin DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS margin
      IMPORTING
        iv_transfer_price TYPE i
        iv_cost           TYPE i
      RETURNING
        VALUE(rv_margin)  TYPE i.

    METHODS is_eliminated
      IMPORTING
        iv_sold_externally TYPE abap_bool
      RETURNING
        VALUE(rv_ok)       TYPE abap_bool.

    METHODS percent
      IMPORTING
        iv_transfer_price TYPE i
        iv_cost           TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_interco_margin IMPLEMENTATION.

  METHOD margin.
    " The intercompany margin sits between the transfer price and the cost.
    rv_margin = iv_transfer_price - iv_cost.
  ENDMETHOD.

  METHOD is_eliminated.
    " The margin is eliminated while the goods have not left the group.
    rv_ok = xsdbool( iv_sold_externally = abap_false ).
  ENDMETHOD.

  METHOD percent.
    DATA lv_margin TYPE i.

    " The margin is related to the transfer price that carried it.
    IF iv_transfer_price = 0.
      RETURN.
    ENDIF.

    lv_margin = iv_transfer_price - iv_cost.
    rv_percent = lv_margin * 100 DIV iv_transfer_price.
  ENDMETHOD.

ENDCLASS.
