CLASS zcl_salloc_allocator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS allocate
      IMPORTING
        iv_available TYPE zif_salloc_types=>ty_quantity
      CHANGING
        ct_demands TYPE zif_salloc_types=>tt_demands
      RETURNING
        VALUE(rv_remaining) TYPE zif_salloc_types=>ty_quantity
      RAISING
        zcx_salloc_invalid.
ENDCLASS.

CLASS zcl_salloc_allocator IMPLEMENTATION.
  METHOD allocate.
    IF iv_available < 0.
      RAISE EXCEPTION TYPE zcx_salloc_invalid
        EXPORTING iv_reason = `Available stock cannot be negative`.
    ENDIF.

    DATA order_ids TYPE SORTED TABLE OF zif_salloc_types=>ty_order_id
      WITH UNIQUE KEY table_line.

    LOOP AT ct_demands ASSIGNING FIELD-SYMBOL(<demand>).
      IF <demand>-order_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_salloc_invalid
          EXPORTING iv_reason = `Order ID is required`.
      ELSEIF <demand>-requested < 0.
        RAISE EXCEPTION TYPE zcx_salloc_invalid
          EXPORTING iv_reason = `Requested quantity cannot be negative`.
      ENDIF.

      INSERT <demand>-order_id INTO TABLE order_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_salloc_invalid
          EXPORTING iv_reason = `Duplicate order ID is not allowed`.
      ENDIF.
    ENDLOOP.

    SORT ct_demands BY priority DESCENDING requested_on order_id.
    rv_remaining = iv_available.

    LOOP AT ct_demands ASSIGNING <demand>.
      CLEAR <demand>-allocated.
      IF <demand>-requested <= rv_remaining.
        <demand>-allocated = <demand>-requested.
      ELSE.
        <demand>-allocated = rv_remaining.
      ENDIF.
      rv_remaining = rv_remaining - <demand>-allocated.
      <demand>-shortage = <demand>-requested - <demand>-allocated.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
