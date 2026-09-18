CLASS ltcl_alloc_pivot DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pivot.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_matnr      TYPE matnr
        iv_werks      TYPE werks_d
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_pivot=>ty_item.

    METHODS empty_list      FOR TESTING.
    METHODS aggregates_cell FOR TESTING.
    METHODS share_of_matnr  FOR TESTING.
    METHODS sorted_cells    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_pivot IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pivot( ).
  ENDMETHOD.

  METHOD item.
    rs_row-matnr = iv_matnr.
    rs_row-werks = iv_werks.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_pivot=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->build( lt_items ) ).
  ENDMETHOD.

  METHOD aggregates_cell.
    DATA lt_items TYPE zcl_alloc_pivot=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_werks = '1000' iv_quantity = '3' )
      TO lt_items.
    APPEND item( iv_matnr = 'MAT-1' iv_werks = '1000' iv_quantity = '4' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-quantity exp = '7' ).
  ENDMETHOD.

  METHOD share_of_matnr.
    DATA lt_items TYPE zcl_alloc_pivot=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_werks = '1000' iv_quantity = '30' )
      TO lt_items.
    APPEND item( iv_matnr = 'MAT-1' iv_werks = '2000' iv_quantity = '70' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-share_pct exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-share_pct exp = 70 ).
  ENDMETHOD.

  METHOD sorted_cells.
    DATA lt_items TYPE zcl_alloc_pivot=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-2' iv_werks = '1000' iv_quantity = '1' )
      TO lt_items.
    APPEND item( iv_matnr = 'MAT-1' iv_werks = '2000' iv_quantity = '1' )
      TO lt_items.
    APPEND item( iv_matnr = 'MAT-1' iv_werks = '1000' iv_quantity = '1' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-matnr exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-werks exp = '1000' ).
  ENDMETHOD.

ENDCLASS.
