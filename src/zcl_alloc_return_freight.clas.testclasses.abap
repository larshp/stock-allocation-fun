CLASS ltcl_alloc_return_freight DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_freight.
    DATA mt_lin TYPE zcl_alloc_return_freight=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_quantity TYPE i
        iv_unit     TYPE i.

    METHODS estimates    FOR TESTING.
    METHODS guards       FOR TESTING.
    METHODS per_unit     FOR TESTING.
    METHODS totals       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_freight IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_freight( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_return_freight=>ty_line.

    ls_line-quantity = iv_quantity.
    ls_line-unit_freight = iv_unit.
    APPEND ls_line TO mt_lin.
  ENDMETHOD.

  METHOD estimates.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->estimate( iv_base = 10 iv_per_unit = 5 iv_quantity = 3 )
      exp = 25 ).
  ENDMETHOD.

  METHOD guards.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->estimate( iv_base = 10 iv_per_unit = 5 iv_quantity = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD per_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_total = 25 iv_quantity = 3 ) exp = 8 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_total = 25 iv_quantity = 0 ) exp = 0 ).
  ENDMETHOD.

  METHOD totals.
    add( iv_quantity = 3 iv_unit = 5 ).
    add( iv_quantity = 2 iv_unit = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_lin ) exp = 35 ).
  ENDMETHOD.

ENDCLASS.
