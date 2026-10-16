CLASS ltcl_alloc_class_summary DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_class_summary.
    DATA mt_item TYPE zcl_alloc_class_summary=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_class    TYPE string
        iv_value    TYPE i.

    METHODS builds_summary FOR TESTING.
    METHODS counts_class   FOR TESTING.
    METHODS finds_top      FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_class_summary IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_class_summary( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_class_summary=>ty_item.

    ls_item-material = iv_material.
    ls_item-class = iv_class.
    ls_item-value = iv_value.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD builds_summary.
    DATA lt_summary TYPE zcl_alloc_class_summary=>ty_summary_tt.

    add( iv_material = 'M1' iv_class = 'A' iv_value = 100 ).
    add( iv_material = 'M2' iv_class = 'A' iv_value = 50 ).
    add( iv_material = 'M3' iv_class = 'B' iv_value = 30 ).

    lt_summary = mo_cut->build( mt_item ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_summary ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_summary[ 1 ]-class exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_summary[ 1 ]-count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_summary[ 1 ]-total_value exp = 150 ).
  ENDMETHOD.

  METHOD counts_class.
    add( iv_material = 'M1' iv_class = 'A' iv_value = 100 ).
    add( iv_material = 'M2' iv_class = 'A' iv_value = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_in( it_items = mt_item iv_class = 'A' ) exp = 2 ).
  ENDMETHOD.

  METHOD finds_top.
    add( iv_material = 'M1' iv_class = 'A' iv_value = 100 ).
    add( iv_material = 'M3' iv_class = 'B' iv_value = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->top_class( mt_item ) exp = 'A' ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->top_class( mt_item ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
