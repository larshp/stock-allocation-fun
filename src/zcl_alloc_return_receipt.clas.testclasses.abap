CLASS ltcl_alloc_return_receipt DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_return_receipt.
    DATA mt_auth TYPE zcl_alloc_return_receipt=>ty_authorised_tt.
    DATA mt_recv TYPE zcl_alloc_return_receipt=>ty_received_tt.

    METHODS setup.

    METHODS auth
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE menge_d.

    METHODS recv
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE menge_d.

    METHODS matches_by_material FOR TESTING.
    METHODS ignores_unknown     FOR TESTING.
    METHODS totals_and_shorts   FOR TESTING.
    METHODS empty_input         FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_receipt IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_receipt( ).
  ENDMETHOD.

  METHOD auth.
    DATA ls_line TYPE zcl_alloc_return_receipt=>ty_authorised.

    ls_line-material = iv_material.
    ls_line-quantity = iv_quantity.
    APPEND ls_line TO mt_auth.
  ENDMETHOD.

  METHOD recv.
    DATA ls_line TYPE zcl_alloc_return_receipt=>ty_received.

    ls_line-material = iv_material.
    ls_line-quantity = iv_quantity.
    APPEND ls_line TO mt_recv.
  ENDMETHOD.

  METHOD matches_by_material.
    DATA lt_lines TYPE zcl_alloc_return_receipt=>ty_line_tt.

    auth( iv_material = 'M1' iv_quantity = 10 ).
    auth( iv_material = 'M2' iv_quantity = 5 ).
    recv( iv_material = 'M1' iv_quantity = 8 ).
    recv( iv_material = 'M2' iv_quantity = 5 ).

    lt_lines = mo_cut->build( it_authorised = mt_auth
                              it_received   = mt_recv ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]-received exp = 8 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]-difference exp = -2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ]-difference exp = 0 ).
  ENDMETHOD.

  METHOD ignores_unknown.
    DATA lt_lines TYPE zcl_alloc_return_receipt=>ty_line_tt.

    auth( iv_material = 'M1' iv_quantity = 10 ).
    recv( iv_material = 'M1' iv_quantity = 10 ).
    recv( iv_material = 'M9' iv_quantity = 4 ).

    lt_lines = mo_cut->build( it_authorised = mt_auth
                              it_received   = mt_recv ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_lines ) exp = 10 ).
  ENDMETHOD.

  METHOD totals_and_shorts.
    DATA lt_lines TYPE zcl_alloc_return_receipt=>ty_line_tt.

    auth( iv_material = 'M1' iv_quantity = 10 ).
    auth( iv_material = 'M2' iv_quantity = 5 ).
    auth( iv_material = 'M3' iv_quantity = 3 ).
    recv( iv_material = 'M1' iv_quantity = 8 ).
    recv( iv_material = 'M2' iv_quantity = 5 ).
    recv( iv_material = 'M3' iv_quantity = 3 ).

    lt_lines = mo_cut->build( it_authorised = mt_auth
                              it_received   = mt_recv ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_lines ) exp = 16 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->short_lines( lt_lines ) exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_lines TYPE zcl_alloc_return_receipt=>ty_line_tt.

    lt_lines = mo_cut->build( it_authorised = mt_auth
                              it_received   = mt_recv ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->short_lines( lt_lines ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
