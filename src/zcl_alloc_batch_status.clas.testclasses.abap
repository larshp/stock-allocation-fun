CLASS ltcl_alloc_batch_status DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_batch_status.

    METHODS setup.

    METHODS known_statuses   FOR TESTING.
    METHODS unknown_status   FOR TESTING.
    METHODS active_usable    FOR TESTING.
    METHODS restricted_use   FOR TESTING.
    METHODS blocked_not_use  FOR TESTING.
    METHODS expired_blocked  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_batch_status IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_batch_status( ).
  ENDMETHOD.

  METHOD known_statuses.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_known( 'ACTIVE' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_known( 'EXPIRED' ) exp = abap_true ).
  ENDMETHOD.

  METHOD unknown_status.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_known( 'WEIRD' ) exp = abap_false ).
  ENDMETHOD.

  METHOD active_usable.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->can_use( 'ACTIVE' ) exp = abap_true ).
  ENDMETHOD.

  METHOD restricted_use.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->can_use( 'RESTRICTED' ) exp = abap_true ).
  ENDMETHOD.

  METHOD blocked_not_use.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->can_use( 'BLOCKED' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_blocked( 'BLOCKED' ) exp = abap_true ).
  ENDMETHOD.

  METHOD expired_blocked.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_blocked( 'EXPIRED' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->can_use( 'WEIRD' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
