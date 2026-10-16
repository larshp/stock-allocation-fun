CLASS ltcl_alloc_return_pareto DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_pareto.
    DATA mt_itm TYPE zcl_alloc_return_pareto=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_quantity TYPE i.

    METHODS cumulative_curve FOR TESTING.
    METHODS vital_few_counts   FOR TESTING.
    METHODS total_percent      FOR TESTING.
    METHODS empty_input        FOR TESTING.
    METHODS skips_zero         FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_pareto IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_pareto( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_return_pareto=>ty_item.

    ls_item-material = iv_material.
    ls_item-quantity = iv_quantity.
    APPEND ls_item TO mt_itm.
  ENDMETHOD.

  METHOD cumulative_curve.
    DATA lt_buckets TYPE zcl_alloc_return_pareto=>ty_bucket_tt.

    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M2' iv_quantity = 3 ).
    add( iv_material = 'M3' iv_quantity = 2 ).

    lt_buckets = mo_cut->pareto( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_buckets ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_buckets[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_buckets[ 1 ]-cumulative_percent exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_buckets[ 2 ]-cumulative_percent exp = 80 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_buckets[ 3 ]-cumulative_percent exp = 100 ).
  ENDMETHOD.

  METHOD vital_few_counts.
    DATA lt_buckets TYPE zcl_alloc_return_pareto=>ty_bucket_tt.

    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M2' iv_quantity = 3 ).
    add( iv_material = 'M3' iv_quantity = 2 ).

    lt_buckets = mo_cut->pareto( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->vital_few( it_buckets = lt_buckets iv_threshold = 80 )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->vital_few( it_buckets = lt_buckets iv_threshold = 50 )
      exp = 1 ).
  ENDMETHOD.

  METHOD total_percent.
    DATA lt_buckets TYPE zcl_alloc_return_pareto=>ty_bucket_tt.

    add( iv_material = 'M1' iv_quantity = 5 ).
    add( iv_material = 'M2' iv_quantity = 3 ).
    add( iv_material = 'M3' iv_quantity = 2 ).

    lt_buckets = mo_cut->pareto( mt_itm ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cumulative_percent( lt_buckets ) exp = 100 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_buckets TYPE zcl_alloc_return_pareto=>ty_bucket_tt.

    lt_buckets = mo_cut->pareto( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_buckets ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cumulative_percent( lt_buckets ) exp = 0 ).
  ENDMETHOD.

  METHOD skips_zero.
    DATA lt_buckets TYPE zcl_alloc_return_pareto=>ty_bucket_tt.

    add( iv_material = 'M1' iv_quantity = 0 ).
    add( iv_material = 'M2' iv_quantity = 2 ).

    lt_buckets = mo_cut->pareto( mt_itm ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_buckets ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_buckets[ 1 ]-material exp = 'M2' ).
  ENDMETHOD.

ENDCLASS.
