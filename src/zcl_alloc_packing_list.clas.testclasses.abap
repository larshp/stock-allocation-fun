CLASS ltcl_alloc_packing_list DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_packing_list.
    DATA mt_lin TYPE zcl_alloc_packing_list=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_qty      TYPE menge_d.

    METHODS numbers_lines    FOR TESTING.
    METHODS sums_material    FOR TESTING.
    METHODS keeps_first_seen FOR TESTING.
    METHODS skips_zero       FOR TESTING.
    METHODS empty_input      FOR TESTING.
    METHODS total_quantity   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_packing_list IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_packing_list( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_packing_list=>ty_line.

    ls_line-material = iv_material.
    ls_line-quantity = iv_qty.
    APPEND ls_line TO mt_lin.
  ENDMETHOD.

  METHOD numbers_lines.
    DATA lt_packed TYPE zcl_alloc_packing_list=>ty_packed_tt.

    add( iv_material = 'M1' iv_qty = 10 ).
    add( iv_material = 'M2' iv_qty = 5 ).

    lt_packed = mo_cut->build( it_lines = mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lt_packed[ 1 ]-pos exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_packed[ 2 ]-pos exp = 2 ).
  ENDMETHOD.

  METHOD sums_material.
    DATA lt_packed TYPE zcl_alloc_packing_list=>ty_packed_tt.

    add( iv_material = 'M1' iv_qty = 10 ).
    add( iv_material = 'M1' iv_qty = 4 ).

    lt_packed = mo_cut->build( it_lines = mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_packed ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_packed[ 1 ]-quantity exp = 14 ).
  ENDMETHOD.

  METHOD keeps_first_seen.
    DATA lt_packed TYPE zcl_alloc_packing_list=>ty_packed_tt.

    add( iv_material = 'M1' iv_qty = 10 ).
    add( iv_material = 'M2' iv_qty = 5 ).
    add( iv_material = 'M1' iv_qty = 1 ).

    lt_packed = mo_cut->build( it_lines = mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lt_packed[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_packed[ 1 ]-quantity exp = 11 ).
    cl_abap_unit_assert=>assert_equals( act = lt_packed[ 2 ]-material exp = 'M2' ).
  ENDMETHOD.

  METHOD skips_zero.
    DATA lt_packed TYPE zcl_alloc_packing_list=>ty_packed_tt.

    add( iv_material = 'M1' iv_qty = 0 ).
    add( iv_material = 'M2' iv_qty = 5 ).

    lt_packed = mo_cut->build( it_lines = mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_packed ) exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_packed TYPE zcl_alloc_packing_list=>ty_packed_tt.

    lt_packed = mo_cut->build( it_lines = mt_lin ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_packed ) exp = 0 ).
  ENDMETHOD.

  METHOD total_quantity.
    DATA lt_packed TYPE zcl_alloc_packing_list=>ty_packed_tt.

    add( iv_material = 'M1' iv_qty = 10 ).
    add( iv_material = 'M2' iv_qty = 5 ).

    lt_packed = mo_cut->build( it_lines = mt_lin ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_quantity( it_packed = lt_packed ) exp = 15 ).
  ENDMETHOD.

ENDCLASS.
