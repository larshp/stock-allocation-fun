CLASS zcl_alloc_layer_status DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS status
      IMPORTING
        iv_remaining     TYPE i
        iv_original      TYPE i
      RETURNING
        VALUE(rv_status) TYPE string.

    METHODS is_empty
      IMPORTING
        iv_remaining TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS pending_qty
      IMPORTING
        iv_remaining      TYPE i
        iv_original       TYPE i
      RETURNING
        VALUE(rv_pending) TYPE i.

ENDCLASS.


CLASS zcl_alloc_layer_status IMPLEMENTATION.

  METHOD status.
    " A layer reads EMPTY, INTACT, PARTIAL or DEPLETED as it is consumed.
    IF iv_original <= 0.
      rv_status = 'EMPTY'.
    ELSEIF iv_remaining >= iv_original.
      rv_status = 'INTACT'.
    ELSEIF iv_remaining > 0.
      rv_status = 'PARTIAL'.
    ELSE.
      rv_status = 'DEPLETED'.
    ENDIF.
  ENDMETHOD.

  METHOD is_empty.
    " A layer is empty once nothing is left of it.
    rv_ok = xsdbool( iv_remaining <= 0 ).
  ENDMETHOD.

  METHOD pending_qty.
    " The pending part is what is still to be consumed, never negative.
    IF iv_remaining >= iv_original.
      RETURN.
    ENDIF.

    rv_pending = iv_original - iv_remaining.
  ENDMETHOD.

ENDCLASS.
