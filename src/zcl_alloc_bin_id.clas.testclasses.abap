CLASS ltcl_alloc_bin_id DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bin_id.
    DATA mt_par TYPE zcl_alloc_bin_decompose=>ty_parts_tt.

    METHODS setup.

    METHODS build_joins     FOR TESTING.
    METHODS build_skips     FOR TESTING.
    METHODS build_empty     FOR TESTING.
    METHODS normalize_trims FOR TESTING.
    METHODS empty_flag      FOR TESTING.
    METHODS empty_flag_no   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bin_id IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bin_id( ).
  ENDMETHOD.

  METHOD build_joins.
    APPEND 'A' TO mt_par.
    APPEND '01' TO mt_par.
    APPEND '03' TO mt_par.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( mt_par ) exp = 'A-01-03' ).
  ENDMETHOD.

  METHOD build_skips.
    APPEND 'A' TO mt_par.
    APPEND '' TO mt_par.
    APPEND '03' TO mt_par.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( mt_par ) exp = 'A-03' ).
  ENDMETHOD.

  METHOD build_empty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( mt_par ) exp = '' ).
  ENDMETHOD.

  METHOD normalize_trims.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->normalize( '-A--01-' ) exp = 'A-01' ).
  ENDMETHOD.

  METHOD empty_flag.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_empty( '--' ) exp = abap_true ).
  ENDMETHOD.

  METHOD empty_flag_no.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_empty( '-A-' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
