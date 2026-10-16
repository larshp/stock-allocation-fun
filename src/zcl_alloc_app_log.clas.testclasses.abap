CLASS ltcl_alloc_app_log DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_app_log.

    METHODS setup.

    METHODS entry
      IMPORTING
        iv_level      TYPE c
        iv_message    TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_app_log=>ty_entry.

    METHODS writes_entry   FOR TESTING.
    METHODS keeps_history  FOR TESTING.
    METHODS counts_level   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_app_log IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_app_log( ).
  ENDMETHOD.

  METHOD entry.
    rs_row-object = 'ZALLOC'.
    rs_row-subobject = 'RUN'.
    rs_row-level = iv_level.
    rs_row-message = iv_message.
  ENDMETHOD.

  METHOD writes_entry.
    DATA ls_input TYPE zcl_alloc_app_log=>ty_input.

    ls_input-entry = entry( iv_level = 'I' iv_message = 'Started' ).

    DATA(lt_entries) = mo_cut->write( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_entries ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 1 ]-message
                                        exp = 'Started' ).
  ENDMETHOD.

  METHOD keeps_history.
    DATA lt_entries TYPE zcl_alloc_app_log=>ty_entry_tt.
    DATA ls_input   TYPE zcl_alloc_app_log=>ty_input.

    ls_input-entry = entry( iv_level = 'I' iv_message = 'Started' ).
    lt_entries = mo_cut->write( ls_input ).

    ls_input-entries = lt_entries.
    ls_input-entry = entry( iv_level = 'E' iv_message = 'Failed' ).
    lt_entries = mo_cut->write( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_entries ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 2 ]-level exp = 'E' ).
  ENDMETHOD.

  METHOD counts_level.
    DATA lt_entries TYPE zcl_alloc_app_log=>ty_entry_tt.
    DATA ls_input   TYPE zcl_alloc_app_log=>ty_input.
    DATA ls_level   TYPE zcl_alloc_app_log=>ty_level_input.

    ls_input-entry = entry( iv_level = 'I' iv_message = 'Started' ).
    lt_entries = mo_cut->write( ls_input ).

    ls_input-entries = lt_entries.
    ls_input-entry = entry( iv_level = 'E' iv_message = 'Failed' ).
    lt_entries = mo_cut->write( ls_input ).

    ls_level-entries = lt_entries.
    ls_level-level = 'E'.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_of_level( ls_level ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
