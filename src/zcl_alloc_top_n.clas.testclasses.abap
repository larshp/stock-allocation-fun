CLASS ltcl_alloc_top_n DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_top_n.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_matnr      TYPE matnr
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_top_n=>ty_item.

    METHODS empty_result      FOR TESTING.
    METHODS returns_top_two   FOR TESTING.
    METHODS zero_returns_all  FOR TESTING.
    METHODS more_than_list    FOR TESTING.
    METHODS rank_and_share    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_top_n IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_top_n( ).
  ENDMETHOD.

  METHOD item.
    rs_row-matnr = iv_matnr.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD empty_result.
    DATA lt_items TYPE zcl_alloc_top_n=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->top( lt_items ) ).
  ENDMETHOD.

  METHOD returns_top_two.
    DATA lt_items TYPE zcl_alloc_top_n=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-A' iv_quantity = '10' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-B' iv_quantity = '90' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-C' iv_quantity = '50' ) TO lt_items.

    DATA(lt_lines) = mo_cut->top( it_items = lt_items
                                  iv_n     = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-matnr exp = 'MAT-B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-matnr exp = 'MAT-C' ).
  ENDMETHOD.

  METHOD zero_returns_all.
    DATA lt_items TYPE zcl_alloc_top_n=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-A' iv_quantity = '10' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-B' iv_quantity = '90' ) TO lt_items.

    DATA(lt_lines) = mo_cut->top( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
  ENDMETHOD.

  METHOD more_than_list.
    DATA lt_items TYPE zcl_alloc_top_n=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-A' iv_quantity = '10' ) TO lt_items.

    DATA(lt_lines) = mo_cut->top( it_items = lt_items
                                  iv_n     = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
  ENDMETHOD.

  METHOD rank_and_share.
    DATA lt_items TYPE zcl_alloc_top_n=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-A' iv_quantity = '10' ) TO lt_items.
    APPEND item( iv_matnr = 'MAT-B' iv_quantity = '90' ) TO lt_items.

    DATA(lt_lines) = mo_cut->top( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-rank exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-share_pct exp = 90 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-rank exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-share_pct exp = 10 ).
  ENDMETHOD.

ENDCLASS.
