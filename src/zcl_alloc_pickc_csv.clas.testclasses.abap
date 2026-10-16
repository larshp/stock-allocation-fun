CLASS ltcl_alloc_pickc_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pickc_csv.

    METHODS setup.

    METHODS header_only    FOR TESTING.
    METHODS complete_flag  FOR TESTING.
    METHODS short_flag     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_pickc_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pickc_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_picks TYPE zcl_alloc_pick_confirm=>ty_line_tt.

    DATA(lt_lines) = mo_cut->build( lt_picks ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'INDEX;PLANNED;CONFIRMED;DIFFERENCE;COMPLETE' ).
  ENDMETHOD.

  METHOD complete_flag.
    DATA lt_picks TYPE zcl_alloc_pick_confirm=>ty_line_tt.
    DATA ls_pick  TYPE zcl_alloc_pick_confirm=>ty_line.

    ls_pick-index = 1.
    ls_pick-planned = '10'.
    ls_pick-confirmed = '10'.
    ls_pick-difference = '0'.
    ls_pick-complete = abap_true.
    APPEND ls_pick TO lt_picks.

    DATA(lt_lines) = mo_cut->build( lt_picks ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '1;10.000;10.000;0.000;Y' ).
  ENDMETHOD.

  METHOD short_flag.
    DATA lt_picks TYPE zcl_alloc_pick_confirm=>ty_line_tt.
    DATA ls_pick  TYPE zcl_alloc_pick_confirm=>ty_line.

    ls_pick-index = 2.
    ls_pick-planned = '10'.
    ls_pick-confirmed = '6'.
    ls_pick-difference = '-4'.
    ls_pick-complete = abap_false.
    APPEND ls_pick TO lt_picks.

    DATA(lt_lines) = mo_cut->build( lt_picks ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '2;10.000;6.000;-4.000;N' ).
  ENDMETHOD.

ENDCLASS.
