CLASS ltcl_alloc_abc_bucket DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_bucket.
    DATA mt_value TYPE zcl_alloc_abc_bucket=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS picks_bucket FOR TESTING.
    METHODS counts_in    FOR TESTING.
    METHODS par_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_abc_bucket IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_bucket( ).

    add( iv_value = 100 ).
    add( iv_value = 600 ).
    add( iv_value = 200 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_value.
  ENDMETHOD.

  METHOD picks_bucket.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket_of( iv_cost = 100 iv_boundary = 500 )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket_of( iv_cost = 600 iv_boundary = 500 )
      exp = 2 ).
  ENDMETHOD.

  METHOD counts_in.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_in( it_values = mt_value iv_boundary = 500 iv_bucket = 1 )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_in( it_values = mt_value iv_boundary = 500 iv_bucket = 2 )
      exp = 1 ).
  ENDMETHOD.

  METHOD par_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_par( iv_count_a = 2 iv_count_b = 2 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_par( iv_count_a = 1 iv_count_b = 2 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
