CLASS ltcl_alloc_tsv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_tsv.
    DATA mt_cel TYPE zcl_alloc_csv_export=>ty_text_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_cell TYPE string.

    METHODS separator_is_tab FOR TESTING.
    METHODS joins_cells       FOR TESTING.
    METHODS joins_single      FOR TESTING.
    METHODS joins_nothing     FOR TESTING.
    METHODS splits_line       FOR TESTING.
    METHODS splits_single     FOR TESTING.
    METHODS splits_empty      FOR TESTING.
    METHODS counts_cells      FOR TESTING.
    METHODS round_trip        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_tsv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_tsv( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_cell TO mt_cel.
  ENDMETHOD.

  METHOD separator_is_tab.
    cl_abap_unit_assert=>assert_equals(
      act = strlen( mo_cut->separator( ) ) exp = 1 ).
  ENDMETHOD.

  METHOD joins_cells.
    DATA lv_expected TYPE string.

    add( iv_cell = 'a' ).
    add( iv_cell = 'b' ).

    lv_expected = 'a' && mo_cut->separator( ).
    lv_expected = lv_expected && 'b'.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->join( mt_cel ) exp = lv_expected ).
  ENDMETHOD.

  METHOD joins_single.
    add( iv_cell = 'only' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->join( mt_cel ) exp = 'only' ).
  ENDMETHOD.

  METHOD joins_nothing.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->join( mt_cel ) exp = '' ).
  ENDMETHOD.

  METHOD splits_line.
    DATA lv_line TYPE string.

    lv_line = 'a' && mo_cut->separator( ).
    lv_line = lv_line && 'b'.

    DATA(lt_cells) = mo_cut->split( lv_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_cells ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ] exp = 'a' ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 2 ] exp = 'b' ).
  ENDMETHOD.

  METHOD splits_single.
    DATA(lt_cells) = mo_cut->split( 'only' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_cells ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ] exp = 'only' ).
  ENDMETHOD.

  METHOD splits_empty.
    DATA(lt_cells) = mo_cut->split( '' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_cells ) exp = 0 ).
  ENDMETHOD.

  METHOD counts_cells.
    DATA lv_line TYPE string.

    lv_line = 'a' && mo_cut->separator( ).
    lv_line = lv_line && 'b'.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cell_count( lv_line ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cell_count( 'a' ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cell_count( '' ) exp = 0 ).
  ENDMETHOD.

  METHOD round_trip.
    add( iv_cell = 'a' ).
    add( iv_cell = 'b' ).
    add( iv_cell = 'c' ).

    DATA(lv_line) = mo_cut->join( mt_cel ).
    DATA(lt_cells) = mo_cut->split( lv_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_cells ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 3 ] exp = 'c' ).
  ENDMETHOD.

ENDCLASS.
