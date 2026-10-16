CLASS ltcl_alloc_release_notes DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_release_notes.
    DATA mt_ent TYPE zcl_alloc_release_notes=>ty_entry_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_version TYPE string
        iv_kind    TYPE string
        iv_text    TYPE string.

    METHODS empty_entries FOR TESTING.
    METHODS keeps_entries FOR TESTING.
    METHODS skips_empty   FOR TESTING.
    METHODS counts_kinds  FOR TESTING.
    METHODS lists_titles  FOR TESTING.
    METHODS no_duplicates FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_release_notes IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_release_notes( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_entry TYPE zcl_alloc_release_notes=>ty_entry.

    ls_entry-version = iv_version.
    ls_entry-kind = iv_kind.
    ls_entry-text = iv_text.
    APPEND ls_entry TO mt_ent.
  ENDMETHOD.

  METHOD empty_entries.
    DATA(lt_notes) = mo_cut->build( mt_ent ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_notes ) exp = 0 ).
  ENDMETHOD.

  METHOD keeps_entries.
    add( iv_version = '1.0' iv_kind = 'feature' iv_text = 'First feature' ).
    add( iv_version = '1.1' iv_kind = 'fix' iv_text = 'First fix' ).

    DATA(lt_notes) = mo_cut->build( mt_ent ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_notes ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_notes[ 1 ]-seq exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_notes[ 2 ]-seq exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_notes[ 2 ]-kind exp = 'fix' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_notes[ 2 ]-text exp = 'First fix' ).
  ENDMETHOD.

  METHOD skips_empty.
    add( iv_version = '1.0' iv_kind = 'feature' iv_text = '' ).
    add( iv_version = '1.0' iv_kind = 'fix' iv_text = 'Real fix' ).

    DATA(lt_notes) = mo_cut->build( mt_ent ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_notes ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_notes[ 1 ]-seq exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_notes[ 1 ]-text exp = 'Real fix' ).
  ENDMETHOD.

  METHOD counts_kinds.
    add( iv_version = '1.0' iv_kind = 'feature' iv_text = 'A' ).
    add( iv_version = '1.0' iv_kind = 'feature' iv_text = 'B' ).
    add( iv_version = '1.1' iv_kind = 'fix' iv_text = 'C' ).

    DATA(lt_notes) = mo_cut->build( mt_ent ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_of( it_notes = lt_notes iv_kind = 'feature' ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_of( it_notes = lt_notes iv_kind = 'fix' ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_of( it_notes = lt_notes iv_kind = 'change' ) exp = 0 ).
  ENDMETHOD.

  METHOD lists_titles.
    add( iv_version = '1.0' iv_kind = 'feature' iv_text = 'A' ).
    add( iv_version = '1.1' iv_kind = 'fix' iv_text = 'B' ).

    DATA(lt_notes) = mo_cut->build( mt_ent ).
    DATA(lt_titles) = mo_cut->titles_of( lt_notes ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_titles ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_titles[ 1 ] exp = '1.0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_titles[ 2 ] exp = '1.1' ).
  ENDMETHOD.

  METHOD no_duplicates.
    add( iv_version = '1.0' iv_kind = 'feature' iv_text = 'A' ).
    add( iv_version = '1.0' iv_kind = 'fix' iv_text = 'B' ).
    add( iv_version = '1.0' iv_kind = 'change' iv_text = 'C' ).

    DATA(lt_notes) = mo_cut->build( mt_ent ).
    DATA(lt_titles) = mo_cut->titles_of( lt_notes ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_titles ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_titles[ 1 ] exp = '1.0' ).
  ENDMETHOD.

ENDCLASS.
