CLASS ltcl_alloc_checksum_reg DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_checksum_reg.

    METHODS setup.

    METHODS register_and_verify FOR TESTING.
    METHODS verify_mismatch     FOR TESTING.
    METHODS verify_unknown      FOR TESTING.
    METHODS re_register_updates FOR TESTING.
    METHODS reads_checksum      FOR TESTING.
    METHODS count_entries       FOR TESTING.
    METHODS reset_clears        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_checksum_reg IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_checksum_reg( ).
  ENDMETHOD.

  METHOD register_and_verify.
    mo_cut->register( iv_key = 'RUN-1' iv_checksum = 42 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->verify( iv_key = 'RUN-1' iv_checksum = 42 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD verify_mismatch.
    mo_cut->register( iv_key = 'RUN-1' iv_checksum = 42 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->verify( iv_key = 'RUN-1' iv_checksum = 43 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD verify_unknown.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->verify( iv_key = 'NOPE' iv_checksum = 0 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD re_register_updates.
    mo_cut->register( iv_key = 'RUN-1' iv_checksum = 42 ).
    mo_cut->register( iv_key = 'RUN-1' iv_checksum = 99 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->checksum_of( 'RUN-1' ) exp = 99 ).
  ENDMETHOD.

  METHOD reads_checksum.
    mo_cut->register( iv_key = 'RUN-2' iv_checksum = 7 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->checksum_of( 'RUN-2' ) exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->checksum_of( 'MISSING' ) exp = 0 ).
  ENDMETHOD.

  METHOD count_entries.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).

    mo_cut->register( iv_key = 'A' iv_checksum = 1 ).
    mo_cut->register( iv_key = 'B' iv_checksum = 2 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

  METHOD reset_clears.
    mo_cut->register( iv_key = 'A' iv_checksum = 1 ).
    mo_cut->reset( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->verify( iv_key = 'A' iv_checksum = 1 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
