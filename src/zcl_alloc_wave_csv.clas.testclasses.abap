CLASS ltcl_alloc_wave_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_wave_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_wave_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_wave_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_lines TYPE zcl_alloc_wave=>ty_line_tt.

    DATA(lt_result) = mo_cut->build( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]
                                        exp = 'WAVE;INDEX;QUANTITY' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_lines TYPE zcl_alloc_wave=>ty_line_tt.
    DATA ls_wave  TYPE zcl_alloc_wave=>ty_line.

    ls_wave-wave = 2.
    ls_wave-index = 3.
    ls_wave-quantity = '5'.
    APPEND ls_wave TO lt_lines.

    DATA(lt_result) = mo_cut->build( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]
                                        exp = '2;3;5.000' ).
  ENDMETHOD.

ENDCLASS.
