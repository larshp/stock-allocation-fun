CLASS ltcl_alloc_load_plan DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_load_plan.
    DATA mt_ite TYPE zcl_alloc_load_plan=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_stop TYPE i
        iv_mat  TYPE matnr
        iv_qty  TYPE menge_d.

    METHODS last_stop_first FOR TESTING.
    METHODS positions       FOR TESTING.
    METHODS empty_plan      FOR TESTING.
    METHODS same_stop_order FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_load_plan IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_load_plan( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_load_plan=>ty_item.

    ls_item-stop = iv_stop.
    ls_item-material = iv_mat.
    ls_item-quantity = iv_qty.
    APPEND ls_item TO mt_ite.
  ENDMETHOD.

  METHOD last_stop_first.
    DATA lt_load TYPE zcl_alloc_load_plan=>ty_load_tt.

    add( iv_stop = 1 iv_mat = 'M1' iv_qty = 5 ).
    add( iv_stop = 3 iv_mat = 'M3' iv_qty = 5 ).
    add( iv_stop = 2 iv_mat = 'M2' iv_qty = 5 ).

    lt_load = mo_cut->plan( mt_ite ).

    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-stop exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 3 ]-stop exp = 1 ).
  ENDMETHOD.

  METHOD positions.
    DATA lt_load TYPE zcl_alloc_load_plan=>ty_load_tt.

    add( iv_stop = 1 iv_mat = 'M1' iv_qty = 5 ).
    add( iv_stop = 2 iv_mat = 'M2' iv_qty = 5 ).

    lt_load = mo_cut->plan( mt_ite ).

    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-load_pos exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 2 ]-load_pos exp = 2 ).
  ENDMETHOD.

  METHOD empty_plan.
    DATA lt_load TYPE zcl_alloc_load_plan=>ty_load_tt.

    lt_load = mo_cut->plan( mt_ite ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_load ) exp = 0 ).
  ENDMETHOD.

  METHOD same_stop_order.
    DATA lt_load TYPE zcl_alloc_load_plan=>ty_load_tt.

    add( iv_stop = 1 iv_mat = 'MB' iv_qty = 5 ).
    add( iv_stop = 1 iv_mat = 'MA' iv_qty = 5 ).

    lt_load = mo_cut->plan( mt_ite ).

    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-material exp = 'MA' ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 2 ]-material exp = 'MB' ).
  ENDMETHOD.

ENDCLASS.
