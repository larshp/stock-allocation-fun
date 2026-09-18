CLASS ltcl_alloc_update_task DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_update_task.

    METHODS setup.

    METHODS input
      IMPORTING
        it_tasks      TYPE zcl_alloc_update_task=>ty_string_tt
        iv_task       TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_update_task=>ty_input.

    METHODS queues_task  FOR TESTING.
    METHODS skips_empty  FOR TESTING.
    METHODS counts_queue FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_update_task IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_update_task( ).
  ENDMETHOD.

  METHOD input.
    rs_row-tasks = it_tasks.
    rs_row-task = iv_task.
  ENDMETHOD.

  METHOD queues_task.
    DATA lt_tasks TYPE zcl_alloc_update_task=>ty_string_tt.

    DATA(lt_new) = mo_cut->queue( input( it_tasks = lt_tasks
                                         iv_task  = 'Z_ALLOC_POST' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_new[ 1 ]
                                        exp = 'Z_ALLOC_POST' ).
  ENDMETHOD.

  METHOD skips_empty.
    DATA lt_tasks TYPE zcl_alloc_update_task=>ty_string_tt.

    DATA(lt_new) = mo_cut->queue( input( it_tasks = lt_tasks
                                         iv_task  = '' ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_new ).
  ENDMETHOD.

  METHOD counts_queue.
    DATA lt_tasks TYPE zcl_alloc_update_task=>ty_string_tt.

    DATA(lt_first) = mo_cut->queue( input( it_tasks = lt_tasks
                                           iv_task  = 'Z_ALLOC_POST' ) ).

    DATA(lt_second) = mo_cut->queue( input( it_tasks = lt_first
                                            iv_task  = 'Z_ALLOC_LOG' ) ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->flush( lt_second )
                                        exp = 2 ).
  ENDMETHOD.

ENDCLASS.
