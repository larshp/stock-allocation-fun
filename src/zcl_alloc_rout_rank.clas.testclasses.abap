CLASS ltcl_alloc_rout_rank DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rout_rank.
    DATA mt_line TYPE zcl_alloc_rout_rank=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_operation TYPE string
        iv_time      TYPE i.

    METHODS ranks_ops     FOR TESTING.
    METHODS picks_longest FOR TESTING.
    METHODS picks_shortest FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rout_rank IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rout_rank( ).

    add( iv_operation = 'OP1' iv_time = 60 ).
    add( iv_operation = 'OP2' iv_time = 90 ).
    add( iv_operation = 'OP3' iv_time = 30 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_rout_rank=>ty_line.

    ls_line-operation = iv_operation.
    ls_line-time = iv_time.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD ranks_ops.
    DATA lt_ranked TYPE zcl_alloc_rout_rank=>ty_line_tt.

    lt_ranked = mo_cut->rank( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 1 ]-time exp = 90 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 3 ]-time exp = 30 ).
  ENDMETHOD.

  METHOD picks_longest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->longest( mt_line ) exp = 90 ).
  ENDMETHOD.

  METHOD picks_shortest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortest( mt_line ) exp = 30 ).
  ENDMETHOD.

ENDCLASS.
