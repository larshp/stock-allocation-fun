CLASS ltcl_alloc_tu_build DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_tu_build.
    DATA mt_ite TYPE zcl_alloc_tu_build=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_mat    TYPE matnr
        iv_weight TYPE i.

    METHODS fills_gap      FOR TESTING.
    METHODS one_per_unit   FOR TESTING.
    METHODS skips_oversize FOR TESTING.
    METHODS zero_capacity  FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_tu_build IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_tu_build( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_tu_build=>ty_item.

    ls_item-material = iv_mat.
    ls_item-weight = iv_weight.
    APPEND ls_item TO mt_ite.
  ENDMETHOD.

  METHOD fills_gap.
    DATA lt_tus TYPE zcl_alloc_tu_build=>ty_tu_tt.

    add( iv_mat = 'M1' iv_weight = 60 ).
    add( iv_mat = 'M2' iv_weight = 50 ).
    add( iv_mat = 'M3' iv_weight = 40 ).

    lt_tus = mo_cut->build( it_items = mt_ite iv_max_weight = 100 ).

    " 60 then 40 share the first unit, 50 needs its own.
    cl_abap_unit_assert=>assert_equals( act = lines( lt_tus ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_tus[ 1 ]-total_weight exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_tus[ 2 ]-total_weight exp = 50 ).
  ENDMETHOD.

  METHOD one_per_unit.
    DATA lt_tus TYPE zcl_alloc_tu_build=>ty_tu_tt.

    add( iv_mat = 'M1' iv_weight = 60 ).
    add( iv_mat = 'M2' iv_weight = 60 ).

    lt_tus = mo_cut->build( it_items = mt_ite iv_max_weight = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_tus ) exp = 2 ).
  ENDMETHOD.

  METHOD skips_oversize.
    DATA lt_tus TYPE zcl_alloc_tu_build=>ty_tu_tt.

    add( iv_mat = 'BIG' iv_weight = 500 ).
    add( iv_mat = 'M1' iv_weight = 50 ).

    lt_tus = mo_cut->build( it_items = mt_ite iv_max_weight = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_tus ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_tus[ 1 ]-total_weight exp = 50 ).
  ENDMETHOD.

  METHOD zero_capacity.
    DATA lt_tus TYPE zcl_alloc_tu_build=>ty_tu_tt.

    add( iv_mat = 'M1' iv_weight = 50 ).

    lt_tus = mo_cut->build( it_items = mt_ite iv_max_weight = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_tus ) exp = 0 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_tus TYPE zcl_alloc_tu_build=>ty_tu_tt.

    lt_tus = mo_cut->build( it_items = mt_ite iv_max_weight = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_tus ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
