CLASS ltcl_alloc_abc_rank DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_abc_rank.
    DATA mt_line TYPE zcl_alloc_abc_rank=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_activity TYPE string
        iv_cost     TYPE i.

    METHODS ranks_lines FOR TESTING.
    METHODS picks_worst FOR TESTING.
    METHODS picks_best  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_abc_rank IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_abc_rank( ).

    add( iv_activity = 'A' iv_cost = 600 ).
    add( iv_activity = 'B' iv_cost = 900 ).
    add( iv_activity = 'C' iv_cost = 300 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_abc_rank=>ty_line.

    ls_line-activity = iv_activity.
    ls_line-cost = iv_cost.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD ranks_lines.
    DATA lt_ranked TYPE zcl_alloc_abc_rank=>ty_line_tt.

    lt_ranked = mo_cut->rank( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 1 ]-cost exp = 900 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 3 ]-cost exp = 300 ).
  ENDMETHOD.

  METHOD picks_worst.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->worst( mt_line ) exp = 900 ).
  ENDMETHOD.

  METHOD picks_best.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best( mt_line ) exp = 300 ).
  ENDMETHOD.

ENDCLASS.
