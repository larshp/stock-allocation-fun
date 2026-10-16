CLASS ltcl_alloc_crp DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_crp.
    DATA mt_ord TYPE zcl_alloc_crp=>ty_order_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id    TYPE string
        iv_wc    TYPE string
        iv_qty   TYPE menge_d
        iv_hours TYPE menge_d.

    METHODS empty_orders      FOR TESTING.
    METHODS single_order      FOR TESTING.
    METHODS aggregates_by_wc  FOR TESTING.
    METHODS counts_orders     FOR TESTING.
    METHODS keeps_wc_order    FOR TESTING.
    METHODS totals_hours      FOR TESTING.
    METHODS zero_hours        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_crp IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_crp( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_order TYPE zcl_alloc_crp=>ty_order.

    ls_order-order_id = iv_id.
    ls_order-work_centre = iv_wc.
    ls_order-quantity = iv_qty.
    ls_order-hours_per_unit = iv_hours.
    APPEND ls_order TO mt_ord.
  ENDMETHOD.

  METHOD empty_orders.
    DATA(lt_load) = mo_cut->calculate( mt_ord ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_load ) exp = 0 ).
  ENDMETHOD.

  METHOD single_order.
    add( iv_id = 'O1' iv_wc = 'WC1' iv_qty = 10 iv_hours = '1.5' ).

    DATA(lt_load) = mo_cut->calculate( mt_ord ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_load ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-load_hours exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-orders exp = 1 ).
  ENDMETHOD.

  METHOD aggregates_by_wc.
    add( iv_id = 'O1' iv_wc = 'WC1' iv_qty = 10 iv_hours = '1.5' ).
    add( iv_id = 'O2' iv_wc = 'WC1' iv_qty = 5 iv_hours = 2 ).
    add( iv_id = 'O3' iv_wc = 'WC2' iv_qty = 4 iv_hours = 1 ).

    DATA(lt_load) = mo_cut->calculate( mt_ord ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_load ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-load_hours exp = 25 ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 2 ]-load_hours exp = 4 ).
  ENDMETHOD.

  METHOD counts_orders.
    add( iv_id = 'O1' iv_wc = 'WC1' iv_qty = 10 iv_hours = 1 ).
    add( iv_id = 'O2' iv_wc = 'WC1' iv_qty = 5 iv_hours = 1 ).

    DATA(lt_load) = mo_cut->calculate( mt_ord ).

    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-orders exp = 2 ).
  ENDMETHOD.

  METHOD keeps_wc_order.
    add( iv_id = 'O1' iv_wc = 'ZETA' iv_qty = 1 iv_hours = 1 ).
    add( iv_id = 'O2' iv_wc = 'ALPHA' iv_qty = 1 iv_hours = 1 ).

    DATA(lt_load) = mo_cut->calculate( mt_ord ).

    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-work_centre exp = 'ZETA' ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 2 ]-work_centre exp = 'ALPHA' ).
  ENDMETHOD.

  METHOD totals_hours.
    add( iv_id = 'O1' iv_wc = 'WC1' iv_qty = 10 iv_hours = 1 ).
    add( iv_id = 'O2' iv_wc = 'WC2' iv_qty = 5 iv_hours = 2 ).

    DATA(lt_load) = mo_cut->calculate( mt_ord ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_hours( lt_load ) exp = 20 ).
  ENDMETHOD.

  METHOD zero_hours.
    add( iv_id = 'O1' iv_wc = 'WC1' iv_qty = 7 iv_hours = 0 ).

    DATA(lt_load) = mo_cut->calculate( mt_ord ).

    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-load_hours exp = 0 ).
  ENDMETHOD.

ENDCLASS.
