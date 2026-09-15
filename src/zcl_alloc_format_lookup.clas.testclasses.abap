CLASS ltcl_alloc_format_lookup DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_format_lookup.

    METHODS setup.

    METHODS input
      IMPORTING
        it_entries    TYPE zcl_alloc_format_registry=>ty_entry_tt
        iv_name       TYPE zcl_alloc_format_registry=>ty_name
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_format_lookup=>ty_input.

    METHODS empty_entries FOR TESTING.
    METHODS finds_entry   FOR TESTING.
    METHODS missing_name  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_format_lookup IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_format_lookup( ).
  ENDMETHOD.

  METHOD input.
    rs_row-entries = it_entries.
    rs_row-name = iv_name.
  ENDMETHOD.

  METHOD empty_entries.
    DATA lt_entries TYPE zcl_alloc_format_registry=>ty_entry_tt.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lookup( input( it_entries = lt_entries
                                   iv_name    = 'ALLOC' ) )
      exp = '' ).
  ENDMETHOD.

  METHOD finds_entry.
    DATA lt_entries TYPE zcl_alloc_format_registry=>ty_entry_tt.
    DATA ls_entry   TYPE zcl_alloc_format_registry=>ty_entry.

    ls_entry-name = 'ALLOC'.
    ls_entry-format = 'CSV'.
    APPEND ls_entry TO lt_entries.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lookup( input( it_entries = lt_entries
                                   iv_name    = 'ALLOC' ) )
      exp = 'CSV' ).
  ENDMETHOD.

  METHOD missing_name.
    DATA lt_entries TYPE zcl_alloc_format_registry=>ty_entry_tt.
    DATA ls_entry   TYPE zcl_alloc_format_registry=>ty_entry.

    ls_entry-name = 'ALLOC'.
    ls_entry-format = 'CSV'.
    APPEND ls_entry TO lt_entries.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lookup( input( it_entries = lt_entries
                                   iv_name    = 'NOPE' ) )
      exp = '' ).
  ENDMETHOD.

ENDCLASS.
