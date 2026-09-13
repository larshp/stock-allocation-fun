CLASS ltcl_alloc_matrix DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_matrix.

    METHODS setup.

    METHODS item
      IMPORTING
        iv_matnr      TYPE matnr
        iv_run_id     TYPE c
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_matrix=>ty_item.

    METHODS empty_list   FOR TESTING.
    METHODS aggregates   FOR TESTING.
    METHODS separate_runs FOR TESTING.
    METHODS sorted_cells FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_matrix IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_matrix( ).
  ENDMETHOD.

  METHOD item.
    rs_row-matnr = iv_matnr.
    rs_row-run_id = iv_run_id.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_items TYPE zcl_alloc_matrix=>ty_item_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->build( lt_items ) ).
  ENDMETHOD.

  METHOD aggregates.
    DATA lt_items TYPE zcl_alloc_matrix=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_run_id = 'R1' iv_quantity = '3' )
      TO lt_items.
    APPEND item( iv_matnr = 'MAT-1' iv_run_id = 'R1' iv_quantity = '4' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-quantity exp = '7' ).
  ENDMETHOD.

  METHOD separate_runs.
    DATA lt_items TYPE zcl_alloc_matrix=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-1' iv_run_id = 'R1' iv_quantity = '3' )
      TO lt_items.
    APPEND item( iv_matnr = 'MAT-1' iv_run_id = 'R2' iv_quantity = '4' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-run_id exp = 'R1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-run_id exp = 'R2' ).
  ENDMETHOD.

  METHOD sorted_cells.
    DATA lt_items TYPE zcl_alloc_matrix=>ty_item_tt.

    APPEND item( iv_matnr = 'MAT-2' iv_run_id = 'R1' iv_quantity = '1' )
      TO lt_items.
    APPEND item( iv_matnr = 'MAT-1' iv_run_id = 'R1' iv_quantity = '1' )
      TO lt_items.

    DATA(lt_lines) = mo_cut->build( lt_items ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-matnr exp = 'MAT-1' ).
  ENDMETHOD.

ENDCLASS.
