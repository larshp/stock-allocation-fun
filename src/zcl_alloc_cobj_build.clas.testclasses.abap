CLASS ltcl_alloc_cobj_build DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cobj_build.
    DATA mt_line TYPE zcl_alloc_cobj_build=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_object TYPE string
        iv_cost   TYPE i.

    METHODS builds_objects FOR TESTING.
    METHODS counts_objects FOR TESTING.
    METHODS sums_total     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cobj_build IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cobj_build( ).

    add( iv_object = 'O1' iv_cost = 600 ).
    add( iv_object = 'O2' iv_cost = 300 ).
    add( iv_object = 'O1' iv_cost = 100 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_cobj_build=>ty_line.

    ls_line-object = iv_object.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_objects.
    DATA lt_object TYPE zcl_alloc_cobj_build=>ty_object_tt.

    lt_object = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_object ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_object[ 1 ]-object exp = 'O1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_object[ 1 ]-total exp = 700 ).
    cl_abap_unit_assert=>assert_equals( act = lt_object[ 2 ]-total exp = 300 ).
  ENDMETHOD.

  METHOD counts_objects.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->object_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 1000 ).
  ENDMETHOD.

ENDCLASS.
