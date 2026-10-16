CLASS ltcl_alloc_location_score DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_location_score.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_fill       TYPE i
        iv_distance   TYPE i
        iv_picks      TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_location_score=>ty_input.

    METHODS high_fill        FOR TESTING.
    METHODS distance_penalty FOR TESTING.
    METHODS picks_penalty    FOR TESTING.
    METHODS clamps_at_zero   FOR TESTING.
    METHODS all_zero         FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_location_score IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_location_score( ).
  ENDMETHOD.

  METHOD input.
    rs_row-fill_pct = iv_fill.
    rs_row-distance = iv_distance.
    rs_row-picks = iv_picks.
  ENDMETHOD.

  METHOD high_fill.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( input( iv_fill     = 90
                                  iv_distance = 0
                                  iv_picks    = 0 ) )
      exp = 180 ).
  ENDMETHOD.

  METHOD distance_penalty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( input( iv_fill     = 90
                                  iv_distance = 10
                                  iv_picks    = 0 ) )
      exp = 170 ).
  ENDMETHOD.

  METHOD picks_penalty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( input( iv_fill     = 90
                                  iv_distance = 0
                                  iv_picks    = 2 ) )
      exp = 170 ).
  ENDMETHOD.

  METHOD clamps_at_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( input( iv_fill     = 10
                                  iv_distance = 100
                                  iv_picks    = 5 ) )
      exp = 0 ).
  ENDMETHOD.

  METHOD all_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( input( iv_fill     = 0
                                  iv_distance = 0
                                  iv_picks    = 0 ) )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
