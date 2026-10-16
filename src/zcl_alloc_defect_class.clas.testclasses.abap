CLASS ltcl_alloc_defect_class DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_defect_class.
    DATA mt_def TYPE zcl_alloc_defect_class=>ty_defect_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_code TYPE string.

    METHODS classifies_critical FOR TESTING.
    METHODS classifies_major    FOR TESTING.
    METHODS classifies_minor    FOR TESTING.
    METHODS short_code          FOR TESTING.
    METHODS worst_wins          FOR TESTING.
    METHODS worst_empty         FOR TESTING.
    METHODS counts_class        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_defect_class IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_defect_class( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_def TYPE zcl_alloc_defect_class=>ty_defect.

    ls_def-defect_code = iv_code.
    ls_def-quantity = 1.
    APPEND ls_def TO mt_def.
  ENDMETHOD.

  METHOD classifies_critical.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( 'CRIT01' ) exp = 'CRITICAL' ).
  ENDMETHOD.

  METHOD classifies_major.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( 'MAJ02' ) exp = 'MAJOR' ).
  ENDMETHOD.

  METHOD classifies_minor.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( 'MIN03' ) exp = 'MINOR' ).
  ENDMETHOD.

  METHOD short_code.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( 'AB' ) exp = 'MINOR' ).
  ENDMETHOD.

  METHOD worst_wins.
    add( iv_code = 'MIN03' ).
    add( iv_code = 'MAJ02' ).
    add( iv_code = 'CRIT01' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst( mt_def ) exp = 'CRITICAL' ).
  ENDMETHOD.

  METHOD worst_empty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst( mt_def ) exp = '' ).
  ENDMETHOD.

  METHOD counts_class.
    add( iv_code = 'MAJ01' ).
    add( iv_code = 'MAJ02' ).
    add( iv_code = 'MIN01' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_of( it_defects = mt_def iv_class = 'MAJOR' )
      exp = 2 ).
  ENDMETHOD.

ENDCLASS.
