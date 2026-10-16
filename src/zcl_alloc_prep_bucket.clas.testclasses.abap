CLASS ltcl_alloc_prep_bucket DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prep_bucket.
    DATA mt_line TYPE zcl_alloc_prep_bucket=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_order TYPE string
        iv_cost  TYPE i.

    METHODS reads_bucket FOR TESTING.
    METHODS counts_bucket FOR TESTING.
    METHODS par_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prep_bucket IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prep_bucket( ).

    add( iv_order = 'O1' iv_cost = 100 ).
    add( iv_order = 'O2' iv_cost = 250 ).
    add( iv_order = 'O3' iv_cost = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_prep_bucket=>ty_line.

    ls_line-order_id = iv_order.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD reads_bucket.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket_of( iv_cost = 250 iv_width = 100 ) exp = 2 ).
  ENDMETHOD.

  METHOD counts_bucket.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_in( it_lines = mt_line iv_bucket = 2 iv_width = 100 )
      exp = 1 ).
  ENDMETHOD.

  METHOD par_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_par( iv_value = 100 iv_target = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_par( iv_value = 90 iv_target = 100 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
