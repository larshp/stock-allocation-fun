CLASS ltcl_alloc_lorenz DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lorenz.
    DATA mt_ser TYPE zcl_alloc_lorenz=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series   FOR TESTING.
    METHODS all_zero       FOR TESTING.
    METHODS equal_values   FOR TESTING.
    METHODS one_holder     FOR TESTING.
    METHODS cumulative_runs FOR TESTING.
    METHODS gap_is_zero    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_lorenz IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lorenz( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_series.
    DATA(lt_points) = mo_cut->build( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_points ) exp = 0 ).
  ENDMETHOD.

  METHOD all_zero.
    add( iv_value = 0 ).
    add( iv_value = 0 ).

    DATA(lt_points) = mo_cut->build( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_points ) exp = 0 ).
  ENDMETHOD.

  METHOD equal_values.
    add( iv_value = 1 ).
    add( iv_value = 1 ).
    add( iv_value = 1 ).
    add( iv_value = 1 ).

    DATA(lt_points) = mo_cut->build( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_points ) exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_points[ 1 ]-cumul_pop exp = 25 ).
    cl_abap_unit_assert=>assert_equals( act = lt_points[ 1 ]-cumul_val exp = 25 ).
    cl_abap_unit_assert=>assert_equals( act = lt_points[ 4 ]-cumul_pop exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_points[ 4 ]-cumul_val exp = 100 ).
  ENDMETHOD.

  METHOD one_holder.
    add( iv_value = 4 ).
    add( iv_value = 0 ).
    add( iv_value = 0 ).
    add( iv_value = 0 ).

    DATA(lt_points) = mo_cut->build( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = lt_points[ 1 ]-cumul_val exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_points[ 3 ]-cumul_val exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_points[ 4 ]-cumul_val exp = 100 ).
  ENDMETHOD.

  METHOD cumulative_runs.
    add( iv_value = 4 ).
    add( iv_value = 0 ).
    add( iv_value = 0 ).
    add( iv_value = 0 ).

    DATA(lt_points) = mo_cut->build( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = lt_points[ 1 ]-rank exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_points[ 1 ]-cumul_pop exp = 25 ).
    cl_abap_unit_assert=>assert_equals( act = lt_points[ 2 ]-cumul_pop exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = lt_points[ 4 ]-cumul_pop exp = 100 ).
  ENDMETHOD.

  METHOD gap_is_zero.
    add( iv_value = 1 ).
    add( iv_value = 1 ).

    DATA(lt_points) = mo_cut->build( mt_ser ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap_of( lt_points ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
