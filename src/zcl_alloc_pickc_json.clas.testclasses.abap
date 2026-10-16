CLASS ltcl_alloc_pickc_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pickc_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS complete   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_pickc_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pickc_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_picks TYPE zcl_alloc_pick_confirm=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_picks )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD complete.
    DATA lt_picks TYPE zcl_alloc_pick_confirm=>ty_line_tt.
    DATA ls_pick  TYPE zcl_alloc_pick_confirm=>ty_line.

    ls_pick-index = 1.
    ls_pick-planned = '10'.
    ls_pick-confirmed = '10'.
    ls_pick-difference = '0'.
    ls_pick-complete = abap_true.
    APPEND ls_pick TO lt_picks.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_picks )
      exp = '[{"index":1,"planned":10.000,"confirmed":10.000,' &&
            '"difference":0.000,"complete":true}]' ).
  ENDMETHOD.

ENDCLASS.
