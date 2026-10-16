CLASS zcl_alloc_constraint DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_ids_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_constraint,
             constraint_id TYPE string,
             must_hold     TYPE abap_bool,
             holds         TYPE abap_bool,
             detail        TYPE string,
           END OF ty_constraint.
    TYPES ty_constraint_tt TYPE STANDARD TABLE OF ty_constraint WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             total              TYPE i,
             satisfied          TYPE i,
             violated           TYPE i,
             mandatory_violated TYPE i,
             feasible           TYPE abap_bool,
           END OF ty_result.

    METHODS evaluate
      IMPORTING
        it_constraints   TYPE ty_constraint_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    METHODS violated_ids
      IMPORTING
        it_constraints TYPE ty_constraint_tt
      RETURNING
        VALUE(rt_ids)  TYPE ty_ids_tt.

ENDCLASS.


CLASS zcl_alloc_constraint IMPLEMENTATION.

  METHOD evaluate.
    rs_result-total = lines( it_constraints ).

    LOOP AT it_constraints INTO DATA(ls_constraint).
      IF ls_constraint-holds = abap_true.
        rs_result-satisfied = rs_result-satisfied + 1.
        CONTINUE.
      ENDIF.

      rs_result-violated = rs_result-violated + 1.
      IF ls_constraint-must_hold = abap_true.
        rs_result-mandatory_violated = rs_result-mandatory_violated + 1.
      ENDIF.
    ENDLOOP.

    IF rs_result-mandatory_violated = 0.
      rs_result-feasible = abap_true.
    ELSE.
      rs_result-feasible = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD violated_ids.
    LOOP AT it_constraints INTO DATA(ls_constraint).
      IF ls_constraint-holds = abap_false
         AND ls_constraint-must_hold = abap_true.
        APPEND ls_constraint-constraint_id TO rt_ids.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
