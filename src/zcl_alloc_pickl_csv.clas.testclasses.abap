CLASS ltcl_alloc_pickl_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pickl_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_pickl_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pickl_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_lines TYPE zcl_alloc_pick_list=>ty_line_tt.

    DATA(lt_result) = mo_cut->build( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]
      exp = 'REQUIREMENT_ID;LGORT;CHARG;QUANTITY' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_lines TYPE zcl_alloc_pick_list=>ty_line_tt.
    DATA ls_pick  TYPE zcl_alloc_pick_list=>ty_line.

    ls_pick-requirement_id = 'REQ-1'.
    ls_pick-lgort = '0001'.
    ls_pick-charg = 'B1'.
    ls_pick-quantity = '5'.
    APPEND ls_pick TO lt_lines.

    DATA(lt_result) = mo_cut->build( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]
                                        exp = 'REQ-1;0001;B1;5.000' ).
  ENDMETHOD.

ENDCLASS.
