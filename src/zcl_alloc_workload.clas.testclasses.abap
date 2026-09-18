CLASS ltcl_alloc_workload DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_workload.
    DATA mt_op  TYPE zcl_alloc_workload=>ty_operation_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id    TYPE string
        iv_wc    TYPE string
        iv_per   TYPE i
        iv_hours TYPE menge_d.

    METHODS empty_operations FOR TESTING.
    METHODS aggregates_wc_period FOR TESTING.
    METHODS keeps_distinct_cells FOR TESTING.
    METHODS marks_overload     FOR TESTING.
    METHODS no_capacity_no_flag FOR TESTING.
    METHODS counts_overloads   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_workload IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_workload( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_op TYPE zcl_alloc_workload=>ty_operation.

    ls_op-order_id = iv_id.
    ls_op-work_centre = iv_wc.
    ls_op-period = iv_per.
    ls_op-load_hours = iv_hours.
    APPEND ls_op TO mt_op.
  ENDMETHOD.

  METHOD empty_operations.
    DATA(lt_load) = mo_cut->build( it_operations = mt_op
                                   iv_capacity   = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_load ) exp = 0 ).
  ENDMETHOD.

  METHOD aggregates_wc_period.
    add( iv_id = 'O1' iv_wc = 'WC1' iv_per = 1 iv_hours = 5 ).
    add( iv_id = 'O2' iv_wc = 'WC1' iv_per = 1 iv_hours = 3 ).

    DATA(lt_load) = mo_cut->build( it_operations = mt_op
                                   iv_capacity   = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_load ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-load_hours exp = 8 ).
  ENDMETHOD.

  METHOD keeps_distinct_cells.
    add( iv_id = 'O1' iv_wc = 'WC1' iv_per = 1 iv_hours = 5 ).
    add( iv_id = 'O2' iv_wc = 'WC1' iv_per = 2 iv_hours = 3 ).
    add( iv_id = 'O3' iv_wc = 'WC2' iv_per = 1 iv_hours = 2 ).

    DATA(lt_load) = mo_cut->build( it_operations = mt_op
                                   iv_capacity   = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_load ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-period exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 2 ]-period exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 3 ]-work_centre exp = 'WC2' ).
  ENDMETHOD.

  METHOD marks_overload.
    add( iv_id = 'O1' iv_wc = 'WC1' iv_per = 1 iv_hours = 5 ).
    add( iv_id = 'O2' iv_wc = 'WC1' iv_per = 1 iv_hours = 3 ).
    add( iv_id = 'O3' iv_wc = 'WC2' iv_per = 1 iv_hours = 2 ).

    DATA(lt_load) = mo_cut->build( it_operations = mt_op
                                   iv_capacity   = 5 ).

    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-over exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_load[ 2 ]-over exp = abap_false ).
  ENDMETHOD.

  METHOD no_capacity_no_flag.
    add( iv_id = 'O1' iv_wc = 'WC1' iv_per = 1 iv_hours = 50 ).

    DATA(lt_load) = mo_cut->build( it_operations = mt_op
                                   iv_capacity   = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lt_load[ 1 ]-over exp = abap_false ).
  ENDMETHOD.

  METHOD counts_overloads.
    add( iv_id = 'O1' iv_wc = 'WC1' iv_per = 1 iv_hours = 9 ).
    add( iv_id = 'O2' iv_wc = 'WC2' iv_per = 1 iv_hours = 9 ).
    add( iv_id = 'O3' iv_wc = 'WC3' iv_per = 1 iv_hours = 1 ).

    DATA(lt_load) = mo_cut->build( it_operations = mt_op
                                   iv_capacity   = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overload_count( lt_load ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
