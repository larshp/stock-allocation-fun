CLASS ltcl_alloc_refund DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_refund.

    METHODS setup.

    METHODS line
      IMPORTING
        iv_material    TYPE matnr
        iv_quantity    TYPE i
        iv_price       TYPE i
      RETURNING
        VALUE(rs_line) TYPE zcl_alloc_refund=>ty_line.

    METHODS multiplies      FOR TESTING.
    METHODS guards_negative FOR TESTING.
    METHODS values_line     FOR TESTING.
    METHODS totals          FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_refund IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_refund( ).
  ENDMETHOD.

  METHOD line.
    rs_line-material = iv_material.
    rs_line-quantity = iv_quantity.
    rs_line-unit_price = iv_price.
  ENDMETHOD.

  METHOD multiplies.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_quantity = 2 iv_unit_price = 100 )
      exp = 200 ).
  ENDMETHOD.

  METHOD guards_negative.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_quantity = -1 iv_unit_price = 100 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_quantity = 2 iv_unit_price = -1 )
      exp = 0 ).
  ENDMETHOD.

  METHOD values_line.
    DATA ls_line TYPE zcl_alloc_refund=>ty_line.

    ls_line = line( iv_material = 'M1' iv_quantity = 3 iv_price = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->for_line( ls_line ) exp = 30 ).
  ENDMETHOD.

  METHOD totals.
    DATA lt_lines TYPE zcl_alloc_refund=>ty_line_tt.
    DATA ls_line  TYPE zcl_alloc_refund=>ty_line.

    ls_line = line( iv_material = 'M1' iv_quantity = 2 iv_price = 100 ).
    APPEND ls_line TO lt_lines.
    ls_line = line( iv_material = 'M2' iv_quantity = 5 iv_price = 10 ).
    APPEND ls_line TO lt_lines.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_lines ) exp = 250 ).
  ENDMETHOD.

ENDCLASS.
