CLASS ltcl_alloc_trend DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_trend.

    METHODS setup.

    METHODS add
      IMPORTING
        it_qty        TYPE zcl_alloc_trend=>ty_qty_tt
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rt_qty) TYPE zcl_alloc_trend=>ty_qty_tt.

    METHODS empty_series  FOR TESTING.
    METHODS rising        FOR TESTING.
    METHODS falling       FOR TESTING.
    METHODS flat          FOR TESTING.
    METHODS single_value  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_trend IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_trend( ).
  ENDMETHOD.

  METHOD add.
    rt_qty = it_qty.
    APPEND iv_quantity TO rt_qty.
  ENDMETHOD.

  METHOD empty_series.
    DATA lt_qty TYPE zcl_alloc_trend=>ty_qty_tt.

    DATA(rs_trend) = mo_cut->analyze( lt_qty ).

    cl_abap_unit_assert=>assert_equals( act = rs_trend-count exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = rs_trend-direction exp = 'F' ).
  ENDMETHOD.

  METHOD rising.
    DATA lt_qty TYPE zcl_alloc_trend=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '20' ).

    DATA(rs_trend) = mo_cut->analyze( lt_qty ).

    cl_abap_unit_assert=>assert_equals( act = rs_trend-direction exp = 'U' ).
    cl_abap_unit_assert=>assert_equals( act = rs_trend-change_pct exp = 100 ).
  ENDMETHOD.

  METHOD falling.
    DATA lt_qty TYPE zcl_alloc_trend=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '20' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).

    DATA(rs_trend) = mo_cut->analyze( lt_qty ).

    cl_abap_unit_assert=>assert_equals( act = rs_trend-direction exp = 'D' ).
    cl_abap_unit_assert=>assert_equals( act = rs_trend-change_pct exp = -50 ).
  ENDMETHOD.

  METHOD flat.
    DATA lt_qty TYPE zcl_alloc_trend=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).

    DATA(rs_trend) = mo_cut->analyze( lt_qty ).

    cl_abap_unit_assert=>assert_equals( act = rs_trend-direction exp = 'F' ).
    cl_abap_unit_assert=>assert_equals( act = rs_trend-change_pct exp = 0 ).
  ENDMETHOD.

  METHOD single_value.
    DATA lt_qty TYPE zcl_alloc_trend=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).

    DATA(rs_trend) = mo_cut->analyze( lt_qty ).

    cl_abap_unit_assert=>assert_equals( act = rs_trend-count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_trend-first_qty exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = rs_trend-last_qty exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = rs_trend-direction exp = 'F' ).
  ENDMETHOD.

ENDCLASS.
