CLASS ltcl_alloc_interco_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_interco_summary.
    DATA mt_line TYPE zcl_alloc_interco_summary=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_entity TYPE string
        iv_amount TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS sums_total     FOR TESTING.
    METHODS counts_entities FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_interco_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_interco_summary( ).

    add( iv_entity = 'A' iv_amount = 500 ).
    add( iv_entity = 'B' iv_amount = 300 ).
    add( iv_entity = 'A' iv_amount = 200 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_interco_summary=>ty_line.

    ls_line-entity = iv_entity.
    ls_line-amount = iv_amount.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_interco_summary=>ty_summary.

    ls_summary = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-entity_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 1000 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 1000 ).
  ENDMETHOD.

  METHOD counts_entities.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->entity_count( mt_line ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
