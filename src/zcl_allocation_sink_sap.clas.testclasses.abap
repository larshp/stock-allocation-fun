CLASS ltcl_allocation_sink_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS persists_allocation FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_sink_sap IMPLEMENTATION.
  METHOD persists_allocation.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_order_id TYPE c LENGTH 20.
    DATA lv_reservation_id TYPE c LENGTH 20.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    APPEND VALUE #( order_id       = 'ORDER-DB'
                    requested      = '5'
                    allocated      = '4'
                    shortage       = '1'
                    reservation_id = 'RES-DB' ) TO lt_demands.

    lo_cut->save_allocations(
      iv_material = 'MATERIAL-DB'
      iv_plant    = '1000'
      it_demands  = lt_demands ).

    SELECT SINGLE order_id, reservation_id
      FROM zstockalloc
      INTO (@lv_order_id, @lv_reservation_id)
      WHERE matnr = 'MATERIAL-DB'
        AND werks = '1000'.

    cl_abap_unit_assert=>assert_equals(
      act = lv_order_id
      exp = 'ORDER-DB' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_reservation_id
      exp = 'RES-DB' ).
  ENDMETHOD.
ENDCLASS.
