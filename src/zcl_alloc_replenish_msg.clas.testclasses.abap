CLASS ltcl_alloc_replenish_msg DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_msg.
    DATA mt_msg TYPE zcl_alloc_replenish_msg=>ty_msg_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_success  TYPE abap_bool.

    METHODS message_text  FOR TESTING.
    METHODS success_rule  FOR TESTING.
    METHODS counts_errors FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_msg IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_msg( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_msg TYPE zcl_alloc_replenish_msg=>ty_msg.

    ls_msg-material = iv_material.
    ls_msg-success = iv_success.
    APPEND ls_msg TO mt_msg.
  ENDMETHOD.

  METHOD message_text.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->message( abap_true ) exp = 'REPLENISHMENT CONFIRMED' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->message( abap_false ) exp = 'REPLENISHMENT FAILED' ).
  ENDMETHOD.

  METHOD success_rule.
    add( iv_material = 'M1' iv_success = abap_true ).
    add( iv_material = 'M2' iv_success = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_success( mt_msg ) exp = abap_true ).

    add( iv_material = 'M3' iv_success = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_success( mt_msg ) exp = abap_false ).
  ENDMETHOD.

  METHOD counts_errors.
    add( iv_material = 'M1' iv_success = abap_true ).
    add( iv_material = 'M2' iv_success = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->error_count( mt_msg ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
