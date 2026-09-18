CLASS ltcl_alloc_batch_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_batch_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_batch_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_batch_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_lines TYPE zcl_alloc_batch_split=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_lines )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_lines TYPE zcl_alloc_batch_split=>ty_line_tt.
    DATA ls_batch TYPE zcl_alloc_batch_split=>ty_line.

    ls_batch-batch = 1.
    ls_batch-matnr = 'MAT-1'.
    ls_batch-quantity = '7'.
    APPEND ls_batch TO lt_lines.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_lines )
      exp = '[{"batch":1,"matnr":"MAT-1","quantity":7.000}]' ).
  ENDMETHOD.

ENDCLASS.
