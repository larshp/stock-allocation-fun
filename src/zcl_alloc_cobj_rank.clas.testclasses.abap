CLASS ltcl_alloc_cobj_rank DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cobj_rank.
    DATA mt_line TYPE zcl_alloc_cobj_rank=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_object TYPE string
        iv_margin TYPE i.

    METHODS ranks_objects FOR TESTING.
    METHODS picks_best    FOR TESTING.
    METHODS picks_worst   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cobj_rank IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cobj_rank( ).

    add( iv_object = 'O1' iv_margin = 100 ).
    add( iv_object = 'O2' iv_margin = 300 ).
    add( iv_object = 'O3' iv_margin = -50 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_cobj_rank=>ty_line.

    ls_line-object = iv_object.
    ls_line-margin = iv_margin.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD ranks_objects.
    DATA lt_ranked TYPE zcl_alloc_cobj_rank=>ty_line_tt.

    lt_ranked = mo_cut->rank( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 1 ]-margin exp = 300 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 3 ]-margin exp = -50 ).
  ENDMETHOD.

  METHOD picks_best.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best( mt_line ) exp = 300 ).
  ENDMETHOD.

  METHOD picks_worst.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst( mt_line ) exp = -50 ).
  ENDMETHOD.

ENDCLASS.
