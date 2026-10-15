CLASS ltcl_alloc_obsolete DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_obsolete.
    DATA mt_val TYPE zcl_alloc_obsolete=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS obsolete_rule FOR TESTING.
    METHODS risk_levels   FOR TESTING.
    METHODS counts_obsolete FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_obsolete IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_obsolete( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_val.
  ENDMETHOD.

  METHOD obsolete_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_obsolete( iv_age_days = 400 iv_threshold = 365 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_obsolete( iv_age_days = 100 iv_threshold = 365 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD risk_levels.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->risk( iv_age_days = 400 iv_threshold = 365 ) exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->risk( iv_age_days = 200 iv_threshold = 365 ) exp = 'MEDIUM' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->risk( iv_age_days = 50 iv_threshold = 365 ) exp = 'LOW' ).
  ENDMETHOD.

  METHOD counts_obsolete.
    add( 400 ).
    add( 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_obsolete( it_values = mt_val iv_threshold = 365 )
      exp = 1 ).
  ENDMETHOD.

ENDCLASS.
