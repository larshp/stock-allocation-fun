CLASS ltcl_alloc_format_list DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_format_list.

    METHODS setup.

    METHODS add_entry
      IMPORTING
        it_entries        TYPE zcl_alloc_format_registry=>ty_entry_tt
        iv_name           TYPE zcl_alloc_format_registry=>ty_name
        iv_format         TYPE zcl_alloc_format_registry=>ty_format
      RETURNING
        VALUE(rt_entries) TYPE zcl_alloc_format_registry=>ty_entry_tt.

    METHODS empty_list   FOR TESTING.
    METHODS sorts_names  FOR TESTING.
    METHODS removes_dups FOR TESTING.
    METHODS counts_names FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_format_list IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_format_list( ).
  ENDMETHOD.

  METHOD add_entry.
    DATA ls_entry TYPE zcl_alloc_format_registry=>ty_entry.

    rt_entries = it_entries.
    ls_entry-name = iv_name.
    ls_entry-format = iv_format.
    APPEND ls_entry TO rt_entries.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_entries TYPE zcl_alloc_format_registry=>ty_entry_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->names( lt_entries ) ).
  ENDMETHOD.

  METHOD sorts_names.
    DATA lt_entries TYPE zcl_alloc_format_registry=>ty_entry_tt.

    lt_entries = add_entry( it_entries = lt_entries
                            iv_name    = 'MAT'
                            iv_format  = 'CSV' ).
    lt_entries = add_entry( it_entries = lt_entries
                            iv_name    = 'ALLOC'
                            iv_format  = 'CSV' ).

    DATA(lt_names) = mo_cut->names( lt_entries ).

    cl_abap_unit_assert=>assert_equals( act = lt_names[ 1 ] exp = 'ALLOC' ).
    cl_abap_unit_assert=>assert_equals( act = lt_names[ 2 ] exp = 'MAT' ).
  ENDMETHOD.

  METHOD removes_dups.
    DATA lt_entries TYPE zcl_alloc_format_registry=>ty_entry_tt.

    lt_entries = add_entry( it_entries = lt_entries
                            iv_name    = 'ALLOC'
                            iv_format  = 'CSV' ).
    lt_entries = add_entry( it_entries = lt_entries
                            iv_name    = 'ALLOC'
                            iv_format  = 'JSON' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->names( lt_entries ) ) exp = 1 ).
  ENDMETHOD.

  METHOD counts_names.
    DATA lt_entries TYPE zcl_alloc_format_registry=>ty_entry_tt.

    lt_entries = add_entry( it_entries = lt_entries
                            iv_name    = 'MAT'
                            iv_format  = 'CSV' ).
    lt_entries = add_entry( it_entries = lt_entries
                            iv_name    = 'ALLOC'
                            iv_format  = 'CSV' ).
    lt_entries = add_entry( it_entries = lt_entries
                            iv_name    = 'ALLOC'
                            iv_format  = 'JSON' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( lt_entries )
                                        exp = 2 ).
  ENDMETHOD.

ENDCLASS.
