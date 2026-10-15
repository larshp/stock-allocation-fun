CLASS ltcl_alloc_warranty_cover DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_warranty_cover.
    DATA mt_itm TYPE zcl_alloc_warranty_cover=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_start    TYPE d
        iv_days     TYPE i
        iv_quantity TYPE menge_d.

    METHODS counts_covered FOR TESTING.
    METHODS sums_quantity  FOR TESTING.
    METHODS shares         FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_warranty_cover IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_warranty_cover( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_warranty_cover=>ty_item.

    ls_item-material = iv_material.
    ls_item-start_day = iv_start.
    ls_item-days = iv_days.
    ls_item-quantity = iv_quantity.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD counts_covered.
    add( iv_material = 'M1' iv_start = '20260101' iv_days = 365
         iv_quantity = 5 ).
    add( iv_material = 'M2' iv_start = '20200101' iv_days = 10
         iv_quantity = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cover( it_items = mt_itm iv_check_day = '20260601' )
      exp = 1 ).
  ENDMETHOD.

  METHOD sums_quantity.
    add( iv_material = 'M1' iv_start = '20260101' iv_days = 365
         iv_quantity = 5 ).
    add( iv_material = 'M2' iv_start = '20260101' iv_days = 365
         iv_quantity = 3 ).
    add( iv_material = 'M3' iv_start = '20200101' iv_days = 10
         iv_quantity = 7 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->covered_quantity( it_items     = mt_itm
                                      iv_check_day = '20260601' )
      exp = 8 ).
  ENDMETHOD.

  METHOD shares.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share_percent( iv_covered = 1 iv_total = 2 )
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share_percent( iv_covered = 1 iv_total = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cover( it_items = mt_itm iv_check_day = '20260601' )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->covered_quantity( it_items     = mt_itm
                                      iv_check_day = '20260601' )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
