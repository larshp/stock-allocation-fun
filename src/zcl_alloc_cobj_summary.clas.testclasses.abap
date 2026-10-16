CLASS ltcl_alloc_cobj_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cobj_summary.
    DATA mt_line TYPE zcl_alloc_cobj_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_object TYPE string
        iv_cost   TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS counts_objects FOR TESTING.
    METHODS sums_total     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cobj_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cobj_summary( ).

    add( iv_object = 'O1' iv_cost = 600 ).
    add( iv_object = 'O2' iv_cost = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_cobj_summary=>ty_line.

    ls_line-object = iv_object.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_cobj_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-object_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 900 ).
  ENDMETHOD.

  METHOD counts_objects.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->object_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 900 ).
  ENDMETHOD.

ENDCLASS.
