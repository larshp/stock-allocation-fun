CLASS ltcl_alloc_cheapest DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cheapest.
    DATA mt_src TYPE zcl_alloc_cheapest=>ty_source_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id    TYPE string
        iv_avail TYPE menge_d
        iv_cost  TYPE menge_d.

    METHODS cheapest_first   FOR TESTING.
    METHODS splits_across    FOR TESTING.
    METHODS reports_shortfall FOR TESTING.
    METHODS no_demand        FOR TESTING.
    METHODS empty_sources    FOR TESTING.
    METHODS ignores_empty    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cheapest IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cheapest( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_source TYPE zcl_alloc_cheapest=>ty_source.

    ls_source-source_id = iv_id.
    ls_source-available = iv_avail.
    ls_source-unit_cost = iv_cost.
    APPEND ls_source TO mt_src.
  ENDMETHOD.

  METHOD cheapest_first.
    add( iv_id = 'EXPENSIVE' iv_avail = 10 iv_cost = 9 ).
    add( iv_id = 'CHEAP' iv_avail = 10 iv_cost = 2 ).

    DATA(ls_result) = mo_cut->solve( it_sources  = mt_src
                                     iv_quantity = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-picks ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-picks[ 1 ]-source_id exp = 'CHEAP' ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-shortfall exp = 0 ).
  ENDMETHOD.

  METHOD splits_across.
    add( iv_id = 'A' iv_avail = 4 iv_cost = 1 ).
    add( iv_id = 'B' iv_avail = 4 iv_cost = 3 ).

    DATA(ls_result) = mo_cut->solve( it_sources  = mt_src
                                     iv_quantity = 6 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-picks ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-picks[ 1 ]-quantity exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-picks[ 2 ]-quantity exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-covered exp = 6 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 10 ).
  ENDMETHOD.

  METHOD reports_shortfall.
    add( iv_id = 'A' iv_avail = 2 iv_cost = 1 ).

    DATA(ls_result) = mo_cut->solve( it_sources  = mt_src
                                     iv_quantity = 5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-covered exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-shortfall exp = 3 ).
  ENDMETHOD.

  METHOD no_demand.
    add( iv_id = 'A' iv_avail = 5 iv_cost = 1 ).

    DATA(ls_result) = mo_cut->solve( it_sources  = mt_src
                                     iv_quantity = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-picks ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-shortfall exp = 0 ).
  ENDMETHOD.

  METHOD empty_sources.
    DATA(ls_result) = mo_cut->solve( it_sources  = mt_src
                                     iv_quantity = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-picks ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-shortfall exp = 5 ).
  ENDMETHOD.

  METHOD ignores_empty.
    add( iv_id = 'EMPTY' iv_avail = 0 iv_cost = 1 ).
    add( iv_id = 'FULL' iv_avail = 3 iv_cost = 2 ).

    DATA(ls_result) = mo_cut->solve( it_sources  = mt_src
                                     iv_quantity = 3 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-picks ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-picks[ 1 ]-source_id exp = 'FULL' ).
  ENDMETHOD.

ENDCLASS.
