CLASS ltcl_alloc_scrap_value DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_scrap_value.

    METHODS setup.

    METHODS line
      IMPORTING
        iv_material    TYPE matnr
        iv_quantity    TYPE i
        iv_unit_value  TYPE i
      RETURNING
        VALUE(rs_line) TYPE zcl_alloc_scrap_value=>ty_line.

    METHODS multiplies      FOR TESTING.
    METHODS guards_negative FOR TESTING.
    METHODS values_line     FOR TESTING.
    METHODS totals          FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_scrap_value IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_scrap_value( ).
  ENDMETHOD.

  METHOD line.
    rs_line-material = iv_material.
    rs_line-quantity = iv_quantity.
    rs_line-unit_value = iv_unit_value.
  ENDMETHOD.

  METHOD multiplies.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_quantity = 3 iv_unit_value = 150 )
      exp = 450 ).
  ENDMETHOD.

  METHOD guards_negative.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_quantity = -1 iv_unit_value = 150 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_quantity = 3 iv_unit_value = -1 )
      exp = 0 ).
  ENDMETHOD.

  METHOD values_line.
    DATA ls_line TYPE zcl_alloc_scrap_value=>ty_line.

    ls_line = line( iv_material = 'M1' iv_quantity = 2 iv_unit_value = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value_of( ls_line ) exp = 200 ).
  ENDMETHOD.

  METHOD totals.
    DATA lt_lines TYPE zcl_alloc_scrap_value=>ty_line_tt.
    DATA ls_line  TYPE zcl_alloc_scrap_value=>ty_line.

    ls_line = line( iv_material = 'M1' iv_quantity = 2 iv_unit_value = 100 ).
    APPEND ls_line TO lt_lines.
    ls_line = line( iv_material = 'M2' iv_quantity = 3 iv_unit_value = 50 ).
    APPEND ls_line TO lt_lines.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_lines ) exp = 350 ).
  ENDMETHOD.

ENDCLASS.
