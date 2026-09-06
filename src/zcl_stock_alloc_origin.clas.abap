CLASS zcl_stock_alloc_origin DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS validate
      IMPORTING origin TYPE zif_stock_alloc_types=>ty_origin
      RAISING zcx_stock_alloc.
    CLASS-METHODS require_independent
      IMPORTING allocations TYPE zif_stock_alloc_types=>ty_allocations
      RAISING zcx_stock_alloc.
ENDCLASS.

CLASS zcl_stock_alloc_origin IMPLEMENTATION.
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
