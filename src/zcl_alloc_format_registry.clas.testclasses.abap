CLASS ltcl_alloc_format_registry DEFINITION
  FOR TESTING
    DURATION SHORT
    RISK LEVEL HARMLESS
    FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_format_registry.

    METHODS setup.

    METHODS entry
      IMPORTING
        iv_name       TYPE zcl_alloc_format_registry=>ty_name
        iv_format     TYPE zcl_alloc_format_registry=>ty_format
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_format_registry=>ty_entry.

    METHODS input
      IMPORTING
        it_entries    TYPE zcl_alloc_format_registry=>ty_entry_tt
        is_entry      TYPE zcl_alloc_format_registry=>ty_entry
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_format_registry=>ty_add_input.

    METHODS adds_new     FOR TESTING.
    METHODS replaces     FOR TESTING.
    METHODS sorts_by_name FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_format_registry IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_format_registry( ).
  ENDMETHOD.

  METHOD entry.
    rs_row-name = iv_name.
    rs_row-format = iv_format.
  ENDMETHOD.

  METHOD input.
    rs_row-entries = it_entries.
    rs_row-entry = is_entry.
  ENDMETHOD.

  METHOD adds_new.
    DATA lt_entries TYPE zcl_alloc_format_registry=>ty_entry_tt.
    DATA ls_input   TYPE zcl_alloc_format_registry=>ty_add_input.
    DATA ls_entry   TYPE zcl_alloc_format_registry=>ty_entry.

    ls_entry-name = 'ALLOC'.
    ls_entry-format = 'CSV'.
    ls_input-entries = lt_entries.
    ls_input-entry = ls_entry.

    DATA(lt_new) = mo_cut->add( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_new[ 1 ]-format exp = 'CSV' ).
  ENDMETHOD.

  METHOD replaces.
    DATA lt_entries TYPE zcl_alloc_format_registry=>ty_entry_tt.
    DATA ls_input   TYPE zcl_alloc_format_registry=>ty_add_input.
    DATA ls_entry   TYPE zcl_alloc_format_registry=>ty_entry.

    ls_entry-name = 'ALLOC'.
    ls_entry-format = 'CSV'.
    APPEND ls_entry TO lt_entries.

    ls_entry-format = 'JSON'.
    ls_input-entries = lt_entries.
    ls_input-entry = ls_entry.

    DATA(lt_new) = mo_cut->add( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_new[ 1 ]-format exp = 'JSON' ).
  ENDMETHOD.

  METHOD sorts_by_name.
    DATA lt_entries TYPE zcl_alloc_format_registry=>ty_entry_tt.
    DATA ls_input   TYPE zcl_alloc_format_registry=>ty_add_input.
    DATA ls_entry   TYPE zcl_alloc_format_registry=>ty_entry.

    ls_entry-name = 'MAT'.
    ls_entry-format = 'CSV'.
    APPEND ls_entry TO lt_entries.

    ls_entry-name = 'ALLOC'.
    ls_input-entries = lt_entries.
    ls_input-entry = ls_entry.

    DATA(lt_new) = mo_cut->add( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lt_new[ 1 ]-name exp = 'ALLOC' ).
    cl_abap_unit_assert=>assert_equals( act = lt_new[ 2 ]-name exp = 'MAT' ).
  ENDMETHOD.

ENDCLASS.
