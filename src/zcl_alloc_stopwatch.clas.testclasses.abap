CLASS ltcl_alloc_stopwatch DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stopwatch.

    METHODS setup.

    METHODS numbers_laps   FOR TESTING.
    METHODS totals_laps    FOR TESTING.
    METHODS finds_fastest  FOR TESTING.
    METHODS finds_slowest  FOR TESTING.
    METHODS empty_defaults FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_stopwatch IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stopwatch( ).
  ENDMETHOD.

  METHOD numbers_laps.
    DATA(ls_lap) = mo_cut->lap( 100 ).

    cl_abap_unit_assert=>assert_equals( act = ls_lap-lap exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_lap-ms exp = 100 ).

    ls_lap = mo_cut->lap( 50 ).

    cl_abap_unit_assert=>assert_equals( act = ls_lap-lap exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

  METHOD totals_laps.
    DATA ls_lap  TYPE zcl_alloc_stopwatch=>ty_lap.
    DATA lt_laps TYPE zcl_alloc_stopwatch=>ty_lap_tt.

    ls_lap = mo_cut->lap( 100 ).
    ls_lap = mo_cut->lap( 50 ).
    ls_lap = mo_cut->lap( 25 ).

    lt_laps = mo_cut->laps( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->total( ) exp = 175 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_laps ) exp = 3 ).
  ENDMETHOD.

  METHOD finds_fastest.
    DATA ls_lap TYPE zcl_alloc_stopwatch=>ty_lap.

    ls_lap = mo_cut->lap( 100 ).
    ls_lap = mo_cut->lap( 50 ).
    ls_lap = mo_cut->lap( 25 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->fastest( ) exp = 25 ).
  ENDMETHOD.

  METHOD finds_slowest.
    DATA ls_lap TYPE zcl_alloc_stopwatch=>ty_lap.

    ls_lap = mo_cut->lap( 100 ).
    ls_lap = mo_cut->lap( 50 ).
    ls_lap = mo_cut->lap( 25 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->slowest( ) exp = 100 ).
  ENDMETHOD.

  METHOD empty_defaults.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->total( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->fastest( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->slowest( ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
