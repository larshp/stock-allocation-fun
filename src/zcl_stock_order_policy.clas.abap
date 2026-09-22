CLASS zcl_stock_order_policy DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS validate
      IMPORTING orders       TYPE zif_stock_order_source=>ty_orders
                through_date TYPE d
                from_date    TYPE d DEFAULT '00010101'
      RAISING zcx_stock_alloc.
ENDCLASS.

CLASS zcl_stock_order_policy IMPLEMENTATION.
  METHOD validate.
    zcl_stock_alloc_date=>validate( through_date ).
    zcl_stock_alloc_date=>validate( from_date ).
    IF from_date > through_date.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'Order simulation start date is after its end date'.
    ENDIF.
    DATA seen TYPE HASHED TABLE OF zif_stock_order_source=>ty_order WITH UNIQUE KEY order_id.
    LOOP AT orders INTO DATA(order).
      IF order-order_id IS INITIAL OR order-priority < 0
          OR ( order-allow_partial <> abap_true AND order-allow_partial <> abap_false ).
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Invalid order selection or allocation policy'.
      ENDIF.
      INSERT order INTO TABLE seen.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Duplicate order selection { order-order_id }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
