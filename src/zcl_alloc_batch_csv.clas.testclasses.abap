CLASS ltcl_alloc_batch_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_batch_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_batch_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_batch_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_lines TYPE zcl_alloc_batch_split=>ty_line_tt.

    DATA(lt_result) = mo_cut->build( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]
                                        exp = 'BATCH;MATNR;QUANTITY' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_lines TYPE zcl_alloc_batch_split=>ty_line_tt.
    DATA ls_batch TYPE zcl_alloc_batch_split=>ty_line.

    ls_batch-batch = 1.
    ls_batch-matnr = 'MAT-1'.
    ls_batch-quantity = '7'.
    APPEND ls_batch TO lt_lines.

    DATA(lt_result) = mo_cut->build( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]
                                        exp = '1;MAT-1;7.000' ).
  ENDMETHOD.

ENDCLASS.
