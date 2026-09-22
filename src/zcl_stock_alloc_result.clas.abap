CLASS zcl_stock_alloc_result DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS validate
      IMPORTING allocations TYPE zif_stock_alloc_types=>ty_allocations
      RAISING zcx_stock_alloc.
ENDCLASS.

CLASS zcl_stock_alloc_result IMPLEMENTATION.
  METHOD validate.
    DATA seen TYPE HASHED TABLE OF zif_stock_alloc_types=>ty_allocation WITH UNIQUE KEY request_id.
    LOOP AT allocations INTO DATA(allocation).
      IF allocation-request_id IS INITIAL OR allocation-material IS INITIAL
          OR allocation-plant IS INITIAL OR allocation-storage IS INITIAL
          OR allocation-unit IS INITIAL OR allocation-required_date IS INITIAL
          OR allocation-requested <= 0 OR allocation-allocated < 0
          OR allocation-allocated > allocation-requested.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Invalid allocation key, date or quantity'.
      ENDIF.
      DATA expected_shortage TYPE zif_stock_alloc_types=>ty_quantity.
      expected_shortage = allocation-requested - allocation-allocated.
      IF allocation-shortage <> expected_shortage.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Invalid allocation shortage'.
      ENDIF.
      zcl_stock_alloc_date=>validate( allocation-required_date ).
      zcl_stock_alloc_origin=>validate( allocation-origin ).
      INSERT allocation INTO TABLE seen.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Duplicate allocation { allocation-request_id }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
