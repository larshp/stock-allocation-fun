CLASS ltcl_alloc_mrp_exception DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mrp_exception.
    DATA mt_item TYPE zcl_alloc_mrp_exception=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_code     TYPE string.

    METHODS codes        FOR TESTING.
    METHODS exception_rule FOR TESTING.
    METHODS counts_codes FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_mrp_exception IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mrp_exception( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_mrp_exception=>ty_item.

    ls_item-material = iv_material.
    ls_item-code = iv_code.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD codes.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->code( iv_net_req = 10 iv_days_late = 0 ) exp = 'NEW' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->code( iv_net_req = 10 iv_days_late = 5 ) exp = 'RESCHEDULE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->code( iv_net_req = 0 iv_days_late = 0 ) exp = 'NONE' ).
  ENDMETHOD.

  METHOD exception_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_exception( iv_net_req = 10 iv_days_late = 0 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_exception( iv_net_req = 0 iv_days_late = 0 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_codes.
    add( iv_material = 'M1' iv_code = 'NEW' ).
    add( iv_material = 'M2' iv_code = 'NONE' ).
    add( iv_material = 'M3' iv_code = 'NEW' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_of( it_items = mt_item iv_code = 'NEW' ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
