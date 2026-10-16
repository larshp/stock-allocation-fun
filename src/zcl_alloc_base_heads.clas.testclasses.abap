CLASS ltcl_alloc_base_heads DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_base_heads.
    DATA mt_head TYPE zcl_alloc_base_heads=>ty_values_tt.
    DATA mt_cost TYPE zcl_alloc_base_heads=>ty_values_tt.

    METHODS setup.

    METHODS sums_heads   FOR TESTING.
    METHODS head_rate    FOR TESTING.
    METHODS sums_totals  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_base_heads IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_base_heads( ).

    APPEND 5 TO mt_head.
    APPEND 3 TO mt_head.

    APPEND 500 TO mt_cost.
    APPEND 300 TO mt_cost.
  ENDMETHOD.

  METHOD sums_heads.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->heads( mt_head ) exp = 8 ).
  ENDMETHOD.

  METHOD head_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_head( iv_cost = 800 iv_heads = 8 )
      exp = 100 ).
  ENDMETHOD.

  METHOD sums_totals.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_cost ) exp = 800 ).
  ENDMETHOD.

ENDCLASS.
