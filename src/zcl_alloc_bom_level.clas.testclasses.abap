CLASS ltcl_alloc_bom_level DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bom_level.

    METHODS setup.

    METHODS reads_level FOR TESTING.
    METHODS top_rule    FOR TESTING.
    METHODS reads_depth FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bom_level IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bom_level( ).
  ENDMETHOD.

  METHOD reads_level.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level_of( 0 ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level_of( 2 ) exp = 3 ).
  ENDMETHOD.

  METHOD top_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_top( 1 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_top( 2 ) exp = abap_false ).
  ENDMETHOD.

  METHOD reads_depth.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->depth( 1 ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->depth( 3 ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
