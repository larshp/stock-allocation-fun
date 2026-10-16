CLASS ltcl_alloc_pickl_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pickl_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_pickl_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pickl_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_lines TYPE zcl_alloc_pick_list=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_lines )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_lines TYPE zcl_alloc_pick_list=>ty_line_tt.
    DATA ls_pick  TYPE zcl_alloc_pick_list=>ty_line.

    ls_pick-requirement_id = 'REQ-1'.
    ls_pick-lgort = '0001'.
    ls_pick-charg = 'B1'.
    ls_pick-quantity = '5'.
    APPEND ls_pick TO lt_lines.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_lines )
      exp = '[{"requirement_id":"REQ-1","lgort":"0001","charg":"B1",' &&
            '"quantity":5.000}]' ).
  ENDMETHOD.

ENDCLASS.
