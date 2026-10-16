CLASS ltcl_alloc_copro_share DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_copro_share.
    DATA mt_line TYPE zcl_alloc_copro_share=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_product TYPE string
        iv_qty     TYPE i.

    METHODS reads_share   FOR TESTING.
    METHODS picks_largest FOR TESTING.
    METHODS zero_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_copro_share IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_copro_share( ).

    add( iv_product = 'P1' iv_qty = 30 ).
    add( iv_product = 'P2' iv_qty = 60 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_copro_share=>ty_line.

    ls_line-product = iv_product.
    ls_line-qty = iv_qty.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD reads_share.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share_percent( iv_part_qty = 30 iv_total_qty = 100 )
      exp = 30 ).
  ENDMETHOD.

  METHOD picks_largest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( mt_line ) exp = 'P2' ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 30 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
