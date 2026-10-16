CLASS ltcl_alloc_cobj_share DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cobj_share.
    DATA mt_value TYPE zcl_alloc_cobj_share=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS computes_share FOR TESTING.
    METHODS picks_largest  FOR TESTING.
    METHODS zero_rule      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cobj_share IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cobj_share( ).

    add( iv_value = 600 ).
    add( iv_value = 300 ).
    add( iv_value = 100 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_value.
  ENDMETHOD.

  METHOD computes_share.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share_percent( iv_part = 300 iv_whole = 1000 )
      exp = 30 ).
  ENDMETHOD.

  METHOD picks_largest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( mt_value ) exp = 600 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 600 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
