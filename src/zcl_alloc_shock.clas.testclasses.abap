CLASS ltcl_alloc_shock DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_shock.
    DATA mt_stock TYPE zif_stock_reader=>ty_stock_tt.

    METHODS setup.

    METHODS add_stock
      IMPORTING
        iv_matnr TYPE matnr
        iv_lgort TYPE lgort_d
        iv_qty   TYPE menge_d.

    METHODS make_input
      IMPORTING
        iv_pct          TYPE i
        iv_abs          TYPE menge_d
        iv_floor        TYPE menge_d
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_shock=>ty_input.

    METHODS reduces_by_percent   FOR TESTING.
    METHODS applies_absolute     FOR TESTING.
    METHODS percent_then_abs     FOR TESTING.
    METHODS respects_floor       FOR TESTING.
    METHODS never_negative       FOR TESTING.
    METHODS keeps_other_fields   FOR TESTING.
    METHODS sums_available       FOR TESTING.
    METHODS empty_stock_empty    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_shock IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_shock( ).
  ENDMETHOD.

  METHOD add_stock.
    DATA ls_stock TYPE zif_stock_reader=>ty_stock.

    ls_stock-matnr = iv_matnr.
    ls_stock-werks = '1000'.
    ls_stock-lgort = iv_lgort.
    ls_stock-unrestricted_qty = iv_qty.
    APPEND ls_stock TO mt_stock.
  ENDMETHOD.

  METHOD make_input.
    rs_input-shock_pct = iv_pct.
    rs_input-shock_abs = iv_abs.
    rs_input-floor = iv_floor.
  ENDMETHOD.

  METHOD reduces_by_percent.
    add_stock( iv_matnr = 'M1' iv_lgort = '0001' iv_qty = 100 ).

    DATA(ls_input) = make_input( iv_pct = 10 iv_abs = 0 iv_floor = 0 ).
    DATA(lt_stock) = mo_cut->apply( is_input = ls_input
                                    it_stock = mt_stock ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_stock[ 1 ]-unrestricted_qty exp = 90 ).
  ENDMETHOD.

  METHOD applies_absolute.
    add_stock( iv_matnr = 'M1' iv_lgort = '0001' iv_qty = 100 ).

    DATA(ls_input) = make_input( iv_pct = 0 iv_abs = 30 iv_floor = 0 ).
    DATA(lt_stock) = mo_cut->apply( is_input = ls_input
                                    it_stock = mt_stock ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_stock[ 1 ]-unrestricted_qty exp = 70 ).
  ENDMETHOD.

  METHOD percent_then_abs.
    add_stock( iv_matnr = 'M1' iv_lgort = '0001' iv_qty = 100 ).

    DATA(ls_input) = make_input( iv_pct = 50 iv_abs = 20 iv_floor = 0 ).
    DATA(lt_stock) = mo_cut->apply( is_input = ls_input
                                    it_stock = mt_stock ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_stock[ 1 ]-unrestricted_qty exp = 30 ).
  ENDMETHOD.

  METHOD respects_floor.
    add_stock( iv_matnr = 'M1' iv_lgort = '0001' iv_qty = 100 ).

    DATA(ls_input) = make_input( iv_pct = 90 iv_abs = 0 iv_floor = 50 ).
    DATA(lt_stock) = mo_cut->apply( is_input = ls_input
                                    it_stock = mt_stock ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_stock[ 1 ]-unrestricted_qty exp = 50 ).
  ENDMETHOD.

  METHOD never_negative.
    add_stock( iv_matnr = 'M1' iv_lgort = '0001' iv_qty = 10 ).

    DATA(ls_input) = make_input( iv_pct = 0 iv_abs = 50 iv_floor = 0 ).
    DATA(lt_stock) = mo_cut->apply( is_input = ls_input
                                    it_stock = mt_stock ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_stock[ 1 ]-unrestricted_qty exp = 0 ).
  ENDMETHOD.

  METHOD keeps_other_fields.
    add_stock( iv_matnr = 'M1' iv_lgort = '0002' iv_qty = 40 ).

    DATA(ls_input) = make_input( iv_pct = 25 iv_abs = 0 iv_floor = 0 ).
    DATA(lt_stock) = mo_cut->apply( is_input = ls_input
                                    it_stock = mt_stock ).

    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-matnr exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-werks exp = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-lgort exp = '0002' ).
  ENDMETHOD.

  METHOD sums_available.
    add_stock( iv_matnr = 'M1' iv_lgort = '0001' iv_qty = 10 ).
    add_stock( iv_matnr = 'M2' iv_lgort = '0001' iv_qty = 25 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->available_of( mt_stock ) exp = 35 ).
  ENDMETHOD.

  METHOD empty_stock_empty.
    DATA(ls_input) = make_input( iv_pct = 10 iv_abs = 0 iv_floor = 0 ).
    DATA(lt_stock) = mo_cut->apply( is_input = ls_input
                                    it_stock = mt_stock ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_stock ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->available_of( mt_stock ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
