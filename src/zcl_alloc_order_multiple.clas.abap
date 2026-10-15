CLASS zcl_alloc_order_multiple DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS align
      IMPORTING
        iv_quantity     TYPE i
        iv_multiple     TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS remainder
      IMPORTING
        iv_quantity    TYPE i
        iv_multiple    TYPE i
      RETURNING
        VALUE(rv_rest) TYPE i.

    METHODS is_aligned
      IMPORTING
        iv_quantity  TYPE i
        iv_multiple  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_order_multiple IMPLEMENTATION.

  METHOD align.
    " The quantity is raised to the next whole multiple.
    IF iv_multiple <= 0.
      rv_value = iv_quantity.
      RETURN.
    ENDIF.

    rv_value = ( iv_quantity + iv_multiple - 1 ) DIV iv_multiple * iv_multiple.
  ENDMETHOD.

  METHOD remainder.
    " The remainder is what the quantity leaves over the last whole multiple.
    IF iv_multiple <= 0.
      RETURN.
    ENDIF.

    rv_rest = iv_quantity MOD iv_multiple.
  ENDMETHOD.

  METHOD is_aligned.
    " A quantity is aligned when nothing remains over.
    rv_ok = xsdbool( iv_multiple > 0
                     AND iv_quantity MOD iv_multiple = 0 ).
  ENDMETHOD.

ENDCLASS.
