CLASS lcl_source DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    METHODS constructor
      IMPORTING
        it_supply TYPE zif_supply_reader=>ty_supply_tab OPTIONAL
        iv_fail   TYPE abap_bool DEFAULT abap_false.

  PRIVATE SECTION.
    DATA mt_supply TYPE zif_supply_reader=>ty_supply_tab.
    DATA mv_fail   TYPE abap_bool.

ENDCLASS.


CLASS lcl_source IMPLEMENTATION.

  METHOD constructor.

    mt_supply = it_supply.
    mv_fail   = iv_fail.

  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.

    IF mv_fail = abap_true.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>no_conversion
        mv_message = |{ iv_matnr }| ).
    ENDIF.

    rt_supply = mt_supply.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_supply_sources DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'SUPPLY-SOURCES-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    METHODS read
      IMPORTING
        it_source        TYPE zcl_supply_sources=>ty_source_tab
      RETURNING
        VALUE(rt_supply) TYPE zif_supply_reader=>ty_supply_tab
      RAISING
        zcx_allocation.

    METHODS every_source_is_read FOR TESTING RAISING cx_static_check.
    METHODS no_source_is_no_supply FOR TESTING RAISING cx_static_check.
    METHODS a_failing_source_stops_it FOR TESTING.

ENDCLASS.


CLASS ltcl_supply_sources IMPLEMENTATION.

  METHOD read.

    rt_supply = NEW zcl_supply_sources( it_source )->zif_supply_reader~read_supply(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD every_source_is_read.

    DATA(lt_supply) = read( VALUE #(
      ( NEW lcl_source( it_supply = VALUE #( ( quantity = '10' ) ) ) )
      ( NEW lcl_source( it_supply = VALUE #( ( avail_date = '20260301' quantity = '4' ) ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_supply
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( quantity = '10' )
        ( avail_date = '20260301' quantity = '4' ) )
      msg = 'everything that can be given away has to reach the engine' ).

  ENDMETHOD.

  METHOD no_source_is_no_supply.

    cl_abap_unit_assert=>assert_initial( read( VALUE #( ) ) ).

  ENDMETHOD.

  METHOD a_failing_source_stops_it.

    TRY.
        read( VALUE #(
          ( NEW lcl_source( it_supply = VALUE #( ( quantity = '10' ) ) ) )
          ( NEW lcl_source( iv_fail = abap_true ) ) ) ).
        cl_abap_unit_assert=>fail( 'supply that is known to be incomplete must not be allocated on' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
