CLASS ltcl_alloc_moving_average DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_moving_average.

    METHODS setup.

    METHODS add
      IMPORTING
        it_qty        TYPE zcl_alloc_moving_average=>ty_qty_tt
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rt_qty) TYPE zcl_alloc_moving_average=>ty_qty_tt.

    METHODS empty_series     FOR TESTING.
    METHODS window_two       FOR TESTING.
    METHODS window_one       FOR TESTING.
    METHODS window_too_large FOR TESTING.
    METHODS window_zero      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_moving_average IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_moving_average( ).
  ENDMETHOD.

  METHOD add.
    rt_qty = it_qty.
    APPEND iv_quantity TO rt_qty.
  ENDMETHOD.

  METHOD empty_series.
    DATA lt_qty TYPE zcl_alloc_moving_average=>ty_qty_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->calculate( lt_qty ) ).
  ENDMETHOD.

  METHOD window_two.
    DATA lt_qty TYPE zcl_alloc_moving_average=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '20' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '30' ).

    DATA(lt_lines) = mo_cut->calculate( it_quantities = lt_qty
                                        iv_window     = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-average exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-average exp = '15' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]-average exp = '25' ).
  ENDMETHOD.

  METHOD window_one.
    DATA lt_qty TYPE zcl_alloc_moving_average=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '20' ).

    DATA(lt_lines) = mo_cut->calculate( it_quantities = lt_qty
                                        iv_window     = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-average exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-average exp = '20' ).
  ENDMETHOD.

  METHOD window_too_large.
    DATA lt_qty TYPE zcl_alloc_moving_average=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '20' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '30' ).

    DATA(lt_lines) = mo_cut->calculate( it_quantities = lt_qty
                                        iv_window     = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-average exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-average exp = '15' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]-average exp = '20' ).
  ENDMETHOD.

  METHOD window_zero.
    DATA lt_qty TYPE zcl_alloc_moving_average=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '20' ).

    DATA(lt_lines) = mo_cut->calculate( it_quantities = lt_qty
                                        iv_window     = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-average exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-average exp = '20' ).
  ENDMETHOD.

ENDCLASS.
