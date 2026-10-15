CLASS ltcl_alloc_return_hold DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_hold.

    METHODS setup.

    METHODS places_holds  FOR TESTING.
    METHODS ignores_bad   FOR TESTING.
    METHODS detects_hold  FOR TESTING.
    METHODS counts_holds  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_hold IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_hold( ).
  ENDMETHOD.

  METHOD places_holds.
    DATA lt_holds TYPE zcl_alloc_return_hold=>ty_hold_tt.

    lt_holds = mo_cut->place( it_holds = lt_holds iv_material = 'M1'
                              iv_reason = 'QC' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_holds ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_holds[ 1 ]-reason exp = 'QC' ).
  ENDMETHOD.

  METHOD ignores_bad.
    DATA lt_holds TYPE zcl_alloc_return_hold=>ty_hold_tt.

    lt_holds = mo_cut->place( it_holds = lt_holds iv_material = ''
                              iv_reason = 'QC' ).
    lt_holds = mo_cut->place( it_holds = lt_holds iv_material = 'M1'
                              iv_reason = '' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_holds ) exp = 0 ).
  ENDMETHOD.

  METHOD detects_hold.
    DATA lt_holds TYPE zcl_alloc_return_hold=>ty_hold_tt.

    lt_holds = mo_cut->place( it_holds = lt_holds iv_material = 'M1'
                              iv_reason = 'QC' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_on_hold( it_holds = lt_holds iv_material = 'M1' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_on_hold( it_holds = lt_holds iv_material = 'M2' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_holds.
    DATA lt_holds TYPE zcl_alloc_return_hold=>ty_hold_tt.

    lt_holds = mo_cut->place( it_holds = lt_holds iv_material = 'M1'
                              iv_reason = 'QC' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->hold_count( lt_holds ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
