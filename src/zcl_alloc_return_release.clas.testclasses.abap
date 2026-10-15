CLASS ltcl_alloc_return_release DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_release.

    METHODS setup.

    METHODS line
      IMPORTING
        iv_quantity    TYPE i
        iv_released    TYPE i
      RETURNING
        VALUE(rs_line) TYPE zcl_alloc_return_release=>ty_line.

    METHODS adds_release     FOR TESTING.
    METHODS caps_release     FOR TESTING.
    METHODS completion_rule  FOR TESTING.
    METHODS remaining_qty    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_release IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_release( ).
  ENDMETHOD.

  METHOD line.
    rs_line-material = 'M1'.
    rs_line-quantity = iv_quantity.
    rs_line-released = iv_released.
  ENDMETHOD.

  METHOD adds_release.
    DATA ls_line TYPE zcl_alloc_return_release=>ty_line.

    ls_line = mo_cut->release( is_line        = line( iv_quantity = 10
                                                      iv_released = 0 )
                               iv_release_qty = 4 ).

    cl_abap_unit_assert=>assert_equals( act = ls_line-released exp = 4 ).
  ENDMETHOD.

  METHOD caps_release.
    DATA ls_line TYPE zcl_alloc_return_release=>ty_line.

    ls_line = mo_cut->release( is_line        = line( iv_quantity = 10
                                                      iv_released = 8 )
                               iv_release_qty = 5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_line-released exp = 10 ).
  ENDMETHOD.

  METHOD completion_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_released( line( iv_quantity = 10 iv_released = 10 ) )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_released( line( iv_quantity = 10 iv_released = 4 ) )
      exp = abap_false ).
  ENDMETHOD.

  METHOD remaining_qty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining( line( iv_quantity = 10 iv_released = 4 ) )
      exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining( line( iv_quantity = 10 iv_released = 12 ) )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
