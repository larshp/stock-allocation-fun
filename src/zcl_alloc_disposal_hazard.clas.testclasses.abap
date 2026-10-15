CLASS ltcl_alloc_disposal_hazard DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_disposal_hazard.

    METHODS setup.

    METHODS maps_classes   FOR TESTING.
    METHODS hazardous_rule FOR TESTING.
    METHODS approval_rule  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_disposal_hazard IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_disposal_hazard( ).
  ENDMETHOD.

  METHOD maps_classes.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->class_of( 'FLAMMABLE' ) exp = 'HAZ_3' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->class_of( 'CORROSIVE' ) exp = 'HAZ_8' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->class_of( '' ) exp = 'NONE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->class_of( 'OTHER' ) exp = 'HAZ_9' ).
  ENDMETHOD.

  METHOD hazardous_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_hazardous( 'HAZ_3' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_hazardous( 'NONE' ) exp = abap_false ).
  ENDMETHOD.

  METHOD approval_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->needs_approval( 'HAZ_6' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->needs_approval( 'HAZ_3' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
