CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_matnr TYPE zif_demand_reader=>ty_matnr_tab.

  PRIVATE SECTION.
    DATA mt_matnr TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_matnr = it_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    rt_matnr = mt_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.
    CLEAR rt_demand.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    METHODS constructor
      IMPORTING
        iv_refuse TYPE abap_bool DEFAULT abap_false.

  PRIVATE SECTION.
    DATA mv_refuse TYPE abap_bool.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD constructor.
    mv_refuse = iv_refuse.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.

    IF mv_refuse = abap_true.
      RAISE EXCEPTION NEW zcx_allocation(
        textid   = zcx_allocation=>not_authorised
        mv_werks = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_coverage DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_werks TYPE mard-werks VALUE '9151'.
    CONSTANTS c_done  TYPE mard-matnr VALUE 'COVER-DONE'.
    CONSTANTS c_missed TYPE mard-matnr VALUE 'COVER-MISSED'.

    METHODS teardown.

    METHODS given_run
      IMPORTING
        iv_matnr    TYPE mard-matnr
        iv_days_ago TYPE i DEFAULT 0.

    METHODS lines_of
      IMPORTING
        it_matnr       TYPE zif_demand_reader=>ty_matnr_tab
        iv_hours       TYPE i DEFAULT 24
        iv_refuse      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_coverage=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS says
      IMPORTING
        it_line       TYPE zcl_alloc_coverage=>ty_line_tab
        iv_text       TYPE string
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

    METHODS a_material_nobody_ran_shows FOR TESTING RAISING cx_static_check.
    METHODS a_material_that_ran_does_not FOR TESTING RAISING cx_static_check.
    METHODS an_old_run_does_not_count FOR TESTING RAISING cx_static_check.
    METHODS a_covered_plant_says_so FOR TESTING RAISING cx_static_check.
    METHODS nothing_waiting_says_so FOR TESTING RAISING cx_static_check.
    METHODS a_closed_plant_is_refused FOR TESTING.
    METHODS what_was_missed_is_a_list FOR TESTING RAISING cx_static_check.
    METHODS a_covered_plant_misses_none FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_alloc_coverage IMPLEMENTATION.

  METHOD teardown.

    DELETE FROM zstock_alloc_res WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_run.

    DATA lt_row  TYPE STANDARD TABLE OF zstock_alloc_res WITH EMPTY KEY.
    DATA lv_date TYPE d.
    DATA lv_when TYPE zstock_alloc_res-created_at.

    lv_date = sy-datum - iv_days_ago.
    CONVERT DATE lv_date TIME '120000'
      INTO TIME STAMP lv_when TIME ZONE 'UTC'.

    lt_row = VALUE #(
      ( mandt      = sy-mandt
        run_id     = |COVER-{ iv_days_ago }-{ iv_matnr }|
        demand_id  = 'COVER-DEMAND'
        matnr      = iv_matnr
        werks      = c_werks
        requested  = 10
        confirmed  = 10
        created_at = lv_when ) ).

    INSERT zstock_alloc_res FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD lines_of.

    rt_line = NEW zcl_alloc_coverage(
      io_demand    = NEW lcl_demand_double( it_matnr )
      io_authority = NEW lcl_authority_double( iv_refuse ) )->run(
        iv_werks = c_werks
        iv_hours = iv_hours ).

  ENDMETHOD.

  METHOD says.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CS iv_text.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD a_material_nobody_ran_shows.

    DATA(lt_line) = lines_of( VALUE #( ( c_missed ) ) ).

    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = |{ c_missed }| ) ).
    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `1 of 1 material(s) with demand were not` )
      msg = 'a material nobody allocated looks like one nobody wants, until this' ).

  ENDMETHOD.

  METHOD a_material_that_ran_does_not.

    given_run( c_done ).

    cl_abap_unit_assert=>assert_true( says(
      it_line = lines_of( VALUE #( ( c_done ) ) )
      iv_text = `All 1 material(s) with demand were allocated` ) ).

  ENDMETHOD.

  METHOD an_old_run_does_not_count.

    given_run( iv_matnr    = c_done
               iv_days_ago = 9 ).

    " last week's run is not last night's: a job that has not run since
    " Tuesday is exactly what this is looking for
    cl_abap_unit_assert=>assert_true( says(
      it_line = lines_of( VALUE #( ( c_done ) ) )
      iv_text = `1 of 1 material(s) with demand were not` ) ).

  ENDMETHOD.

  METHOD a_covered_plant_says_so.

    given_run( c_done ).
    given_run( c_missed ).

    DATA(lt_line) = lines_of( VALUE #( ( c_done ) ( c_missed ) ) ).

    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `All 2 material(s)` ) ).
    cl_abap_unit_assert=>assert_false( says( it_line = lt_line
                                             iv_text = |{ c_missed }| ) ).

  ENDMETHOD.

  METHOD nothing_waiting_says_so.

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lines_of( VALUE #( ) )
                  iv_text = `Nothing is waiting for stock` )
      msg = 'a quiet plant is not a plant with a hundred missed materials' ).

  ENDMETHOD.

  METHOD a_closed_plant_is_refused.

    TRY.
        lines_of( it_matnr  = VALUE #( ( c_done ) )
                  iv_refuse = abap_true ).
        cl_abap_unit_assert=>fail( 'what a plant did last night is the plant''s business' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD what_was_missed_is_a_list.

    DATA(lo_check) = NEW zcl_alloc_coverage(
      io_demand    = NEW lcl_demand_double( VALUE #( ( c_missed ) ) )
      io_authority = NEW lcl_authority_double( ) ).

    " a scheduled check that keeps quiet unless something is wrong has to be
    " able to ask before it decides whether to say anything
    cl_abap_unit_assert=>assert_equals(
      act = lines( lo_check->missed( c_werks ) )
      exp = 1 ).

  ENDMETHOD.

  METHOD a_covered_plant_misses_none.

    given_run( c_done ).

    DATA(lo_check) = NEW zcl_alloc_coverage(
      io_demand    = NEW lcl_demand_double( VALUE #( ( c_done ) ) )
      io_authority = NEW lcl_authority_double( ) ).

    cl_abap_unit_assert=>assert_initial( lo_check->missed( c_werks ) ).

  ENDMETHOD.
ENDCLASS.
