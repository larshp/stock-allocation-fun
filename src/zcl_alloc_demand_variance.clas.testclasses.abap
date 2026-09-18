CLASS ltcl_alloc_demand_variance DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_demand_variance.

    METHODS setup.

    METHODS add
      IMPORTING
        it_qty        TYPE zcl_alloc_demand_variance=>ty_qty_tt
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rt_qty) TYPE zcl_alloc_demand_variance=>ty_qty_tt.

    METHODS empty_series     FOR TESTING.
    METHODS single_value     FOR TESTING.
    METHODS two_values       FOR TESTING.
    METHODS range_and_extremes FOR TESTING.
    METHODS constant_series  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_demand_variance IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_demand_variance( ).
  ENDMETHOD.

  METHOD add.
    rt_qty = it_qty.
    APPEND iv_quantity TO rt_qty.
  ENDMETHOD.

  METHOD empty_series.
    DATA lt_qty TYPE zcl_alloc_demand_variance=>ty_qty_tt.

    DATA(rs_stats) = mo_cut->analyze( lt_qty ).

    cl_abap_unit_assert=>assert_equals( act = rs_stats-count exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = rs_stats-variance exp = '0' ).
  ENDMETHOD.

  METHOD single_value.
    DATA lt_qty TYPE zcl_alloc_demand_variance=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '7' ).

    DATA(rs_stats) = mo_cut->analyze( lt_qty ).

    cl_abap_unit_assert=>assert_equals( act = rs_stats-count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_stats-mean exp = '7' ).
    cl_abap_unit_assert=>assert_equals( act = rs_stats-variance exp = '0' ).
  ENDMETHOD.

  METHOD two_values.
    DATA lt_qty TYPE zcl_alloc_demand_variance=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '20' ).

    DATA(rs_stats) = mo_cut->analyze( lt_qty ).

    cl_abap_unit_assert=>assert_equals( act = rs_stats-total exp = '30' ).
    cl_abap_unit_assert=>assert_equals( act = rs_stats-mean exp = '15' ).
    cl_abap_unit_assert=>assert_equals( act = rs_stats-variance exp = '25' ).
  ENDMETHOD.

  METHOD range_and_extremes.
    DATA lt_qty TYPE zcl_alloc_demand_variance=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '5' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '25' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '15' ).

    DATA(rs_stats) = mo_cut->analyze( lt_qty ).

    cl_abap_unit_assert=>assert_equals( act = rs_stats-min_qty exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = rs_stats-max_qty exp = '25' ).
    cl_abap_unit_assert=>assert_equals( act = rs_stats-range_qty exp = '20' ).
  ENDMETHOD.

  METHOD constant_series.
    DATA lt_qty TYPE zcl_alloc_demand_variance=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '4' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '4' ).

    DATA(rs_stats) = mo_cut->analyze( lt_qty ).

    cl_abap_unit_assert=>assert_equals( act = rs_stats-variance exp = '0' ).
  ENDMETHOD.

ENDCLASS.
