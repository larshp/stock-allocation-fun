CLASS ltcl_alloc_season_forecast DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_season_forecast.
    DATA mt_ser  TYPE zcl_alloc_seasonal=>ty_series_tt.
    DATA mt_idx  TYPE zcl_alloc_seasonal=>ty_index_tt.

    METHODS setup.

    METHODS add_value
      IMPORTING
        iv_value TYPE menge_d.

    METHODS add_index
      IMPORTING
        iv_index TYPE i.

    METHODS no_index           FOR TESTING.
    METHODS season_out_of_range FOR TESTING.
    METHODS flat_index_forecast FOR TESTING.
    METHODS scaled_season      FOR TESTING.
    METHODS empty_series       FOR TESTING.
    METHODS baseline_deseasons FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_season_forecast IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_season_forecast( ).
  ENDMETHOD.

  METHOD add_value.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD add_index.
    APPEND iv_index TO mt_idx.
  ENDMETHOD.

  METHOD no_index.
    add_value( iv_value = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->forecast( it_series      = mt_ser
                              it_index       = mt_idx
                              iv_next_season = 1 )
      exp = 0 ).
  ENDMETHOD.

  METHOD season_out_of_range.
    add_value( iv_value = 10 ).
    add_index( iv_index = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->forecast( it_series      = mt_ser
                              it_index       = mt_idx
                              iv_next_season = 2 )
      exp = 0 ).
  ENDMETHOD.

  METHOD flat_index_forecast.
    add_value( iv_value = 10 ).
    add_value( iv_value = 20 ).
    add_index( iv_index = 100 ).
    add_index( iv_index = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->forecast( it_series      = mt_ser
                              it_index       = mt_idx
                              iv_next_season = 1 )
      exp = 15 ).
  ENDMETHOD.

  METHOD scaled_season.
    add_value( iv_value = 10 ).
    add_value( iv_value = 20 ).
    add_index( iv_index = 100 ).
    add_index( iv_index = 200 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->forecast( it_series      = mt_ser
                              it_index       = mt_idx
                              iv_next_season = 2 )
      exp = 20 ).
  ENDMETHOD.

  METHOD empty_series.
    add_index( iv_index = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->forecast( it_series      = mt_ser
                              it_index       = mt_idx
                              iv_next_season = 1 )
      exp = 0 ).
  ENDMETHOD.

  METHOD baseline_deseasons.
    add_value( iv_value = 10 ).
    add_value( iv_value = 20 ).
    add_index( iv_index = 100 ).
    add_index( iv_index = 200 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->baseline_of( it_series = mt_ser
                                 it_index  = mt_idx )
      exp = 10 ).
  ENDMETHOD.

ENDCLASS.
