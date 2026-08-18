CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_demand TYPE zif_allocation=>ty_demand_tab
        it_matnr  TYPE zif_demand_reader=>ty_matnr_tab OPTIONAL.

  PRIVATE SECTION.
    DATA mt_demand TYPE zif_allocation=>ty_demand_tab.
    DATA mt_matnr  TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_demand = it_demand.
    mt_matnr  = it_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.
    rt_demand = mt_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    rt_matnr = mt_matnr.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_demand_reader_net DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr  TYPE mard-matnr VALUE 'NET-DEMAND-01'.
    CONSTANTS c_werks  TYPE mard-werks VALUE '1000'.
    CONSTANTS c_run_id TYPE zstock_alloc_res-run_id VALUE 'NET-DEMAND-RUN-00001'.

    TYPES ty_result_tab TYPE STANDARD TABLE OF zstock_alloc_res WITH EMPTY KEY.

    METHODS teardown.

    METHODS given_earlier_run
      IMPORTING
        it_result TYPE ty_result_tab.

    METHODS result_row
      IMPORTING
        iv_demand_id     TYPE zstock_alloc_res-demand_id
        iv_confirmed     TYPE zstock_alloc_res-confirmed
        iv_reservation   TYPE zstock_alloc_res-reservation DEFAULT '0000004711'
      RETURNING
        VALUE(rs_result) TYPE zstock_alloc_res.

    METHODS open_demand
      IMPORTING
        it_demand        TYPE zif_allocation=>ty_demand_tab
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab
      RAISING
        cx_static_check.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_quantity      TYPE zif_allocation=>ty_quantity
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS nothing_allocated_yet FOR TESTING RAISING cx_static_check.
    METHODS covered_line_drops_out FOR TESTING RAISING cx_static_check.
    METHODS part_covered_asks_the_rest FOR TESTING RAISING cx_static_check.
    METHODS unreserved_run_does_not_count FOR TESTING RAISING cx_static_check.
    METHODS several_runs_add_up FOR TESTING RAISING cx_static_check.
    METHODS materials_are_passed_through FOR TESTING.

ENDCLASS.


CLASS ltcl_demand_reader_net IMPLEMENTATION.

  METHOD teardown.
    DELETE FROM zstock_alloc_res WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
  ENDMETHOD.

  METHOD result_row.
    rs_result = VALUE #(
      mandt       = sy-mandt
      run_id      = c_run_id
      demand_id   = iv_demand_id
      matnr       = c_matnr
      werks       = c_werks
      confirmed   = iv_confirmed
      reservation = iv_reservation ).
  ENDMETHOD.

  METHOD given_earlier_run.
    INSERT zstock_alloc_res FROM TABLE @it_result.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'earlier run fixture could not be inserted' ).
  ENDMETHOD.

  METHOD demand.
    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = c_matnr
      werks     = c_werks
      quantity  = iv_quantity
      req_date  = '20260101'
      priority  = '01' ).
  ENDMETHOD.

  METHOD open_demand.

    DATA lo_inner TYPE REF TO zif_demand_reader.

    lo_inner = NEW lcl_demand_double( it_demand = it_demand ).

    rt_demand = NEW zcl_demand_reader_net( lo_inner )->zif_demand_reader~read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD nothing_allocated_yet.

    cl_abap_unit_assert=>assert_equals(
      act = lines( open_demand( VALUE #(
        ( demand(
            iv_id       = 'D1'
            iv_quantity = '10' ) ) ) ) )
      exp = 1 ).

  ENDMETHOD.

  METHOD covered_line_drops_out.

    given_earlier_run( VALUE #(
      ( result_row(
          iv_demand_id = 'D1'
          iv_confirmed = '10' ) ) ) ).

    cl_abap_unit_assert=>assert_initial(
      act = open_demand( VALUE #( ( demand(
      iv_id       = 'D1'
      iv_quantity = '10' ) ) ) )
      msg = 'a line already served in full must not compete for stock again' ).

  ENDMETHOD.

  METHOD part_covered_asks_the_rest.

    given_earlier_run( VALUE #(
      ( result_row(
          iv_demand_id = 'D1'
          iv_confirmed = '4' ) ) ) ).

    DATA(lt_demand) = open_demand( VALUE #( ( demand(
      iv_id       = 'D1'
      iv_quantity = '10' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demand )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-quantity
      exp = '6'
      msg = 'only the part that is still missing may be asked for' ).

  ENDMETHOD.

  METHOD unreserved_run_does_not_count.

    given_earlier_run( VALUE #(
      ( result_row(
          iv_demand_id   = 'D1'
          iv_confirmed   = '10'
          iv_reservation = '0000000000' ) ) ) ).

    DATA(lt_demand) = open_demand( VALUE #( ( demand(
      iv_id       = 'D1'
      iv_quantity = '10' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-quantity
      exp = '10'
      msg = 'a run that never earmarked anything has not served the demand' ).

  ENDMETHOD.

  METHOD several_runs_add_up.

    DATA lt_second TYPE ty_result_tab.

    given_earlier_run( VALUE #(
      ( result_row(
          iv_demand_id = 'D1'
          iv_confirmed = '2.5' ) ) ) ).

    lt_second = VALUE #(
      ( mandt = sy-mandt run_id = 'NET-DEMAND-RUN-00002' demand_id = 'D1'
        matnr = c_matnr werks = c_werks confirmed = '1.5' reservation = '0000004712' ) ).
    INSERT zstock_alloc_res FROM TABLE @lt_second.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).

    DATA(lt_demand) = open_demand( VALUE #( ( demand(
      iv_id       = 'D1'
      iv_quantity = '10' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-quantity
      exp = '6'
      msg = 'everything earmarked so far counts, not just the last run' ).

  ENDMETHOD.

  METHOD materials_are_passed_through.

    DATA lo_inner TYPE REF TO zif_demand_reader.

    lo_inner = NEW lcl_demand_double(
      it_demand = VALUE #( )
      it_matnr  = VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = NEW zcl_demand_reader_net( lo_inner )->zif_demand_reader~materials_with_demand( c_werks )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( 'MAT-1' ) ( 'MAT-2' ) ) ).

  ENDMETHOD.

ENDCLASS.
