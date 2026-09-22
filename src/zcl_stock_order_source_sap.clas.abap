CLASS zcl_stock_order_source_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_order_source.
ENDCLASS.

CLASS zcl_stock_order_source_sap IMPLEMENTATION.
  METHOD zif_stock_order_source~read.
    zcl_stock_order_policy=>validate( orders       = orders
                                      through_date = through_date
                                      from_date    = from_date ).
    IF orders IS INITIAL.
      RETURN.
    ENDIF.
    DATA selected TYPE HASHED TABLE OF zif_stock_order_source=>ty_order WITH UNIQUE KEY order_id.
    selected = orders.
    DATA components TYPE STANDARD TABLE OF resb WITH DEFAULT KEY.
    SELECT rsnum, rspos, rsart, aufnr, matnr, werks, lgort, meins, bdmng, enmng, bdter
        FROM resb
        FOR ALL ENTRIES IN @orders
        WHERE aufnr = @orders-order_id
          AND xloek = @space
          AND kzear = @space
          AND shkzg = 'H'
          AND sobkz = @space
          AND bdter <= @through_date
          AND bdter >= @from_date
        INTO CORRESPONDING FIELDS OF TABLE @components.
    LOOP AT components INTO DATA(component).
        READ TABLE selected INTO DATA(order) WITH TABLE KEY order_id = component-aufnr.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_stock_alloc
            EXPORTING reason = 'Order read returned an unselected order'.
        ENDIF.
        IF component-bdmng < 0 OR component-enmng < 0.
          RAISE EXCEPTION TYPE zcx_stock_alloc
            EXPORTING reason = 'Negative order component quantities require investigation'.
        ENDIF.
        IF component-bdmng <= component-enmng.
          CONTINUE.
        ENDIF.
        APPEND VALUE #( request_id    = |{ component-rsnum }/{ component-rspos }/{ component-rsart }|
                        material      = component-matnr
                        plant         = component-werks
                        storage       = component-lgort
                        unit          = component-meins
                        quantity      = component-bdmng - component-enmng
                        required_date = component-bdter
                        origin        = VALUE #( order_id         = order-order_id
                                                 reservation      = component-rsnum
                                                 reservation_item = component-rspos
                                                 reservation_type = component-rsart )
                        priority      = order-priority
                        allow_partial = order-allow_partial ) TO requests.
    ENDLOOP.
    DATA(validator) = NEW zcl_stock_allocator( ).
    validator->validate( stocks   = VALUE #( )
                         requests = requests ).
    SORT requests BY priority required_date request_id.
  ENDMETHOD.
ENDCLASS.
