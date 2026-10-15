CLASS ltcl_alloc_drv_weight DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_drv_weight.
    DATA mt_line TYPE zcl_alloc_drv_weight=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name   TYPE string
        iv_value  TYPE i
        iv_weight TYPE i.

    METHODS weights_one   FOR TESTING.
    METHODS sums_weighted FOR TESTING.
    METHODS sums_weights  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_drv_weight IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_drv_weight( ).

    add( iv_name = 'A' iv_value = 1000 iv_weight = 50 ).
    add( iv_name = 'B' iv_value = 2000 iv_weight = 25 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_drv_weight=>ty_line.

    ls_line-name = iv_name.
    ls_line-value = iv_value.
    ls_line-weight = iv_weight.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD weights_one.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->weight_of( iv_value = 1000 iv_weight = 50 )
      exp = 500 ).
  ENDMETHOD.

  METHOD sums_weighted.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->weighted( mt_line ) exp = 1000 ).
  ENDMETHOD.

  METHOD sums_weights.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_weight( mt_line ) exp = 75 ).
  ENDMETHOD.

ENDCLASS.
