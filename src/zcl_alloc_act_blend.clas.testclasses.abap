CLASS ltcl_alloc_act_blend DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_act_blend.
    DATA mt_line TYPE zcl_alloc_act_blend=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name     TYPE string
        iv_quantity TYPE i
        iv_rate     TYPE i.

    METHODS blends_rates  FOR TESTING.
    METHODS computes_weight FOR TESTING.
    METHODS sums_blended  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_act_blend IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_act_blend( ).

    add( iv_name = 'A' iv_quantity = 100 iv_rate = 2 ).
    add( iv_name = 'B' iv_quantity = 300 iv_rate = 3 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_act_blend=>ty_line.

    ls_line-name = iv_name.
    ls_line-quantity = iv_quantity.
    ls_line-rate = iv_rate.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD blends_rates.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->blend( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD computes_weight.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->weight_of( iv_quantity = 100 iv_total_quantity = 400 )
      exp = 25 ).
  ENDMETHOD.

  METHOD sums_blended.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->blended( mt_line ) exp = 1100 ).
  ENDMETHOD.

ENDCLASS.
