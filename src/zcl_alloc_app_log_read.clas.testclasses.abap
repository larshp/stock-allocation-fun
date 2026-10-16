CLASS ltcl_alloc_app_log_read DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_app_log_read.

    METHODS setup.

    METHODS add_entry
      IMPORTING
        it_entries        TYPE zcl_alloc_app_log=>ty_entry_tt
        iv_level          TYPE c
        iv_message        TYPE c
      RETURNING
        VALUE(rt_entries) TYPE zcl_alloc_app_log=>ty_entry_tt.

    METHODS empty_entries FOR TESTING.
    METHODS filters_level FOR TESTING.
    METHODS no_errors     FOR TESTING.
    METHODS finds_errors  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_app_log_read IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_app_log_read( ).
  ENDMETHOD.

  METHOD add_entry.
    DATA ls_entry TYPE zcl_alloc_app_log=>ty_entry.

    rt_entries = it_entries.
    ls_entry-object = 'ZALLOC'.
    ls_entry-subobject = 'RUN'.
    ls_entry-level = iv_level.
    ls_entry-message = iv_message.
    APPEND ls_entry TO rt_entries.
  ENDMETHOD.

  METHOD empty_entries.
    DATA ls_input TYPE zcl_alloc_app_log_read=>ty_input.

    ls_input-level = 'E'.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->messages( ls_input ) ).
  ENDMETHOD.

  METHOD filters_level.
    DATA lt_entries TYPE zcl_alloc_app_log=>ty_entry_tt.
    DATA ls_input   TYPE zcl_alloc_app_log_read=>ty_input.

    lt_entries = add_entry( it_entries = lt_entries
                            iv_level   = 'I'
                            iv_message = 'Started' ).
    lt_entries = add_entry( it_entries = lt_entries
                            iv_level   = 'E'
                            iv_message = 'Failed' ).

    ls_input-entries = lt_entries.
    ls_input-level = 'E'.

    DATA(lt_lines) = mo_cut->messages( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'Failed' ).
  ENDMETHOD.

  METHOD no_errors.
    DATA lt_entries TYPE zcl_alloc_app_log=>ty_entry_tt.

    lt_entries = add_entry( it_entries = lt_entries
                            iv_level   = 'I'
                            iv_message = 'Started' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->has_errors( lt_entries )
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD finds_errors.
    DATA lt_entries TYPE zcl_alloc_app_log=>ty_entry_tt.

    lt_entries = add_entry( it_entries = lt_entries
                            iv_level   = 'I'
                            iv_message = 'Started' ).
    lt_entries = add_entry( it_entries = lt_entries
                            iv_level   = 'E'
                            iv_message = 'Failed' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->has_errors( lt_entries )
                                        exp = abap_true ).
  ENDMETHOD.

ENDCLASS.
