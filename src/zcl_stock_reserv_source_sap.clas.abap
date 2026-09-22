CLASS zcl_stock_reserv_source_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_reservation_source.
ENDCLASS.

CLASS zcl_stock_reserv_source_sap IMPLEMENTATION.
  METHOD zif_stock_reservation_source~read.
    LOOP AT references INTO DATA(reference).
      zcl_stock_alloc_origin=>validate( reference ).
      IF reference-reservation IS INITIAL OR reference-reservation_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'A complete reservation key is required for reading'.
      ENDIF.
    ENDLOOP.
    DATA(keys) = references.
    SORT keys BY reservation reservation_item reservation_type.
    DELETE ADJACENT DUPLICATES FROM keys COMPARING reservation reservation_item reservation_type.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.
    DATA components TYPE STANDARD TABLE OF resb WITH DEFAULT KEY.
    SELECT rsnum, rspos, rsart, aufnr, matnr, werks, lgort, meins, bdmng, enmng, bdter
      FROM resb
      FOR ALL ENTRIES IN @keys
      WHERE rsnum = @keys-reservation
        AND rspos = @keys-reservation_item
        AND rsart = @keys-reservation_type
        AND xloek = @space
        AND kzear = @space
        AND shkzg = 'H'
        AND sobkz = @space
      INTO CORRESPONDING FIELDS OF TABLE @components.
    SORT components BY rsnum rspos rsart.
    LOOP AT components INTO DATA(component).
      IF component-bdmng < 0 OR component-enmng < 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Negative reservation quantities require investigation'.
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
                      origin        = VALUE #( order_id  = component-aufnr
                                        reservation      = component-rsnum
                                        reservation_item = component-rspos
                                        reservation_type = component-rsart ) ) TO requests.
    ENDLOOP.
    NEW zcl_stock_allocator( )->validate( stocks   = VALUE #( )
                                          requests = requests ).
  ENDMETHOD.
ENDCLASS.
