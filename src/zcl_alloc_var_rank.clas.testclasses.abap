CLASS ltcl_alloc_var_rank DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_var_rank.
    DATA mt_line TYPE zcl_alloc_var_rank=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_variance TYPE i.

    METHODS ranks_lines FOR TESTING.
    METHODS picks_worst FOR TESTING.
    METHODS picks_best  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_var_rank IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_var_rank( ).

    add( iv_material = 'M1' iv_variance = 200 ).
    add( iv_material = 'M2' iv_variance = -50 ).
    add( iv_material = 'M3' iv_variance = 100 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_var_rank=>ty_line.

    ls_line-material = iv_material.
    ls_line-variance = iv_variance.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD ranks_lines.
    DATA lt_ranked TYPE zcl_alloc_var_rank=>ty_line_tt.

    lt_ranked = mo_cut->rank( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 1 ]-variance exp = 200 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 2 ]-variance exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 3 ]-variance exp = -50 ).
  ENDMETHOD.

  METHOD picks_worst.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst( mt_line ) exp = 200 ).
  ENDMETHOD.

  METHOD picks_best.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best( mt_line ) exp = -50 ).
  ENDMETHOD.

ENDCLASS.
