CLASS zcl_stock_alloc_origin DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS validate
      IMPORTING origin TYPE zif_stock_alloc_types=>ty_origin
      RAISING zcx_stock_alloc.
    CLASS-METHODS require_independent
      IMPORTING allocations TYPE zif_stock_alloc_types=>ty_allocations
      RAISING zcx_stock_alloc.
    CLASS-METHODS require_reserved
      IMPORTING allocations TYPE zif_stock_alloc_types=>ty_allocations
      RAISING zcx_stock_alloc.
ENDCLASS.

CLASS zcl_stock_alloc_origin IMPLEMENTATION.
  METHOD require_reserved.
    DATA seen TYPE HASHED TABLE OF zif_stock_alloc_types=>ty_origin
      WITH UNIQUE KEY reservation reservation_item reservation_type.
    LOOP AT allocations INTO DATA(allocation).
      validate( allocation-origin ).
      IF allocation-origin-reservation IS INITIAL OR allocation-origin-reservation_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Reservation reference is required for { allocation-request_id }|.
      ENDIF.
      INSERT allocation-origin INTO TABLE seen.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Duplicate reservation item in goods issue'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate.
    IF ( origin-reservation IS INITIAL AND origin-reservation_item IS NOT INITIAL )
        OR ( origin-reservation IS NOT INITIAL AND origin-reservation_item IS INITIAL )
        OR ( origin-reservation IS INITIAL AND origin-reservation_type IS NOT INITIAL ).
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'Incomplete reservation origin'.
    ENDIF.
  ENDMETHOD.

  METHOD require_independent.
    LOOP AT allocations INTO DATA(allocation).
      validate( allocation-origin ).
      IF allocation-origin-order_id IS NOT INITIAL OR allocation-origin-reservation IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Referenced demand requires its order or reservation processing path'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
