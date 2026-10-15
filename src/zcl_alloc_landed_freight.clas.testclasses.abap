CLASS ltcl_alloc_landed_freight DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_landed_freight.
    DATA mt_line TYPE zcl_alloc_landed_freight=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i.

    METHODS apportions_freight FOR TESTING.
    METHODS reads_share        FOR TESTING.
    METHODS computes_per_unit  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_landed_freight IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_landed_freight( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_landed_freight=>ty_line.

    ls_line-material = iv_material.
    ls_line-quantity = iv_quantity.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD apportions_freight.
    DATA lt_shares TYPE zcl_alloc_landed_freight=>ty_values_tt.

    add( iv_material = 'M1' iv_quantity = 100 ).
    add( iv_material = 'M2' iv_quantity = 50 ).

    lt_shares = mo_cut->apportion( it_lines = mt_line iv_freight = 300 ).

    cl_abap_unit_assert=>assert_equals( act = lt_shares[ 1 ] exp = 200 ).
    cl_abap_unit_assert=>assert_equals( act = lt_shares[ 2 ] exp = 100 ).
  ENDMETHOD.

  METHOD reads_share.
    add( iv_material = 'M1' iv_quantity = 100 ).
    add( iv_material = 'M2' iv_quantity = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share_of( it_lines = mt_line iv_index = 1 )
      exp = 66 ).
  ENDMETHOD.

  METHOD computes_per_unit.
    add( iv_material = 'M1' iv_quantity = 100 ).
    add( iv_material = 'M2' iv_quantity = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( it_lines = mt_line iv_freight = 300 )
      exp = 2 ).
  ENDMETHOD.

ENDCLASS.
