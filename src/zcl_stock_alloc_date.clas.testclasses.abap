CLASS ltcl_date DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS accepts_valid_dates FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_invalid_dates FOR TESTING.
ENDCLASS.

CLASS ltcl_date IMPLEMENTATION.
  METHOD accepts_valid_dates.
    zcl_stock_alloc_date=>validate( '20000229' ).
    zcl_stock_alloc_date=>validate( '20240229' ).
    zcl_stock_alloc_date=>validate( '20260930' ).
    zcl_stock_alloc_date=>validate( '00010101' ).
    zcl_stock_alloc_date=>validate( '99991231' ).
  ENDMETHOD.

  METHOD rejects_invalid_dates.
    DATA dates TYPE STANDARD TABLE OF d WITH DEFAULT KEY.
    dates = VALUE #( ( '19000229' ) ( '20260229' ) ( '20260931' ) ( '20261301' )
                     ( '20260001' ) ( '20260100' ) ( '00000101' ) ( '00000000' ) ( 'abcdefgh' ) ).
    LOOP AT dates INTO DATA(date).
      TRY.
          zcl_stock_alloc_date=>validate( date ).
          cl_abap_unit_assert=>fail( |Invalid date accepted: { date }| ).
        CATCH zcx_stock_alloc.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
