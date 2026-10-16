CLASS ltcl_alloc_rout_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rout_summary.
    DATA mt_line TYPE zcl_alloc_rout_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_operation TYPE string
        iv_time      TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS counts_ops     FOR TESTING.
    METHODS sums_time      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rout_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rout_summary( ).

    add( iv_operation = 'OP1' iv_time = 60 ).
    add( iv_operation = 'OP2' iv_time = 90 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_rout_summary=>ty_line.

    ls_line-operation = iv_operation.
    ls_line-time = iv_time.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_rout_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-operation_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_time exp = 150 ).
  ENDMETHOD.

  METHOD counts_ops.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->operation_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_time.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_time( mt_line ) exp = 150 ).
  ENDMETHOD.

ENDCLASS.
