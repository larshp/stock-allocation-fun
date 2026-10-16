CLASS ltcl_alloc_stock_guard DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stock_guard.
    DATA mt_pos TYPE zcl_alloc_stock_guard=>ty_position_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_lgort TYPE lgort_d
        iv_open  TYPE menge_d
        iv_move  TYPE menge_d.

    METHODS empty_positions FOR TESTING.
    METHODS closing_computed FOR TESTING.
    METHODS negative_flagged FOR TESTING.
    METHODS zero_is_fine    FOR TESTING.
    METHODS several_flag    FOR TESTING.
    METHODS first_is_reported FOR TESTING.
    METHODS none_is_empty   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stock_guard IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stock_guard( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_position TYPE zcl_alloc_stock_guard=>ty_position.

    ls_position-lgort = iv_lgort.
    ls_position-opening = iv_open.
    ls_position-movement = iv_move.
    APPEND ls_position TO mt_pos.
  ENDMETHOD.

  METHOD empty_positions.
    DATA(lt_findings) = mo_cut->check( mt_pos ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_findings ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->first_negative( mt_pos ) exp = '' ).
  ENDMETHOD.

  METHOD closing_computed.
    DATA ls_position TYPE zcl_alloc_stock_guard=>ty_position.

    ls_position-opening = 10.
    ls_position-movement = -4.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->closing_of( ls_position ) exp = 6 ).
  ENDMETHOD.

  METHOD negative_flagged.
    add( iv_lgort = '0001' iv_open = 10 iv_move = -15 ).

    DATA(lt_findings) = mo_cut->check( mt_pos ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_findings ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_findings[ 1 ]-lgort exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_findings[ 1 ]-closing exp = -5 ).
  ENDMETHOD.

  METHOD zero_is_fine.
    add( iv_lgort = '0001' iv_open = 10 iv_move = -10 ).

    DATA(lt_findings) = mo_cut->check( mt_pos ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_findings ) exp = 0 ).
  ENDMETHOD.

  METHOD several_flag.
    add( iv_lgort = '0001' iv_open = 10 iv_move = -15 ).
    add( iv_lgort = '0002' iv_open = 10 iv_move = -5 ).
    add( iv_lgort = '0003' iv_open = 1 iv_move = -9 ).

    DATA(lt_findings) = mo_cut->check( mt_pos ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_findings ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_findings[ 1 ]-lgort exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_findings[ 2 ]-lgort exp = '0003' ).
  ENDMETHOD.

  METHOD first_is_reported.
    add( iv_lgort = '0001' iv_open = 10 iv_move = -15 ).
    add( iv_lgort = '0002' iv_open = 1 iv_move = -9 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->first_negative( mt_pos ) exp = '0001' ).
  ENDMETHOD.

  METHOD none_is_empty.
    add( iv_lgort = '0001' iv_open = 10 iv_move = -1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->first_negative( mt_pos ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
