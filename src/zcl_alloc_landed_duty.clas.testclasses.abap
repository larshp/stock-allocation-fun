CLASS ltcl_alloc_landed_duty DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_landed_duty.
    DATA mt_line TYPE zcl_alloc_landed_duty=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_value    TYPE i.

    METHODS apportions_duty FOR TESTING.
    METHODS sums_duty       FOR TESTING.
    METHODS reads_rate      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_landed_duty IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_landed_duty( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_landed_duty=>ty_line.

    ls_line-material = iv_material.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD apportions_duty.
    DATA lt_duty TYPE zcl_alloc_landed_duty=>ty_values_tt.

    add( iv_material = 'M1' iv_value = 1000 ).
    add( iv_material = 'M2' iv_value = 500 ).

    lt_duty = mo_cut->apportion( it_lines = mt_line iv_rate_percent = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lt_duty[ 1 ] exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = lt_duty[ 2 ] exp = 25 ).
  ENDMETHOD.

  METHOD sums_duty.
    DATA lt_duty TYPE zcl_alloc_landed_duty=>ty_values_tt.

    add( iv_material = 'M1' iv_value = 1000 ).
    add( iv_material = 'M2' iv_value = 500 ).

    lt_duty = mo_cut->apportion( it_lines = mt_line iv_rate_percent = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_duty( lt_duty ) exp = 75 ).
  ENDMETHOD.

  METHOD reads_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate_percent( iv_duty_value = 75 iv_customs_value = 1500 )
      exp = 5 ).
  ENDMETHOD.

ENDCLASS.
