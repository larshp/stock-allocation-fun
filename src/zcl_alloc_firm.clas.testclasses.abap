"! Answers with a fixed set of recorded lines.
CLASS lcl_store_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_store.

    METHODS constructor
      IMPORTING
        it_recorded TYPE zif_allocation_store=>ty_recorded_tab.

    METHODS reads
      RETURNING
        VALUE(rv_reads) TYPE i.

  PRIVATE SECTION.
    DATA mt_recorded TYPE zif_allocation_store=>ty_recorded_tab.
    DATA mv_reads    TYPE i.
    DATA mv_written  TYPE abap_bool.

ENDCLASS.


CLASS lcl_store_double IMPLEMENTATION.

  METHOD constructor.
    mt_recorded = it_recorded.
  ENDMETHOD.

  METHOD reads.
    rv_reads = mv_reads.
  ENDMETHOD.

  METHOD zif_allocation_store~latest_per_material.
    mv_reads    = mv_reads + 1.
    rt_recorded = mt_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~save.
    " the firm zone only reads
    CLEAR mv_written.
  ENDMETHOD.

  METHOD zif_allocation_store~read.
    CLEAR rt_allocation.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_recorded_before.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_of_material.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~record_reservation.
    CLEAR mv_written.
  ENDMETHOD.

  METHOD zif_allocation_store~delete_run.
    CLEAR mv_written.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_firm DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_matnr TYPE mard-matnr VALUE 'FIRM-MAT-01'.
    CONSTANTS c_other TYPE mard-matnr VALUE 'FIRM-MAT-02'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9671'.

    DATA mo_store TYPE REF TO lcl_store_double.

    METHODS source
      IMPORTING
        iv_days          TYPE i
        it_recorded      TYPE zif_allocation_store=>ty_recorded_tab
      RETURNING
        VALUE(ro_source) TYPE REF TO zif_alloc_floor.

    METHODS recorded
      IMPORTING
        iv_id              TYPE zif_allocation=>ty_demand_id
        iv_confirmed       TYPE zif_allocation=>ty_quantity
        iv_matnr           TYPE mard-matnr DEFAULT c_matnr
      RETURNING
        VALUE(rs_recorded) TYPE zif_allocation_store=>ty_recorded.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_req_date      TYPE zif_allocation=>ty_demand-req_date
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS in_days
      IMPORTING
        iv_days        TYPE i
      RETURNING
        VALUE(rv_date) TYPE d.

    METHODS no_firm_zone_holds_nothing FOR TESTING.
    METHODS a_line_shipping_soon_keeps_it FOR TESTING.
    METHODS a_line_further_out_does_not FOR TESTING.
    METHODS a_line_nobody_confirmed FOR TESTING.
    METHODS a_line_confirmed_nothing FOR TESTING.
    METHODS another_material_is_not_it FOR TESTING.
    METHODS the_plant_is_read_once FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_firm IMPLEMENTATION.

  METHOD source.

    mo_store  = NEW lcl_store_double( it_recorded ).
    ro_source = NEW zcl_alloc_firm(
      iv_days  = iv_days
      io_store = mo_store ).

  ENDMETHOD.

  METHOD recorded.

    rs_recorded = VALUE #(
      matnr     = iv_matnr
      run_id    = 'RUN-FIRM-1'
      demand_id = iv_id
      requested = 100
      confirmed = iv_confirmed
      customer  = 'FIRMCUST' ).

  ENDMETHOD.

  METHOD demand.

    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = c_matnr
      werks     = c_werks
      quantity  = 100
      req_date  = iv_req_date
      priority  = '01'
      customer  = 'FIRMCUST' ).

  ENDMETHOD.

  METHOD in_days.

    rv_date = sy-datum + iv_days.

  ENDMETHOD.

  METHOD no_firm_zone_holds_nothing.

    DATA(lt_floor) = source(
      iv_days     = zcl_alloc_firm=>c_no_firm
      it_recorded = VALUE #( ( recorded( iv_id        = 'D1'
                                         iv_confirmed = 40 ) ) )
      )->floors_for( VALUE #( ( demand( iv_id       = 'D1'
                                        iv_req_date = in_days( 1 ) ) ) ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_floor
      msg = 'a plant that has asked for no firm zone re-cuts everything' ).

  ENDMETHOD.

  METHOD a_line_shipping_soon_keeps_it.

    DATA(lt_floor) = source(
      iv_days     = 3
      it_recorded = VALUE #( ( recorded( iv_id        = 'D1'
                                         iv_confirmed = 40 ) ) )
      )->floors_for( VALUE #( ( demand( iv_id       = 'D1'
                                        iv_req_date = in_days( 1 ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_floor )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_floor[ 1 ]-quantity
      exp = CONV zif_allocation=>ty_quantity( 40 )
      msg = 'what the last run confirmed for a line on the ramp stands' ).

  ENDMETHOD.

  METHOD a_line_further_out_does_not.

    DATA(lt_floor) = source(
      iv_days     = 3
      it_recorded = VALUE #( ( recorded( iv_id        = 'D1'
                                         iv_confirmed = 40 ) ) )
      )->floors_for( VALUE #( ( demand( iv_id       = 'D1'
                                        iv_req_date = in_days( 10 ) ) ) ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_floor
      msg = 'a line ten days out is re-cut, which is the point of running again' ).

  ENDMETHOD.

  METHOD a_line_nobody_confirmed.

    DATA(lt_floor) = source(
      iv_days     = 3
      it_recorded = VALUE #( ( recorded( iv_id        = 'D9'
                                         iv_confirmed = 40 ) ) )
      )->floors_for( VALUE #( ( demand( iv_id       = 'D1'
                                        iv_req_date = in_days( 1 ) ) ) ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_floor
      msg = 'a line the last run never saw has nothing to keep' ).

  ENDMETHOD.

  METHOD a_line_confirmed_nothing.

    DATA(lt_floor) = source(
      iv_days     = 3
      it_recorded = VALUE #( ( recorded( iv_id        = 'D1'
                                         iv_confirmed = 0 ) ) )
      )->floors_for( VALUE #( ( demand( iv_id       = 'D1'
                                        iv_req_date = in_days( 1 ) ) ) ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_floor
      msg = 'a floor of nothing is no floor, and would answer a line twice' ).

  ENDMETHOD.

  METHOD another_material_is_not_it.

    " the recorded lines are the whole plant's, and a demand id is unique to a
    " document line rather than to a material -- but reading one material's
    " answer for another one would be a confirmation out of thin air
    DATA(lt_floor) = source(
      iv_days     = 3
      it_recorded = VALUE #( ( recorded( iv_id        = 'D1'
                                         iv_confirmed = 40
                                         iv_matnr     = c_other ) ) )
      )->floors_for( VALUE #( ( demand( iv_id       = 'D1'
                                        iv_req_date = in_days( 1 ) ) ) ) ).

    cl_abap_unit_assert=>assert_initial( lt_floor ).

  ENDMETHOD.

  METHOD the_plant_is_read_once.

    DATA(lo_source) = source(
      iv_days     = 3
      it_recorded = VALUE #( ( recorded( iv_id        = 'D1'
                                         iv_confirmed = 40 ) ) ) ).

    lo_source->floors_for( VALUE #( ( demand( iv_id       = 'D1'
                                              iv_req_date = in_days( 1 ) ) ) ) ).
    lo_source->floors_for( VALUE #( ( demand( iv_id       = 'D1'
                                              iv_req_date = in_days( 1 ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_store->reads( )
      exp = 1
      msg = 'a plant wide run would otherwise read the recorded runs per material' ).

  ENDMETHOD.

ENDCLASS.
