CLASS ltcl_alloc_return_status DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_status.

    METHODS setup.

    METHODS stages         FOR TESTING.
    METHODS unknown_stage  FOR TESTING.
    METHODS advances       FOR TESTING.
    METHODS final_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_status IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_status( ).
  ENDMETHOD.

  METHOD stages.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->stage( 1 ) exp = 'CREATE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->stage( 3 ) exp = 'INSPECT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->stage( 5 ) exp = 'CLOSE' ).
  ENDMETHOD.

  METHOD unknown_stage.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->stage( 0 ) exp = '' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->stage( 9 ) exp = '' ).
  ENDMETHOD.

  METHOD advances.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_stage( 'INSPECT' ) exp = 'SETTLE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_stage( 'CLOSE' ) exp = '' ).
  ENDMETHOD.

  METHOD final_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_final( 'CLOSE' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_final( 'CREATE' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
