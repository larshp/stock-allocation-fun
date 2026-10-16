CLASS ltcl_alloc_landed_value DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_landed_value.
    DATA mt_line TYPE zcl_alloc_landed_value=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_value    TYPE i.

    METHODS apportions_cost FOR TESTING.
    METHODS reads_share     FOR TESTING.
    METHODS sums_total      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_landed_value IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_landed_value( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_landed_value=>ty_line.

    ls_line-material = iv_material.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD apportions_cost.
    DATA lt_shares TYPE zcl_alloc_landed_value=>ty_values_tt.

    add( iv_material = 'M1' iv_value = 1000 ).
    add( iv_material = 'M2' iv_value = 500 ).

    lt_shares = mo_cut->apportion( it_lines = mt_line iv_cost = 300 ).

    cl_abap_unit_assert=>assert_equals( act = lt_shares[ 1 ] exp = 200 ).
    cl_abap_unit_assert=>assert_equals( act = lt_shares[ 2 ] exp = 100 ).
  ENDMETHOD.

  METHOD reads_share.
    add( iv_material = 'M1' iv_value = 1000 ).
    add( iv_material = 'M2' iv_value = 500 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value_share( it_lines = mt_line iv_index = 1 )
      exp = 66 ).
  ENDMETHOD.

  METHOD sums_total.
    DATA lt_shares TYPE zcl_alloc_landed_value=>ty_values_tt.

    add( iv_material = 'M1' iv_value = 1000 ).
    add( iv_material = 'M2' iv_value = 500 ).

    lt_shares = mo_cut->apportion( it_lines = mt_line iv_cost = 300 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( lt_shares ) exp = 300 ).
  ENDMETHOD.

ENDCLASS.
