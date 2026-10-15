CLASS ltcl_alloc_rma_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rma_check.

    METHODS setup.

    METHODS line
      IMPORTING
        iv_material    TYPE matnr
        iv_quantity    TYPE menge_d
        iv_reason      TYPE string
      RETURNING
        VALUE(rs_line) TYPE zcl_alloc_rma=>ty_line.

    METHODS accepts_valid   FOR TESTING.
    METHODS flags_material  FOR TESTING.
    METHODS flags_quantity  FOR TESTING.
    METHODS reports_all     FOR TESTING.
    METHODS rejects_bad     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rma_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rma_check( ).
  ENDMETHOD.

  METHOD line.
    rs_line-material = iv_material.
    rs_line-quantity = iv_quantity.
    rs_line-reason = iv_reason.
  ENDMETHOD.

  METHOD accepts_valid.
    DATA ls_line   TYPE zcl_alloc_rma=>ty_line.
    DATA lt_reason TYPE zcl_alloc_rma_check=>ty_reason_tt.

    ls_line = line( iv_material = 'M1' iv_quantity = 1 iv_reason = 'DAMAGED' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( ls_line ) exp = abap_true ).

    lt_reason = mo_cut->reasons( ls_line ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_reason ) exp = 0 ).
  ENDMETHOD.

  METHOD flags_material.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( line( iv_material = '' iv_quantity = 1
                                     iv_reason = 'DAMAGED' ) )
      exp = abap_false ).
  ENDMETHOD.

  METHOD flags_quantity.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( line( iv_material = 'M1' iv_quantity = 0
                                     iv_reason = 'DAMAGED' ) )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_all.
    DATA lt_reason TYPE zcl_alloc_rma_check=>ty_reason_tt.

    lt_reason = mo_cut->reasons( line( iv_material = '' iv_quantity = 0
                                       iv_reason = '' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_reason ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_reason[ 1 ] exp = 'MATERIAL_MISSING' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_reason[ 3 ] exp = 'REASON_MISSING' ).
  ENDMETHOD.

  METHOD rejects_bad.
    DATA lt_lines TYPE zcl_alloc_rma=>ty_line_tt.
    DATA lt_bad   TYPE zcl_alloc_rma=>ty_line_tt.
    DATA ls_line  TYPE zcl_alloc_rma=>ty_line.

    ls_line = line( iv_material = 'M1' iv_quantity = 1 iv_reason = 'A' ).
    APPEND ls_line TO lt_lines.
    ls_line = line( iv_material = '' iv_quantity = 1 iv_reason = 'A' ).
    APPEND ls_line TO lt_lines.
    ls_line = line( iv_material = 'M3' iv_quantity = -1 iv_reason = 'B' ).
    APPEND ls_line TO lt_lines.

    lt_bad = mo_cut->reject( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_bad ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_bad[ 1 ]-material exp = '' ).
    cl_abap_unit_assert=>assert_equals( act = lt_bad[ 2 ]-material exp = 'M3' ).
  ENDMETHOD.

ENDCLASS.
