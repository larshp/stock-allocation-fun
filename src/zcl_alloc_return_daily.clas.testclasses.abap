CLASS ltcl_alloc_return_daily DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_daily.
    DATA mt_itm TYPE zcl_alloc_return_daily=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_day   TYPE d
        iv_count TYPE i.

    METHODS groups_by_day FOR TESTING.
    METHODS totals        FOR TESTING.
    METHODS busiest        FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_daily IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_daily( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_return_daily=>ty_item.

    ls_item-day = iv_day.
    ls_item-count = iv_count.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD groups_by_day.
    DATA lt_groups TYPE zcl_alloc_return_daily=>ty_group_tt.

    add( iv_day = '20260102' iv_count = 5 ).
    add( iv_day = '20260101' iv_count = 2 ).
    add( iv_day = '20260101' iv_count = 1 ).

    lt_groups = mo_cut->group( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_groups ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_groups[ 1 ]-day exp = '20260101' ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 1 ]-count exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_groups[ 2 ]-day exp = '20260102' ).
  ENDMETHOD.

  METHOD totals.
    add( iv_day = '20260101' iv_count = 2 ).
    add( iv_day = '20260102' iv_count = 5 ).
    add( iv_day = '20260101' iv_count = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_itm ) exp = 8 ).
  ENDMETHOD.

  METHOD busiest.
    add( iv_day = '20260101' iv_count = 3 ).
    add( iv_day = '20260102' iv_count = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->busiest_day( mt_itm ) exp = '20260102' ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_groups TYPE zcl_alloc_return_daily=>ty_group_tt.

    lt_groups = mo_cut->group( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_groups ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->busiest_day( mt_itm ) exp = '00000000' ).
  ENDMETHOD.

ENDCLASS.
