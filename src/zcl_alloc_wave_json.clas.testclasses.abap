CLASS ltcl_alloc_wave_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_wave_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_wave_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_wave_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_lines TYPE zcl_alloc_wave=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_lines )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_lines TYPE zcl_alloc_wave=>ty_line_tt.
    DATA ls_wave  TYPE zcl_alloc_wave=>ty_line.

    ls_wave-wave = 2.
    ls_wave-index = 3.
    ls_wave-quantity = '5'.
    APPEND ls_wave TO lt_lines.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_lines )
      exp = '[{"wave":2,"index":3,"quantity":5.000}]' ).
  ENDMETHOD.

ENDCLASS.
