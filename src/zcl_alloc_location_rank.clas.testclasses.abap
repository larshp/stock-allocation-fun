CLASS ltcl_alloc_location_rank DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_location_rank.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_lgort      TYPE lgort_d
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_location_rank=>ty_item.

    METHODS empty_list    FOR TESTING.
    METHODS sorts_by_qty  FOR TESTING.
    METHODS assigns_ranks FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_location_rank IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_location_rank( ).
  ENDMETHOD.

  METHOD item.
    rs_row-lgort = iv_lgort.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_stock TYPE zcl_alloc_location_rank=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->rank( lt_stock ) ).
  ENDMETHOD.

  METHOD sorts_by_qty.
    DATA lt_stock TYPE zcl_alloc_location_rank=>ty_item_tt.

    APPEND item( iv_lgort = 'L1' iv_quantity = '10' ) TO lt_stock.
    APPEND item( iv_lgort = 'L2' iv_quantity = '50' ) TO lt_stock.

    DATA(lt_lines) = mo_cut->rank( lt_stock ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-lgort exp = 'L2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-lgort exp = 'L1' ).
  ENDMETHOD.

  METHOD assigns_ranks.
    DATA lt_stock TYPE zcl_alloc_location_rank=>ty_item_tt.

    APPEND item( iv_lgort = 'L1' iv_quantity = '10' ) TO lt_stock.
    APPEND item( iv_lgort = 'L2' iv_quantity = '50' ) TO lt_stock.

    DATA(lt_lines) = mo_cut->rank( lt_stock ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-rank exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-rank exp = 2 ).
  ENDMETHOD.

ENDCLASS.
