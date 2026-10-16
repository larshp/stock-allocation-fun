CLASS ltcl_alloc_copro_split DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_copro_split.
    DATA mt_weight TYPE zcl_alloc_copro_split=>ty_weight_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_product TYPE string
        iv_weight  TYPE i.

    METHODS splits_total  FOR TESTING.
    METHODS reads_share   FOR TESTING.
    METHODS computes_unit FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_copro_split IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_copro_split( ).

    add( iv_product = 'G1' iv_weight = 1 ).
    add( iv_product = 'G2' iv_weight = 3 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_weight TYPE zcl_alloc_copro_split=>ty_weight.

    ls_weight-product = iv_product.
    ls_weight-weight = iv_weight.
    APPEND ls_weight TO mt_weight.
  ENDMETHOD.

  METHOD splits_total.
    DATA lt_share TYPE zcl_alloc_copro_split=>ty_share_tt.

    lt_share = mo_cut->split( iv_total = 400 it_weights = mt_weight ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_share ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_share[ 1 ]-amount exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_share[ 2 ]-amount exp = 300 ).
  ENDMETHOD.

  METHOD reads_share.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->share_of( iv_part = 300 iv_total = 400 ) exp = 75 ).
  ENDMETHOD.

  METHOD computes_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_amount = 300 iv_qty = 3 ) exp = 100 ).
  ENDMETHOD.

ENDCLASS.
