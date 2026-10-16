CLASS ltcl_alloc_lot_period DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lot_period.
    DATA mt_dem TYPE zcl_alloc_lot_period=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series      FOR TESTING.
    METHODS groups_in_pairs   FOR TESTING.
    METHODS one_period_grace  FOR TESTING.
    METHODS zero_period_grace FOR TESTING.
    METHODS trailing_partial  FOR TESTING.
    METHODS period_one        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_lot_period IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lot_period( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_dem.
  ENDMETHOD.

  METHOD empty_series.
    DATA(lt_lots) = mo_cut->size( it_demand  = mt_dem
                                  iv_periods = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lots ) exp = 0 ).
  ENDMETHOD.

  METHOD groups_in_pairs.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).
    add( iv_value = 40 ).

    DATA(lt_lots) = mo_cut->size( it_demand  = mt_dem
                                  iv_periods = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lots ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 1 ]-period_from exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 1 ]-period_to exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 1 ]-quantity exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 2 ]-period_from exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 2 ]-quantity exp = 70 ).
  ENDMETHOD.

  METHOD one_period_grace.
    add( iv_value = 10 ).
    add( iv_value = 20 ).

    DATA(lt_lots) = mo_cut->size( it_demand  = mt_dem
                                  iv_periods = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lots ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 1 ]-quantity exp = 10 ).
  ENDMETHOD.

  METHOD zero_period_grace.
    add( iv_value = 10 ).
    add( iv_value = 20 ).

    DATA(lt_lots) = mo_cut->size( it_demand  = mt_dem
                                  iv_periods = -5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lots ) exp = 2 ).
  ENDMETHOD.

  METHOD trailing_partial.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).

    DATA(lt_lots) = mo_cut->size( it_demand  = mt_dem
                                  iv_periods = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lots ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 2 ]-period_from exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 2 ]-period_to exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 2 ]-quantity exp = 30 ).
  ENDMETHOD.

  METHOD period_one.
    add( iv_value = 10 ).
    add( iv_value = 20 ).
    add( iv_value = 30 ).

    DATA(lt_lots) = mo_cut->size( it_demand  = mt_dem
                                  iv_periods = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lots ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lots[ 2 ]-quantity exp = 20 ).
  ENDMETHOD.

ENDCLASS.
