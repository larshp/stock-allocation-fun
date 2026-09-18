CLASS ltcl_alloc_change_read DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_change_read.

    METHODS setup.

    METHODS add_change
      IMPORTING
        it_changes        TYPE zcl_alloc_change_doc=>ty_change_tt
        iv_object         TYPE c
        iv_key            TYPE c
        iv_field          TYPE c
      RETURNING
        VALUE(rt_changes) TYPE zcl_alloc_change_doc=>ty_change_tt.

    METHODS empty_changes FOR TESTING.
    METHODS filters_by_key FOR TESTING.
    METHODS counts_field  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_change_read IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_change_read( ).
  ENDMETHOD.

  METHOD add_change.
    DATA ls_change TYPE zcl_alloc_change_doc=>ty_change.

    rt_changes = it_changes.
    ls_change-object = iv_object.
    ls_change-key = iv_key.
    ls_change-field = iv_field.
    ls_change-old_value = 'A'.
    ls_change-new_value = 'B'.
    APPEND ls_change TO rt_changes.
  ENDMETHOD.

  METHOD empty_changes.
    DATA lt_changes TYPE zcl_alloc_change_doc=>ty_change_tt.
    DATA ls_input   TYPE zcl_alloc_change_read=>ty_input.

    ls_input-changes = lt_changes.
    ls_input-object = 'ZSTOCKRUN'.
    ls_input-key = 'R1'.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->of_object( ls_input ) ).
  ENDMETHOD.

  METHOD filters_by_key.
    DATA lt_changes TYPE zcl_alloc_change_doc=>ty_change_tt.
    DATA ls_input   TYPE zcl_alloc_change_read=>ty_input.

    lt_changes = add_change( it_changes = lt_changes
                             iv_object  = 'ZSTOCKRUN'
                             iv_key     = 'R1'
                             iv_field   = 'STATUS' ).
    lt_changes = add_change( it_changes = lt_changes
                             iv_object  = 'ZSTOCKRUN'
                             iv_key     = 'R2'
                             iv_field   = 'STATUS' ).

    ls_input-changes = lt_changes.
    ls_input-object = 'ZSTOCKRUN'.
    ls_input-key = 'R1'.

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->of_object( ls_input ) ) exp = 1 ).
  ENDMETHOD.

  METHOD counts_field.
    DATA lt_changes TYPE zcl_alloc_change_doc=>ty_change_tt.
    DATA ls_input   TYPE zcl_alloc_change_read=>ty_field_input.

    lt_changes = add_change( it_changes = lt_changes
                             iv_object  = 'ZSTOCKRUN'
                             iv_key     = 'R1'
                             iv_field   = 'STATUS' ).
    lt_changes = add_change( it_changes = lt_changes
                             iv_object  = 'ZSTOCKRUN'
                             iv_key     = 'R2'
                             iv_field   = 'STATUS' ).
    lt_changes = add_change( it_changes = lt_changes
                             iv_object  = 'ZSTOCKRUN'
                             iv_key     = 'R1'
                             iv_field   = 'QTY' ).

    ls_input-changes = lt_changes.
    ls_input-field = 'STATUS'.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->field_count( ls_input ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
