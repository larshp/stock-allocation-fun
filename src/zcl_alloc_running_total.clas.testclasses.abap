CLASS ltcl_alloc_running_total DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_running_total.

    METHODS setup.

    METHODS add
      IMPORTING
        it_qty        TYPE zcl_alloc_running_total=>ty_qty_tt
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rt_qty) TYPE zcl_alloc_running_total=>ty_qty_tt.

    METHODS empty_series FOR TESTING.
    METHODS single_value FOR TESTING.
    METHODS accumulates  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_running_total IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_running_total( ).
  ENDMETHOD.

  METHOD add.
    rt_qty = it_qty.
    APPEND iv_quantity TO rt_qty.
  ENDMETHOD.

  METHOD empty_series.
    DATA lt_qty TYPE zcl_alloc_running_total=>ty_qty_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->calculate( lt_qty ) ).
  ENDMETHOD.

  METHOD single_value.
    DATA lt_qty TYPE zcl_alloc_running_total=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '7' ).

    DATA(lt_lines) = mo_cut->calculate( lt_qty ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-index exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-total exp = '7' ).
  ENDMETHOD.

  METHOD accumulates.
    DATA lt_qty TYPE zcl_alloc_running_total=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '20' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '30' ).

    DATA(lt_lines) = mo_cut->calculate( lt_qty ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]-total exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]-total exp = '30' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]-total exp = '60' ).
  ENDMETHOD.

ENDCLASS.
