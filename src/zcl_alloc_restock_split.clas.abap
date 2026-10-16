CLASS zcl_alloc_restock_split DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_split,
             sellable TYPE i,
             blocked  TYPE i,
           END OF ty_split.

    METHODS split
      IMPORTING
        iv_quantity     TYPE i
        iv_blocked      TYPE i
      RETURNING
        VALUE(rs_split) TYPE ty_split.

    METHODS sellable
      IMPORTING
        iv_quantity        TYPE i
        iv_blocked         TYPE i
      RETURNING
        VALUE(rv_sellable) TYPE i.

    METHODS blocked
      IMPORTING
        iv_quantity       TYPE i
        iv_blocked        TYPE i
      RETURNING
        VALUE(rv_blocked) TYPE i.

ENDCLASS.


CLASS zcl_alloc_restock_split IMPLEMENTATION.

  METHOD blocked.
    " The blocked share is clamped into the quantity, so a bad figure can never
    " make the sellable share negative.
    IF iv_quantity <= 0 OR iv_blocked <= 0.
      RETURN.
    ENDIF.

    IF iv_blocked > iv_quantity.
      rv_blocked = iv_quantity.
    ELSE.
      rv_blocked = iv_blocked.
    ENDIF.
  ENDMETHOD.

  METHOD sellable.
    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    rv_sellable = iv_quantity - blocked( iv_quantity = iv_quantity
                                         iv_blocked  = iv_blocked ).
  ENDMETHOD.

  METHOD split.
    rs_split-blocked = blocked( iv_quantity = iv_quantity
                                iv_blocked  = iv_blocked ).
    rs_split-sellable = sellable( iv_quantity = iv_quantity
                                  iv_blocked  = iv_blocked ).
  ENDMETHOD.

ENDCLASS.
