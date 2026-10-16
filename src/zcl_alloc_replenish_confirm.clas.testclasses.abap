CLASS ltcl_alloc_replenish_confirm DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_confirm.
    DATA mt_prop TYPE zcl_alloc_replenish_confirm=>ty_proposal_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material  TYPE matnr
        iv_quantity  TYPE i
        iv_confirmed TYPE abap_bool.

    METHODS confirms_material FOR TESTING.
    METHODS reads_confirmed   FOR TESTING.
    METHODS converts_to_order FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_confirm IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_confirm( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_proposal TYPE zcl_alloc_replenish_confirm=>ty_proposal.

    ls_proposal-material = iv_material.
    ls_proposal-quantity = iv_quantity.
    ls_proposal-confirmed = iv_confirmed.
    APPEND ls_proposal TO mt_prop.
  ENDMETHOD.

  METHOD confirms_material.
    DATA lt_prop TYPE zcl_alloc_replenish_confirm=>ty_proposal_tt.

    add( iv_material = 'M1' iv_quantity = 10 iv_confirmed = abap_false ).
    add( iv_material = 'M2' iv_quantity = 5 iv_confirmed = abap_false ).

    lt_prop = mo_cut->confirm( it_proposals = mt_prop iv_material = 'M1' ).

    cl_abap_unit_assert=>assert_equals( act = lt_prop[ 1 ]-confirmed exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_prop[ 2 ]-confirmed exp = abap_false ).
  ENDMETHOD.

  METHOD reads_confirmed.
    add( iv_material = 'M1' iv_quantity = 10 iv_confirmed = abap_true ).
    add( iv_material = 'M2' iv_quantity = 5 iv_confirmed = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_confirmed( it_proposals = mt_prop iv_material = 'M1' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_confirmed( it_proposals = mt_prop iv_material = 'M2' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD converts_to_order.
    DATA lt_lines TYPE zcl_alloc_replenish_confirm=>ty_line_tt.

    add( iv_material = 'M1' iv_quantity = 10 iv_confirmed = abap_true ).
    add( iv_material = 'M2' iv_quantity = 5 iv_confirmed = abap_false ).

    lt_lines = mo_cut->convert_to_order( mt_prop ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-quantity exp = 10 ).
  ENDMETHOD.

ENDCLASS.
