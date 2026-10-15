CLASS ltcl_alloc_drv_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_drv_summary.
    DATA mt_line TYPE zcl_alloc_drv_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name  TYPE string
        iv_value TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS sums_total     FOR TESTING.
    METHODS counts_drivers FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_drv_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_drv_summary( ).

    add( iv_name = 'A' iv_value = 100 ).
    add( iv_name = 'B' iv_value = 200 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_drv_summary=>ty_line.

    ls_line-name = iv_name.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_drv_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-driver_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 300 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 300 ).
  ENDMETHOD.

  METHOD counts_drivers.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->driver_count( mt_line ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
