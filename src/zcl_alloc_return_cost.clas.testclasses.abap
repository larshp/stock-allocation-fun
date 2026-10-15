CLASS ltcl_alloc_return_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_cost.
    DATA mt_lin TYPE zcl_alloc_return_cost=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_quantity TYPE i
        iv_cost     TYPE i.

    METHODS values           FOR TESTING.
    METHODS guards_negative  FOR TESTING.
    METHODS per_unit         FOR TESTING.
    METHODS per_unit_guard   FOR TESTING.
    METHODS totals           FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_cost( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_return_cost=>ty_line.

    ls_line-quantity = iv_quantity.
    ls_line-unit_cost = iv_cost.
    APPEND ls_line TO mt_lin.
  ENDMETHOD.

  METHOD values.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_quantity = 3 iv_unit_cost = 7 )
      exp = 21 ).
  ENDMETHOD.

  METHOD guards_negative.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_quantity = -1 iv_unit_cost = 7 )
      exp = 0 ).
  ENDMETHOD.

  METHOD per_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_total = 21 iv_quantity = 3 )
      exp = 7 ).
  ENDMETHOD.

  METHOD per_unit_guard.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_total = 21 iv_quantity = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD totals.
    add( iv_quantity = 3 iv_cost = 7 ).
    add( iv_quantity = 2 iv_cost = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_lin ) exp = 31 ).
  ENDMETHOD.

ENDCLASS.
