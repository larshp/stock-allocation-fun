CLASS ltcl_alloc_pick_confirm DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pick_confirm.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_planned    TYPE menge_d
        iv_confirmed  TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_pick_confirm=>ty_input.

    METHODS empty_planned  FOR TESTING.
    METHODS complete_line  FOR TESTING.
    METHODS short_line     FOR TESTING.
    METHODS missing_pick   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_pick_confirm IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pick_confirm( ).
  ENDMETHOD.

  METHOD input.
    APPEND iv_planned TO rs_row-planned.
    APPEND iv_confirmed TO rs_row-confirmed.
  ENDMETHOD.

  METHOD empty_planned.
    DATA ls_input TYPE zcl_alloc_pick_confirm=>ty_input.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->confirm( ls_input ) ).
  ENDMETHOD.

  METHOD complete_line.
    DATA ls_input TYPE zcl_alloc_pick_confirm=>ty_input.

    ls_input = input( iv_planned = '10' iv_confirmed = '10' ).

    DATA(lt_lines) = mo_cut->confirm( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-difference
                                        exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-complete
                                        exp = abap_true ).
  ENDMETHOD.

  METHOD short_line.
    DATA ls_input TYPE zcl_alloc_pick_confirm=>ty_input.

    ls_input = input( iv_planned = '10' iv_confirmed = '6' ).

    DATA(lt_lines) = mo_cut->confirm( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-difference
                                        exp = '-4' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-complete
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD missing_pick.
    DATA ls_input TYPE zcl_alloc_pick_confirm=>ty_input.

    APPEND '10' TO ls_input-planned.
    APPEND '5' TO ls_input-planned.
    APPEND '10' TO ls_input-confirmed.

    DATA(lt_lines) = mo_cut->confirm( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-confirmed
                                        exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-difference
                                        exp = '-5' ).
  ENDMETHOD.

ENDCLASS.
