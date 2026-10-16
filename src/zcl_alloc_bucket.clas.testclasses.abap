CLASS ltcl_alloc_bucket DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bucket.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_value      TYPE menge_d
        it_bounds     TYPE zcl_alloc_bucket=>ty_qty_tt
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_bucket=>ty_input.

    METHODS bounds
      IMPORTING
        iv_one        TYPE menge_d
        iv_two        TYPE menge_d
      RETURNING
        VALUE(rt_qty) TYPE zcl_alloc_bucket=>ty_qty_tt.

    METHODS below_first   FOR TESTING.
    METHODS between_bounds FOR TESTING.
    METHODS above_last    FOR TESTING.
    METHODS empty_bounds  FOR TESTING.
    METHODS exact_boundary FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_bucket IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bucket( ).
  ENDMETHOD.

  METHOD input.
    rs_row-value = iv_value.
    rs_row-boundaries = it_bounds.
  ENDMETHOD.

  METHOD bounds.
    APPEND iv_one TO rt_qty.
    APPEND iv_two TO rt_qty.
  ENDMETHOD.

  METHOD below_first.
    DATA ls_input TYPE zcl_alloc_bucket=>ty_input.

    ls_input-value = '5'.
    ls_input-boundaries = bounds( iv_one = '10' iv_two = '20' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( ls_input )
                                        exp = 1 ).
  ENDMETHOD.

  METHOD between_bounds.
    DATA ls_input TYPE zcl_alloc_bucket=>ty_input.

    ls_input-value = '15'.
    ls_input-boundaries = bounds( iv_one = '10' iv_two = '20' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( ls_input )
                                        exp = 2 ).
  ENDMETHOD.

  METHOD above_last.
    DATA ls_input TYPE zcl_alloc_bucket=>ty_input.

    ls_input-value = '25'.
    ls_input-boundaries = bounds( iv_one = '10' iv_two = '20' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( ls_input )
                                        exp = 3 ).
  ENDMETHOD.

  METHOD empty_bounds.
    DATA ls_input TYPE zcl_alloc_bucket=>ty_input.

    ls_input-value = '25'.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( ls_input )
                                        exp = 1 ).
  ENDMETHOD.

  METHOD exact_boundary.
    DATA ls_input TYPE zcl_alloc_bucket=>ty_input.

    ls_input-value = '10'.
    ls_input-boundaries = bounds( iv_one = '10' iv_two = '20' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->bucket( ls_input )
                                        exp = 2 ).
  ENDMETHOD.

ENDCLASS.
