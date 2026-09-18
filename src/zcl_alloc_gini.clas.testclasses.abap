CLASS ltcl_alloc_gini DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gini.
    DATA mt_ser TYPE zcl_alloc_gini=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series  FOR TESTING.
    METHODS all_zero      FOR TESTING.
    METHODS single_value  FOR TESTING.
    METHODS equal_values  FOR TESTING.
    METHODS two_unequal   FOR TESTING.
    METHODS one_holder    FOR TESTING.
    METHODS unsorted_same FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gini IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gini( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_series.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( mt_ser ) exp = 0 ).
  ENDMETHOD.

  METHOD all_zero.
    add( iv_value = 0 ).
    add( iv_value = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( mt_ser ) exp = 0 ).
  ENDMETHOD.

  METHOD single_value.
    add( iv_value = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( mt_ser ) exp = 0 ).
  ENDMETHOD.

  METHOD equal_values.
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( mt_ser ) exp = 0 ).
  ENDMETHOD.

  METHOD two_unequal.
    add( iv_value = 10 ).
    add( iv_value = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( mt_ser ) exp = 5000 ).
  ENDMETHOD.

  METHOD one_holder.
    add( iv_value = 30 ).
    add( iv_value = 0 ).
    add( iv_value = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( mt_ser ) exp = 6667 ).
  ENDMETHOD.

  METHOD unsorted_same.
    add( iv_value = 30 ).
    add( iv_value = 0 ).
    add( iv_value = 0 ).

    DATA(lv_first) = mo_cut->calculate( mt_ser ).

    DATA lt_other TYPE zcl_alloc_gini=>ty_series_tt.
    APPEND 0 TO lt_other.
    APPEND 0 TO lt_other.
    APPEND 30 TO lt_other.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->calculate( lt_other ) exp = lv_first ).
  ENDMETHOD.

ENDCLASS.
