CLASS ltcl_alloc_disposal_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_disposal_cost.
    DATA mt_lin TYPE zcl_alloc_disposal_cost=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_quantity TYPE i
        iv_cost     TYPE i.

    METHODS multiplies     FOR TESTING.
    METHODS guards_negative FOR TESTING.
    METHODS values_line    FOR TESTING.
    METHODS totals         FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_disposal_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_disposal_cost( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_disposal_cost=>ty_line.

    ls_line-quantity = iv_quantity.
    ls_line-unit_cost = iv_cost.
    APPEND ls_line TO mt_lin.
  ENDMETHOD.

  METHOD multiplies.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cost( iv_quantity = 3 iv_unit_cost = 7 )
      exp = 21 ).
  ENDMETHOD.

  METHOD guards_negative.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cost( iv_quantity = -1 iv_unit_cost = 7 )
      exp = 0 ).
  ENDMETHOD.

  METHOD values_line.
    DATA ls_line TYPE zcl_alloc_disposal_cost=>ty_line.

    ls_line-quantity = 3.
    ls_line-unit_cost = 7.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cost_of( ls_line ) exp = 21 ).
  ENDMETHOD.

  METHOD totals.
    add( iv_quantity = 3 iv_cost = 7 ).
    add( iv_quantity = 2 iv_cost = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_lin ) exp = 31 ).
  ENDMETHOD.

ENDCLASS.
