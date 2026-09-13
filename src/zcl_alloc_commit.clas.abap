CLASS zcl_alloc_commit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_reason TYPE c LENGTH 40.

    TYPES: BEGIN OF ty_result,
             committed   TYPE abap_bool,
             rolled_back TYPE abap_bool,
             message     TYPE c LENGTH 80,
           END OF ty_result.

    METHODS commit
      IMPORTING
        iv_task_count    TYPE i
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    METHODS rollback
      IMPORTING
        iv_reason        TYPE ty_reason
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_commit IMPLEMENTATION.

  METHOD commit.
    rs_result-committed = abap_true.
    rs_result-rolled_back = abap_false.
    rs_result-message = |Committed { iv_task_count } tasks|.
  ENDMETHOD.

  METHOD rollback.
    rs_result-committed = abap_false.
    rs_result-rolled_back = abap_true.

    IF iv_reason IS INITIAL.
      rs_result-message = 'Rolled back'.
    ELSE.
      rs_result-message = iv_reason.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
