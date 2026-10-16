CLASS zcl_alloc_pallet_round DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS pallets
      IMPORTING
        iv_quantity       TYPE i
        iv_per_pallet     TYPE i
      RETURNING
        VALUE(rv_pallets) TYPE i.

    METHODS remainder
      IMPORTING
        iv_quantity    TYPE i
        iv_per_pallet  TYPE i
      RETURNING
        VALUE(rv_rest) TYPE i.

    METHODS is_full
      IMPORTING
        iv_quantity   TYPE i
        iv_per_pallet TYPE i
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_pallet_round IMPLEMENTATION.

  METHOD pallets.
    " The quantity is spread over whole pallets, the last one possibly partial.
    IF iv_per_pallet <= 0.
      RETURN.
    ENDIF.

    rv_pallets = ( iv_quantity + iv_per_pallet - 1 ) DIV iv_per_pallet.
  ENDMETHOD.

  METHOD remainder.
    " The remainder sits on the last, partly filled pallet.
    IF iv_per_pallet <= 0.
      RETURN.
    ENDIF.

    rv_rest = iv_quantity MOD iv_per_pallet.
  ENDMETHOD.

  METHOD is_full.
    " The last pallet is only full when the quantity is a whole multiple.
    rv_ok = xsdbool( iv_per_pallet > 0
                     AND iv_quantity MOD iv_per_pallet = 0 ).
  ENDMETHOD.

ENDCLASS.
