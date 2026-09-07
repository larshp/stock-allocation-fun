CLASS lcl_source DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_demand TYPE zif_allocation=>ty_demand_tab OPTIONAL
        it_matnr  TYPE zif_demand_reader=>ty_matnr_tab OPTIONAL
        iv_fail   TYPE abap_bool DEFAULT abap_false.

  PRIVATE SECTION.
    DATA mt_demand TYPE zif_allocation=>ty_demand_tab.
    DATA mt_matnr  TYPE zif_demand_reader=>ty_matnr_tab.
    DATA mv_fail   TYPE abap_bool.

ENDCLASS.


CLASS lcl_source IMPLEMENTATION.

  METHOD constructor.

    mt_demand = it_demand.
    mt_matnr  = it_matnr.
    mv_fail   = iv_fail.

  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    IF mv_fail = abap_true.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>no_conversion
        mv_message = |{ iv_matnr }| ).
    ENDIF.

    rt_demand = mt_demand.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    rt_matnr = mt_matnr.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_demand_sources DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'SOURCES-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab.

    METHODS read
      IMPORTING
        it_source        TYPE zcl_demand_sources=>ty_source_tab
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab
      RAISING
        zcx_allocation.

    METHODS every_source_is_read FOR TESTING RAISING cx_static_check.
    METHODS one_source_reads_as_itself FOR TESTING RAISING cx_static_check.
    METHODS no_source_is_no_demand FOR TESTING RAISING cx_static_check.
    METHODS a_failing_source_stops_it FOR TESTING.
    METHODS materials_are_the_union FOR TESTING.

ENDCLASS.


CLASS ltcl_demand_sources IMPLEMENTATION.

  METHOD demand.

    rt_demand = VALUE #(
      ( demand_id = iv_id
        matnr     = c_matnr
        werks     = c_werks
        quantity  = '5'
        req_date  = '20260101'
        priority  = '01' ) ).

  ENDMETHOD.

  METHOD read.

    rt_demand = NEW zcl_demand_sources( it_source )->zif_demand_reader~read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD every_source_is_read.

    DATA(lt_demand) = read( VALUE #(
      ( NEW lcl_source( it_demand = demand( 'FROM-ORDER' ) ) )
      ( NEW lcl_source( it_demand = demand( 'FROM-TRANSFER' ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demand )
      exp = 2
      msg = 'everything competing for the stock has to reach the strategy' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-demand_id
      exp = 'FROM-ORDER'
      msg = 'the sources are read in the order they were given' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 2 ]-demand_id
      exp = 'FROM-TRANSFER' ).

  ENDMETHOD.

  METHOD one_source_reads_as_itself.

    cl_abap_unit_assert=>assert_equals(
      act = read( VALUE #( ( NEW lcl_source( it_demand = demand( 'ONLY' ) ) ) ) )
      exp = demand( 'ONLY' ) ).

  ENDMETHOD.

  METHOD no_source_is_no_demand.

    cl_abap_unit_assert=>assert_initial( read( VALUE #( ) ) ).

  ENDMETHOD.

  METHOD a_failing_source_stops_it.

    TRY.
        read( VALUE #(
          ( NEW lcl_source( it_demand = demand( 'FROM-ORDER' ) ) )
          ( NEW lcl_source( iv_fail = abap_true ) ) ) ).
        cl_abap_unit_assert=>fail( 'incomplete demand must not be allocated on' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

  METHOD materials_are_the_union.

    DATA(lo_cut) = NEW zcl_demand_sources( VALUE #(
      ( NEW lcl_source( it_matnr = VALUE #( ( 'MAT-B' ) ( 'MAT-C' ) ) ) )
      ( NEW lcl_source( it_matnr = VALUE #( ( 'MAT-A' ) ( 'MAT-C' ) ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->zif_demand_reader~materials_with_demand( c_werks )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( 'MAT-A' ) ( 'MAT-B' ) ( 'MAT-C' ) )
      msg = 'a material wanted by two sources is allocated once' ).

  ENDMETHOD.

ENDCLASS.
