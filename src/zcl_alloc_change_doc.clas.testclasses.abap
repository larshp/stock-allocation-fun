CLASS ltcl_alloc_change_doc DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_change_doc.

    METHODS setup.

    METHODS change
      IMPORTING
        iv_object     TYPE c
        iv_field      TYPE c
        iv_old        TYPE c
        iv_new        TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_change_doc=>ty_change.

    METHODS input
      IMPORTING
        it_changes    TYPE zcl_alloc_change_doc=>ty_change_tt
        is_change     TYPE zcl_alloc_change_doc=>ty_change
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_change_doc=>ty_input.

    METHODS adds_change   FOR TESTING.
    METHODS skips_noop    FOR TESTING.
    METHODS keeps_previous FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_change_doc IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_change_doc( ).
  ENDMETHOD.

  METHOD change.
    rs_row-object = iv_object.
    rs_row-key = 'R1'.
    rs_row-field = iv_field.
    rs_row-old_value = iv_old.
    rs_row-new_value = iv_new.
  ENDMETHOD.

  METHOD input.
    rs_row-changes = it_changes.
    rs_row-change = is_change.
  ENDMETHOD.

  METHOD adds_change.
    DATA lt_changes TYPE zcl_alloc_change_doc=>ty_change_tt.
    DATA ls_input   TYPE zcl_alloc_change_doc=>ty_input.

    ls_input-changes = lt_changes.
    ls_input-change = change( iv_object = 'ZSTOCKRUN'
                              iv_field  = 'STATUS'
                              iv_old    = 'NEW'
                              iv_new    = 'DONE' ).

    DATA(lt_new) = mo_cut->add( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_new[ 1 ]-field exp = 'STATUS' ).
  ENDMETHOD.

  METHOD skips_noop.
    DATA lt_changes TYPE zcl_alloc_change_doc=>ty_change_tt.
    DATA ls_input   TYPE zcl_alloc_change_doc=>ty_input.

    ls_input-changes = lt_changes.
    ls_input-change = change( iv_object = 'ZSTOCKRUN'
                              iv_field  = 'STATUS'
                              iv_old    = 'DONE'
                              iv_new    = 'DONE' ).

    DATA(lt_new) = mo_cut->add( ls_input ).

    cl_abap_unit_assert=>assert_initial( act = lt_new ).
  ENDMETHOD.

  METHOD keeps_previous.
    DATA lt_changes TYPE zcl_alloc_change_doc=>ty_change_tt.
    DATA ls_input   TYPE zcl_alloc_change_doc=>ty_input.

    ls_input-changes = lt_changes.
    ls_input-change = change( iv_object = 'ZSTOCKRUN'
                              iv_field  = 'STATUS'
                              iv_old    = 'NEW'
                              iv_new    = 'DONE' ).

    DATA(lt_first) = mo_cut->add( ls_input ).

    ls_input-changes = lt_first.
    ls_input-change = change( iv_object = 'ZSTOCKRUN'
                              iv_field  = 'QTY'
                              iv_old    = '5'
                              iv_new    = '8' ).

    DATA(lt_second) = mo_cut->add( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_second ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_second[ 2 ]-field exp = 'QTY' ).
  ENDMETHOD.

ENDCLASS.
