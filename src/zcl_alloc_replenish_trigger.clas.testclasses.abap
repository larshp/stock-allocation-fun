CLASS ltcl_alloc_replenish_trigger DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_trigger.
    DATA mt_trg TYPE zcl_alloc_replenish_trigger=>ty_trigger_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_need     TYPE i.

    METHODS counts_triggers FOR TESTING.
    METHODS sums_quantity   FOR TESTING.
    METHODS builds_summary  FOR TESTING.
    METHODS empty_input     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_trigger IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_trigger( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_trigger TYPE zcl_alloc_replenish_trigger=>ty_trigger.

    ls_trigger-material = iv_material.
    ls_trigger-need = iv_need.
    APPEND ls_trigger TO mt_trg.
  ENDMETHOD.

  METHOD counts_triggers.
    add( iv_material = 'M1' iv_need = 10 ).
    add( iv_material = 'M2' iv_need = 0 ).
    add( iv_material = 'M3' iv_need = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->trigger_count( mt_trg ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_quantity.
    add( iv_material = 'M1' iv_need = 10 ).
    add( iv_material = 'M2' iv_need = 0 ).
    add( iv_material = 'M3' iv_need = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_quantity( mt_trg ) exp = 15 ).
  ENDMETHOD.

  METHOD builds_summary.
    DATA ls_summary TYPE zcl_alloc_replenish_trigger=>ty_summary.

    add( iv_material = 'M1' iv_need = 10 ).
    add( iv_material = 'M2' iv_need = 0 ).
    add( iv_material = 'M3' iv_need = 5 ).

    ls_summary = mo_cut->build( mt_trg ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-trigger_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-total_quantity exp = 15 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->trigger_count( mt_trg ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
