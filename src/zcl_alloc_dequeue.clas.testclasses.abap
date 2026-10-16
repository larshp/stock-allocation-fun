CLASS ltcl_alloc_dequeue DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_dequeue.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_object     TYPE c
        iv_key        TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_dequeue=>ty_input.

    METHODS dequeues_ok    FOR TESTING.
    METHODS dequeue_empty  FOR TESTING.
    METHODS counts_distinct FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_dequeue IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_dequeue( ).
  ENDMETHOD.

  METHOD input.
    rs_row-object = iv_object.
    rs_row-key = iv_key.
  ENDMETHOD.

  METHOD dequeues_ok.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->dequeue( input( iv_object = 'ZSTOCKRUN'
                                    iv_key    = 'R1' ) )
      exp = abap_true ).
  ENDMETHOD.

  METHOD dequeue_empty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->dequeue( input( iv_object = ''
                                    iv_key    = 'R1' ) )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_distinct.
    DATA lt_inputs TYPE zcl_alloc_dequeue=>ty_input_tt.

    APPEND input( iv_object = 'ZSTOCKRUN' iv_key = 'R1' ) TO lt_inputs.
    APPEND input( iv_object = 'ZSTOCKRUN' iv_key = 'R2' ) TO lt_inputs.
    APPEND input( iv_object = 'ZALLOC' iv_key = 'R1' ) TO lt_inputs.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->distinct_count( lt_inputs ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
